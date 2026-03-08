resource "proxmox_vm_qemu" "this" {
  name        = var.vm_name
  desc        = var.vm_desc
  target_node = var.proxmox_node
  vmid        = var.vm_id
  clone       = var.template_name
  full_clone  = true

  cores   = var.cpu_cores
  memory  = var.memory_mb
  scsihw  = "virtio-scsi-pci"
  machine = "q35"
  agent   = 1

  disk {
    slot     = 0
    type     = "scsi"
    storage  = var.storage
    size     = var.disk_size
    iothread = 1
    discard  = "on"
  }

  network {
    model  = "virtio"
    bridge = var.network_bridge
  }

  os_type    = "cloud-init"
  ipconfig0  = var.ip_address == "dhcp" ? "ip=dhcp" : "ip=${var.ip_address},gw=${var.gateway}"
  nameserver = var.dns
  ciuser     = var.ssh_user
  sshkeys    = var.ssh_public_key

  onboot   = true
  vm_state = "running"

  lifecycle {
    ignore_changes = [network, desc]
  }
}
