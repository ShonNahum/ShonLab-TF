# VM settings (same as ubuntu-vm)
variable "vm_name"       { type = string }
variable "vm_desc" {
  type    = string
  default = ""
}
variable "vm_id"         { type = number }
variable "proxmox_node"  { type = string }
variable "template_name" { type = string }

variable "cpu_cores" {
  type = number
  default = 2
}
variable "memory_mb" { 
  type = number
  default = 4096
  }
variable "disk_size" {
  type = string
  default = "30G"
  }
variable "storage"   { type = string }

variable "network_bridge" { type = string }
variable "ip_address"     {
  type = string
  default = "dhcp" 
  }
variable "gateway"        {
  type = string
  default = ""
  }
variable "dns"            {
  type = string
  default = "1.1.1.1 8.8.8.8"
  }

variable "ssh_user"            {
  type = string
  default = "ubuntu"
}
variable "ssh_public_key"      {
  type = string
  sensitive = true
}
variable "ssh_private_key_path"{
  type = string
  default = "~/.ssh/id_ed25519"
}

# K3s specific
variable "k3s_version" {
  description = "K3s version — 'latest' or pinned e.g. 'v1.29.4+k3s1'"
  type        = string
  default     = "latest"
}

variable "k3s_extra_args" {
  description = "Extra args for the k3s server command"
  type        = string
  default     = "--disable traefik"
}
