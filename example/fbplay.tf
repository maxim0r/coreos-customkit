# Configure the Docker provider
provider "docker" {
  host = "tcp://172.50.0.21:2376"
  cert_path = "${pathexpand("~/.docker/machine/machines/coreos-display")}"
}

resource "docker_image" "fbplay" {
  name = "snizovtsev/fbplay:latest"
}

resource "docker_container" "fbplay" {
  name = "fbplay",
  image = "${docker_image.fbplay.latest}"
  // https://gist.github.com/jsturgis/3b19447b304616f18657
  command = ["http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"]
  rm = true
  capabilities {
    add = ["SYS_TTY_CONFIG"]
  }
  devices {
    host_path = "/dev/tty0"
  }
  devices {
    host_path = "/dev/fb0"
  }
  devices {
    host_path = "/dev/snd"
  }
}
