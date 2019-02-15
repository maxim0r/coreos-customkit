# CoreOS customization toolkit
This [Terraform][2] recipes simplifies creation of Container Linux Ignition configs.
Typically CoreOS ignition scripts ran once right after installation on clean machines.
`coreos-customkit` allows wiping root partition and rerun new scripts again to cut development cycle.
It simulates fast, automated and reproducible CoreOS development environment using iPXE provisioning with Qemu and Matchbox.
## Prerequisites
* Linux host machine with KVM
* Terraform +provider-libvirt +provider-matchbox
* LibVirt with QEmu configured (virt-manager is also recommended)
* Docker and Docker-Machine
## Provisioning
* Download CoreOS assets: `data/get-coreos`
* Generate Matchbox RPC certificates: `( cd cert; ./cert-gen )`
* Put your ssh key into `terraform.tfvars`
* Initialize Terraform plugins: `terraform init`
* Launch matchbox [first][1]: `terraform apply -target docker_container.matchbox`
* Run everything else: `terraform apply`
* Wait until CoreOS installed: `ssh 172.50.0.21 journalctl -u installer.service --follow`
* Reboot VM to apply `/usr/share/oem/grub.cfg` kernel parameters
* `docker-machine create --driver generic --generic-ip-address=172.50.0.21 --generic-ssh-user=core coreos-display`
## Factory reset VM
* Edit your CL config: `cl/display.yaml.tmpl`
* Apply it into matchbox: `terraform apply`
* Reboot VM to GRUB
* Press 'e' and add `coreos.first_boot=1` to kernel cmdline
* Update certs: `docker-machine regenerate-certs coreos-display`
* Reboot again in case of `grub.cfg` changes
## Run example app on VM
Stock CoreOS distribution have no graphics enable by default.
Using this custom CL config we enabled `/dev/fb0` device on CoreOS to play videos.
`terraform apply example` will launch `mplayer` container that streams Big Buck Bounty into VM framebuffer.
Open `virt-manager` to view it.

[1]: https://github.com/hashicorp/terraform/issues/2430
[2]: https://terraform.io/
