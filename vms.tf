# ── Plain Ubuntu VM ─────────────────────────────────────────────────────────
# Uncomment to create. Change vm_id and ip_address to unique values.

module "ubuntu" {
  vm_count = 2
  source = "./modules/ubuntu-vm"
  vm_name     = "ubuntu"
  vm_start_id = 201
  template_id = 100
  proxmox_node  = var.proxmox_node
  template_name = var.template_name

  cpu_cores = 2
  memory_mb = 2048
  disk_size = "20G"
  storage   = var.storage

  network_bridge = var.network_bridge
  ip_address     = "dhcp"
  gateway        = var.gateway
  dns            = var.dns

  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
}
