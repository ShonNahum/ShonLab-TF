resource "proxmox_vm_qemu" "this" {
  count       = var.vm_count
  description = var.vm_desc
  target_node = var.proxmox_node
  vmid   = var.vm_start_id + count.index    
  name   = "${var.vm_name}-${count.index+1}"  
  clone       = var.template_name
  full_clone  = true

  cpu {
    cores = var.cpu_cores
  }
  memory  = var.memory_mb
  boot = "c"
  scsihw = "virtio-scsi-pci"
  machine = "q35"
  agent   = 1

  disk {
    slot     = "scsi0"
    type     = "disk"
    storage  = var.storage
    size     = var.disk_size
    iothread = true
    discard  = true
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = var.network_bridge
  }
  
  disk {
  slot    = "ide2"
  type    = "cloudinit"
  storage = var.storage
  }
  os_type    = "cloud-init"
  ipconfig0  = var.ip_address == "dhcp" ? "ip=dhcp" : "ip=${var.ip_address},gw=${var.gateway}"
  nameserver = var.dns
  ciuser     = var.ssh_user
  sshkeys    = var.ssh_public_key

  start_at_node_boot = true

  lifecycle {
    ignore_changes = [network, description]
  }
}