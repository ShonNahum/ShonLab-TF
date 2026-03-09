terraform {
  required_providers {
    null = { 
      source = "hashicorp/null"
      version = "~> 3.0"
      }
  }
}

# Step 1 — create the VM (reuses the ubuntu-vm module)
module "vm" {
  source = "../ubuntu-vm"

  vm_name       = var.vm_name
  vm_desc       = var.vm_desc
  vm_id         = var.vm_id
  proxmox_node  = var.proxmox_node
  template_name = var.template_name
  cpu_cores     = var.cpu_cores
  memory_mb     = var.memory_mb
  disk_size     = var.disk_size
  storage       = var.storage
  network_bridge = var.network_bridge
  ip_address    = var.ip_address
  gateway       = var.gateway
  dns           = var.dns
  ssh_user      = var.ssh_user
  ssh_public_key = var.ssh_public_key
}

# Step 2 — SSH in and install K3s
resource "null_resource" "k3s_install" {
  depends_on = [module.vm]

  triggers = {
    vm_id = module.vm.vm_id
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cloud-init status --wait || true",
      "sudo apt-get update -qq && sudo apt-get install -y -qq curl",
      var.k3s_version == "latest" ? "curl -sfL https://get.k3s.io | sh -s - ${var.k3s_extra_args}" : "curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION='${var.k3s_version}' sh -s - ${var.k3s_extra_args}",
      "until sudo kubectl get nodes 2>/dev/null | grep -q ' Ready'; do sleep 5; done",
    ]

    connection {
      type        = "ssh"
      host        = module.vm.ip_address
      user        = var.ssh_user
      private_key = file(var.ssh_private_key_path)
      timeout     = "10m"
    }
  }
}
