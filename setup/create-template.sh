#!/bin/bash
# Script to create Ubuntu Cloud-Init template in Proxmox
# Run this on your Proxmox host as root

TEMPLATE_ID=9000
TEMPLATE_NAME="ubuntu-template" # make sure to run inside cloud-init & install qemu-guest-agent if u have problems with it
# Imoprtant after running clout-init init
#sudo cloud-init clean
#sudo truncate -s 0 /etc/machine-id
#sudo rm /var/lib/dbus/machine-id
#sudo rm -f /var/lib/dhcp/*
#and after it only make it convert it back to template
STORAGE="local-lvm"
BRIDGE="vmbr0"
SSH_KEY="$HOME/.ssh/id_rsa.pub"
MEMORY=2048
CORES=2
mkdir -p /var/lib/vz/template/qemu
# 1. Download latest Ubuntu Jammy Cloud image
echo "Downloading Ubuntu Cloud Image..."
IMG_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
IMG_FILE="/var/lib/vz/template/qemu/jammy-cloud.img"
wget -O "$IMG_FILE" "$IMG_URL"

# 2. Create empty VM
echo "Creating VM $TEMPLATE_ID..."
qm create $TEMPLATE_ID --name $TEMPLATE_NAME --memory $MEMORY --cores $CORES --net0 virtio,bridge=$BRIDGE

# 3. Import disk into Proxmox storage
echo "Importing disk..."
qm importdisk $TEMPLATE_ID "$IMG_FILE" $STORAGE

# 4. Attach imported disk as SCSI
qm set $TEMPLATE_ID --scsihw virtio-scsi-pci --scsi0 $STORAGE:vm-$TEMPLATE_ID-disk-0

# 5. Add Cloud-Init disk
qm set $TEMPLATE_ID --ide2 $STORAGE:cloudinit

# 6. Enable QEMU Guest Agent
qm set $TEMPLATE_ID --agent enabled=1

# 7. Set default user and SSH key
qm set $TEMPLATE_ID --ciuser ubuntu --sshkey "$(cat $SSH_KEY)"

# 8. Optional: set boot order to SCSI disk first
qm set $TEMPLATE_ID --boot c --bootdisk scsi0

# 9. Convert VM to template
qm template $TEMPLATE_ID

echo "✅ Ubuntu Cloud-Init template created!"
echo "VM ID: $TEMPLATE_ID, Name: $TEMPLATE_NAME"
