output "ip_address" {
  value = var.ip_address == "dhcp" ? proxmox_vm_qemu.this.default_ipv4_address : split("/", var.ip_address)[0]
}

output "vm_id" {
  value = proxmox_vm_qemu.this.vmid
}

output "ssh_command" {
  value = "ssh ${var.ssh_user}@${var.ip_address == "dhcp" ? proxmox_vm_qemu.this.default_ipv4_address : split("/", var.ip_address)[0]}"
}
