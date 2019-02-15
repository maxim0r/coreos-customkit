provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "display" {
  name = "coreos-display"
  pool = "default"
  format = "qcow2"
  size = "${10*1024*1024*1024}"
}

resource "libvirt_domain" "display" {
  name = "coreos-display"
  memory = "2048"
  vcpu = 1

  disk {
    volume_id = "${libvirt_volume.display.id}"
    scsi = true
  }

  network_interface {
    bridge = "${local.matchbox_bridge_iface}"
  }

  boot_device {
    dev = [ "hd", "network" ]
  }
}
