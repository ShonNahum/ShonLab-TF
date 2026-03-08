# ── K3s outputs ─────────────────────────────────────────────────────────────

output "k3s_ip" {
  value = module.k3s.ip_address
}

output "k3s_ssh" {
  value = module.k3s.ssh_command
}

output "k3s_kubeconfig" {
  description = "Run this to get your kubeconfig"
  value       = module.k3s.kubeconfig_cmd
}

output "k3s_node_token" {
  description = "Run this to get the join token (for adding worker nodes)"
  value       = module.k3s.node_token_cmd
}

# ── Ubuntu VM outputs ────────────────────────────────────────────────────────
# Uncomment when you activate the ubuntu_dev module in vms.tf

# output "ubuntu_dev_ip"  { value = module.ubuntu_dev.ip_address }
# output "ubuntu_dev_ssh" { value = module.ubuntu_dev.ssh_command }
