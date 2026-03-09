output "ip_addresses" {
  description = "IP addresses of all VMs"
  value = [
    for i in range(var.vm_count) : var.ip_address == "dhcp" 
      ? proxmox_vm_qemu.this[i].default_ipv4_address 
      : split("/", var.ip_address)[0]
  ]
}

output "vm_ids" {
  description = "VM IDs of all VMs"
  value = [
    for i in range(var.vm_count) : proxmox_vm_qemu.this[i].vmid
  ]
}

output "ssh_commands" {
  description = "SSH commands to connect to all VMs"
  value = [
    for i in range(var.vm_count) : "ssh ${var.ssh_user}@${var.ip_address == "dhcp" ? proxmox_vm_qemu.this[i].default_ipv4_address : split("/", var.ip_address)[0]}"
  ]
}