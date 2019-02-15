# dnsmasq.conf

no-daemon
dhcp-range=${cidrhost("${network}", 50)},${cidrhost("${network}", 99)}
dhcp-option=3,${cidrhost("${network}", 1)}
dhcp-host=${node0_mac},${cidrhost("${network}", 21)},1h

enable-tftp
tftp-root=/var/lib/tftpboot

# Legacy PXE
dhcp-match=set:bios,option:client-arch,0
dhcp-boot=tag:bios,undionly.kpxe

# UEFI
dhcp-match=set:efi32,option:client-arch,6
dhcp-boot=tag:efi32,ipxe.efi

dhcp-match=set:efibc,option:client-arch,7
dhcp-boot=tag:efibc,ipxe.efi

dhcp-match=set:efi64,option:client-arch,9
dhcp-boot=tag:efi64,ipxe.efi

# iPXE
dhcp-userclass=set:ipxe,iPXE
dhcp-boot=tag:ipxe,${matchbox_http_endpoint}/boot.ipxe

log-queries
log-dhcp

address=/matchbox.docker/${matchbox_ip_address}
address=/${node0_name}.vm/${cidrhost("${network}", 21)}
