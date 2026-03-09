
# ── Ubuntu VM outputs ────────────────────────────────────────────────────────

output "ubuntu_ip" {
  description = "ubuntu ip"
  value       = module.ubuntu.ip_address
}

output "ubuntu_ssh" {
  description = "ubuntu ssh"
  value       = module.ubuntu.ssh_command
}