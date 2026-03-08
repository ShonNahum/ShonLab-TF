##############################################################################
# vms.tf — Define your VMs here.
#
# To add a VM: copy one of the module blocks below, change the name/id/ip.
# To remove a VM: delete or comment out its module block, then terraform apply.
##############################################################################

# ── K3s Node ────────────────────────────────────────────────────────────────

module "k3s" {
  source = "./modules/k3s-vm"

  vm_name      = "k3s"
  vm_id        = 200
  proxmox_node = var.proxmox_node
  template_name = var.template_name

  cpu_cores = 2
  memory_mb = 4096
  disk_size = "30G"
  storage   = var.storage

  network_bridge = var.network_bridge
  ip_address     = "192.168.1.50/24"
  gateway        = var.gateway
  dns            = var.dns

  ssh_user             = var.ssh_user
  ssh_public_key       = var.ssh_public_key
  ssh_private_key_path = var.ssh_private_key_path

  k3s_version    = "latest"
  k3s_extra_args = "--disable traefik"
}

# ── Plain Ubuntu VM ─────────────────────────────────────────────────────────
# Uncomment to create. Change vm_id and ip_address to unique values.

# module "ubuntu_dev" {
#   source = "./modules/ubuntu-vm"
#
#   vm_name       = "ubuntu-dev"
#   vm_id         = 201
#   proxmox_node  = var.proxmox_node
#   template_name = var.template_name
#
#   cpu_cores = 2
#   memory_mb = 2048
#   disk_size = "20G"
#   storage   = var.storage
#
#   network_bridge = var.network_bridge
#   ip_address     = "192.168.1.51/24"
#   gateway        = var.gateway
#   dns            = var.dns
#
#   ssh_user       = var.ssh_user
#   ssh_public_key = var.ssh_public_key
# }
