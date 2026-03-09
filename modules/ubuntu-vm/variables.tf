variable "vm_name"       { type = string }
variable "vm_id"         { type = number }
variable "proxmox_node"  { type = string }
variable "template_name" { type = string }
variable "storage"       { type = string }
variable "network_bridge"{ type = string }
variable "ssh_public_key" {
  type = string
  sensitive = true
}

variable "vm_desc" {
  type    = string
  default = ""
}

variable "cpu_cores" {
  type    = number
  default = 2
}

variable "memory_mb" {
  type    = number
  default = 2048
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "ip_address" {
  type    = string
  default = "dhcp"
}

variable "gateway" {
  type    = string
  default = ""
}

variable "dns" {
  type    = string
  default = "1.1.1.1 8.8.8.8"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}