output "ip_address"       { value = module.vm.ip_address }
output "vm_id"            { value = module.vm.vm_id }
output "ssh_command"      { value = module.vm.ssh_command }
output "kubeconfig_cmd"   { value = "ssh ${var.ssh_user}@${module.vm.ip_address} 'sudo cat /etc/rancher/k3s/k3s.yaml'" }
output "node_token_cmd"   { value = "ssh ${var.ssh_user}@${module.vm.ip_address} 'sudo cat /var/lib/rancher/k3s/server/node-token'" }
