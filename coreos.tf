provider "matchbox" {
  endpoint    = "${local.matchbox_rpc_endpoint}"
  client_cert = "${file("${path.module}/cert/client.crt")}"
  client_key  = "${file("${path.module}/cert/client.key")}"
  ca          = "${file("${path.module}/cert/ca.crt")}"
}

/////////////////////////////////////////////////////////////////////

// iPXE CoreOS-install profile
resource "matchbox_profile" "coreos-install" {
  name   = "coreos-install"
  kernel = "/assets/coreos/${var.coreos_version}/coreos_production_pxe.vmlinuz"

  initrd = [
    "/assets/coreos/${var.coreos_version}/coreos_production_pxe_image.cpio.gz",
  ]

  args = [
    "initrd=coreos_production_pxe_image.cpio.gz",
    "coreos.config.url=${local.matchbox_http_endpoint}/ignition?uuid=$${uuid}&mac=$${mac:hexhyp}",
    "coreos.first_boot=yes",
    "console=tty0",
    "console=ttyS0",
  ]

  container_linux_config = "${file("./cl/coreos-install.yaml.tmpl")}"
}

// ROOT partition wipe profile
resource "matchbox_profile" "wipe" {
  name                   = "wipe"
  container_linux_config = "${file("./cl/wipe.yaml.tmpl")}"
}

// Framebuffer enabled node
resource "matchbox_profile" "display" {
  name                   = "display"
  container_linux_config = "${file("./cl/display.yaml.tmpl")}"
}

/////////////////////////////////////////////////////////////////////

// Install Container Linux to disk before provisioning
resource "matchbox_group" "default" {
  name    = "default"
  profile = "${matchbox_profile.coreos-install.name}"

  // No selector, matches all nodes

  metadata {
    baseurl = "${local.matchbox_http_endpoint}/assets/coreos"
    ignition_endpoint = "${local.matchbox_http_endpoint}/ignition"
    ssh_authorized_key = "${var.ssh_authorized_key}"
  }
}

resource "matchbox_group" "wipe" {
  name    = "wipe"
  profile = "${matchbox_profile.wipe.name}"

  selector {
    os  = "installed"
  }

  metadata {
    ignition_endpoint = "${local.matchbox_http_endpoint}/ignition"
  }
}

resource "matchbox_group" "virt_display" {
  name    = "virt_display"
  profile = "${matchbox_profile.display.name}"

  selector {
    mac = "${libvirt_domain.display.network_interface.0.mac}"
    os  = "installed"
    append = "1"
  }

  metadata {
    domain_name          = "${libvirt_domain.display.name}.vm"
    ssh_authorized_key   = "${var.ssh_authorized_key}"
    vga_mode             = "${var.vesafb_vga_mode}"
  }
}
