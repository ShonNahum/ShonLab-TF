
# ── Ubuntu VM outputs ────────────────────────────────────────────────────────

output "ubuntu_ips" {
  value = module.ubuntu.ip_addresses
}

output "ubuntu_vm_ids" {
  value = module.ubuntu.vm_ids
}

output "ubuntu_ssh" {
  value = module.ubuntu.ssh_commands
}