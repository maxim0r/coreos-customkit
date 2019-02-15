resource "docker_image" "matchbox" {
  name = "quay.io/coreos/matchbox:v0.7.1"
}

resource "docker_image" "dnsmasq" {
  name = "quay.io/coreos/dnsmasq:v0.5.0"
}

locals {
  matchbox_http_port = 8080
  matchbox_rpc_port = 8081
  matchbox_ip_address = "${docker_container.matchbox.ip_address}"
  matchbox_http_endpoint = "http://${local.matchbox_ip_address}:${local.matchbox_http_port}"
  matchbox_rpc_endpoint = "${local.matchbox_ip_address}:${local.matchbox_rpc_port}"
  matchbox_bridge_iface = "br-matchbox"
}

resource "docker_network" "matchbox" {
  name = "matchbox"
  driver = "bridge"
  options {
    "com.docker.network.bridge.name" = "${local.matchbox_bridge_iface}"
  }
  ipam_config {
    subnet = "172.50.0.0/16"
  }
}

resource "docker_container" "matchbox" {
  name = "matchbox",
  image = "${docker_image.matchbox.latest}"
  command = [
    "-address=0.0.0.0:8080",
    "-rpc-address=0.0.0.0:8081",
    "-log-level=debug",
  ]
  rm = true
  destroy_grace_seconds = 2
  ports {
    internal = 8080
    external = "${local.matchbox_http_port}"
  }
  ports {
    internal = 8081
    external = "${local.matchbox_rpc_port}"
  }
  volumes {
    host_path = "${path.module}/data"
    container_path = "/var/lib/matchbox"
  }
  upload {
    content = "${file("${path.module}/cert/ca.crt")}"
    file = "/etc/matchbox/ca.crt"
  }
  upload {
    content = "${file("${path.module}/cert/server.crt")}"
    file = "/etc/matchbox/server.crt"
  }
  upload {
    content = "${file("${path.module}/cert/server.key")}"
    file = "/etc/matchbox/server.key"
  }
  networks_advanced {
    name = "matchbox"
  }
}

resource "docker_container" "dnsmasq" {
  name = "matchbox-netboot"
  image = "${docker_image.dnsmasq.latest}"
  rm = true
  destroy_grace_seconds = 2
  capabilities {
    add = ["NET_ADMIN"]
  }
  upload {
    content = "${data.template_file.dnsmasq_conf.rendered}"
    file = "/etc/dnsmasq.conf"
  }
  networks_advanced {
    name = "matchbox"
  }
}

data "template_file" "dnsmasq_conf" {
  template = "${file("${path.module}/dnsmasq.conf.tpl")}"
  vars = {
    network = "${format("%s/%s", "${docker_container.matchbox.network_data.0.gateway}", "${docker_container.matchbox.network_data.0.ip_prefix_length}")}"
    matchbox_ip_address = "${docker_container.matchbox.network_data.0.ip_address}"
    matchbox_http_endpoint = "${local.matchbox_http_endpoint}"
    node0_name = "${libvirt_domain.display.name}"
    node0_mac = "${libvirt_domain.display.network_interface.0.mac}"
  }
}
