# ── Proxmox connection ──────────────────────────────────────────────────────

variable "proxmox_api_url" {
  description = "Proxmox API URL, e.g. https://192.168.1.10:8006/api2/json"
  type        = string
}

variable "proxmox_token_id" {
  description = "API token ID, format: user@realm!tokenname"
  type        = string
}

variable "proxmox_token_secret" {
  description = "API token secret"
  type        = string
  sensitive   = true
}

# ── Defaults shared by all VMs ──────────────────────────────────────────────

variable "proxmox_node" {
  description = "Name of your Proxmox node (shown in the web UI)"
  type        = string
  default     = "pve"
}

variable "template_name" {
  description = "Name of the VM template to clone (created by setup/create-template.sh)"
  type        = string
  default     = "ubuntu-22.04-cloud"
}

variable "storage" {
  description = "Proxmox storage pool for VM disks"
  type        = string
  default     = "local-lvm"
}

variable "network_bridge" {
  description = "Proxmox network bridge"
  type        = string
  default     = "vmbr0"
}

variable "gateway" {
  description = "Your network gateway (router IP)"
  type        = string
  default     = "192.168.1.1"
}

variable "dns" {
  description = "DNS servers (space-separated)"
  type        = string
  default     = "1.1.1.1 8.8.8.8"
}

variable "ssh_user" {
  description = "Username created on the VM by cloud-init"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "Your SSH public key (contents of ~/.ssh/id_ed25519.pub)"
  type        = string
  sensitive   = true
}

variable "ssh_private_key_path" {
  description = "Path to your SSH private key on this machine"
  type        = string
  default     = "~/.ssh/id_ed25519"
}
