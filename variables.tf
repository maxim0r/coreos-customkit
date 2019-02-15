variable "ssh_authorized_key" {
  type        = "string"
  description = "SSH public key to set as an authorized_key on machines"
}

variable "coreos_version" {
  type        = "string"
  description = "CoreOS version number (like 1967.6.0)"
}

variable "vesafb_vga_mode" {
  type        = "string"
  description = "Linux vesafb mode (Documentation/fb/vesafb.txt)"
}
