# proxmox-tf

Modular Terraform project to deploy Ubuntu and K3s VMs on Proxmox.

---

## Project Structure

```
proxmox-tf/
│
├── vms.tf                    ← DEFINE YOUR VMs HERE (one module block per VM)
├── outputs.tf                ← what prints after terraform apply
├── variables.tf              ← shared settings (node, storage, bridge, SSH key)
├── provider.tf               ← Proxmox API connection
├── versions.tf               ← Terraform + provider version locks
├── terraform.tfvars.example  ← copy to terraform.tfvars and fill in (the rael terraform.tfvars i dont commit it.)
│
├── modules/
│   ├── ubuntu-vm/            ← plain Ubuntu VM
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── ADD-vm/               ←  VM 
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
└── setup/
    └── create-template.sh    ← run ONCE on your Proxmox server
```

---

## Before You Start — Create the Template

Terraform clones a VM template to create new VMs. You need to create
this template once on your Proxmox server.

**SSH into your Proxmox server and run:**

```bash
bash <(curl -s https://raw.githubusercontent.com/ShonNahum/ShonLab-TF/main/setup/create-template.sh)
```

Or copy the script manually:

```bash
# On your Proxmox server:
wget -O /tmp/create-template.sh https://...
bash /tmp/create-template.sh

# With custom options:
bash /tmp/create-template.sh 9000 local-lvm vmbr0
#                            ^     ^         ^
#                        VM ID  storage   bridge
```

This downloads the Ubuntu 22.04 cloud image, installs the qemu guest agent
into it, and registers it as a Proxmox template. Takes about 2-3 minutes.

---

## Setup

### 1. Create a Proxmox API token

In the Proxmox web UI:
```
Datacenter → Permissions → API Tokens → Add
  User:                terraform@pam
  Token name:          mytoken
  Privilege Separation: unchecked
```
Copy the secret — you only see it once.

Then add permissions:
```
Datacenter → Permissions → Add → API Token Permission
  Path:  /
  Token: terraform@pam!mytoken
  Role:  PVEVMAdmin
```

### 2. Configure

```bash
cp terraform.tfvars.example terraform.tfvars
nano terraform.tfvars
```

Fill in:
- `proxmox_api_url` — e.g. `https://192.168.1.10:8006/api2/json`
- `proxmox_token_secret` — the secret from step 1
- `ssh_public_key` — contents of your `~/.ssh/id_ed25519.pub`
- `gateway` — your router IP

### 3. Deploy

```bash
terraform init     # download the Proxmox provider
terraform plan     # preview what will be created
terraform apply    # create the VMs
```

---

## Adding a New VM

Open `vms.tf` and add a module block:

**Plain Ubuntu:**
```hcl
module "my_server" {
  source = "./modules/ubuntu-vm"

  vm_name       = "my-server"
  vm_id         = 202           # must be unique
  proxmox_node  = var.proxmox_node
  template_name = var.template_name

  cpu_cores = 2
  memory_mb = 2048
  disk_size = "20G"
  storage   = var.storage

  network_bridge = var.network_bridge
  ip_address     = "192.168.1.52/24"  # must be unique
  gateway        = var.gateway
  dns            = var.dns

  ssh_user       = var.ssh_user
  ssh_public_key = var.ssh_public_key
}
```


Then:
```bash
terraform apply   # only the new VM is created — existing VMs untouched
```

**To delete a VM:** comment out or delete its block, then `terraform apply`.

---
## Useful Commands

```bash
terraform init        # first time setup
terraform plan        # preview changes
terraform apply       # apply changes
terraform destroy     # delete everything
terraform output      # show all outputs
terraform fmt         # auto-format .tf files
```

## USE ENV VARIBLES
variable "ssh_user" { type = string; default = "ubuntu" }
```

Terraform checks in this order every time you run it:
```
1. TF_VAR_ssh_user env var   ← if set, uses this
2. terraform.tfvars           ← if set, uses this
3. default = "ubuntu"         ← falls back to this

export TF_VAR_proxmox_api_url="https://192.168.1.10:8006/api2/json"
export TF_VAR_proxmox_token_id="terraform@pam!mytoken"
export TF_VAR_proxmox_token_secret="xxxx-xxxx-xxxx"
export TF_VAR_ssh_public_key="ssh-ed25519 AAAAC3..."
```

Then just run `terraform apply` — no `terraform.tfvars` needed at all.

---

The naming rule is simple:
```
variable "proxmox_token_secret"  →  TF_VAR_proxmox_token_secret


## ARCITCTURE
Your PC (terraform apply)
         │
         │  reads
         ├──────────► terraform.tfvars        (your credentials + defaults)
         │
         │  reads
         ├──────────► vms.tf                  (which VMs you want)
         │                │
         │                │ calls
         │                ├──────► modules/ADD-vm/      (for ADD VMs)
         │                                       │
         │                         Proxmox API   │
         │                         ◄─────────────┘
         │                └──────► modules/ubuntu-vm/   
         │                                       │
         │                         Proxmox API   │
         │                         ◄─────────────┘
         │
         │  after VM is created 
         └──────────► SSH into VM 