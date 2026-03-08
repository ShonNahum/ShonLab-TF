#!/usr/bin/env bash
##############################################################################
# setup/create-template.sh
#
# Run this ONCE on your Proxmox server to create the VM template.
# Everything Terraform creates will be cloned from this template.
#
# HOW TO USE:
#   1. SSH into your Proxmox server
#   2. Run: bash create-template.sh
#
# OPTIONAL ARGUMENTS:
#   bash create-template.sh [TEMPLATE_ID] [STORAGE] [BRIDGE]
#
#   TEMPLATE_ID  — VM ID for the template (default: 9000)
#   STORAGE      — where to store it     (default: local-lvm)
#   BRIDGE       — network bridge        (default: vmbr0)
##############################################################################
set -euo pipefail

TEMPLATE_ID="${1:-9000}"
STORAGE="${2:-local-lvm}"
BRIDGE="${3:-vmbr0}"
IMAGE_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
IMAGE_FILE="/tmp/ubuntu-22.04-cloud.img"
TEMPLATE_NAME="ubuntu-22.04-cloud"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Proxmox Template Creator"
echo " Template ID : $TEMPLATE_ID"
echo " Storage     : $STORAGE"
echo " Bridge      : $BRIDGE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Make sure we're on a Proxmox host
command -v qm &>/dev/null || { echo "ERROR: Run this on your Proxmox server."; exit 1; }

# Install libguestfs-tools (needed to customise the image)
echo "[1/5] Installing tools..."
apt-get install -y --no-install-recommends libguestfs-tools wget

# Download Ubuntu 22.04 cloud image (skip if already present)
echo "[2/5] Downloading Ubuntu 22.04 cloud image..."
if [[ ! -f "$IMAGE_FILE" ]]; then
  wget -q --show-progress -O "$IMAGE_FILE" "$IMAGE_URL"
else
  echo "      Already downloaded, skipping."
fi

# Install qemu-guest-agent into the image
# This daemon lets Proxmox read the VM's IP and do clean shutdowns
echo "[3/5] Installing qemu-guest-agent into image..."
virt-customize -a "$IMAGE_FILE" \
  --install qemu-guest-agent \
  --run-command "systemctl enable qemu-guest-agent" \
  --run-command "apt-get clean" \
  --truncate /etc/machine-id

# Create the VM that will become our template
echo "[4/5] Creating VM $TEMPLATE_ID in Proxmox..."
qm create "$TEMPLATE_ID" \
  --name "$TEMPLATE_NAME" \
  --memory 2048 --cores 2 \
  --net0 virtio,bridge="$BRIDGE" \
  --ostype l26 \
  --machine q35 \
  --scsihw virtio-scsi-pci \
  --agent enabled=1,fstrim_cloned_disks=1

# Import the disk and configure boot + cloud-init drive
qm importdisk "$TEMPLATE_ID" "$IMAGE_FILE" "$STORAGE"
qm set "$TEMPLATE_ID" \
  --scsi0 "$STORAGE:vm-${TEMPLATE_ID}-disk-1,discard=on,iothread=1" \
  --ide2  "$STORAGE:cloudinit" \
  --boot c --bootdisk scsi0 \
  --serial0 socket --vga serial0

# Convert to template — templates can only be cloned, not started
echo "[5/5] Converting to template..."
qm template "$TEMPLATE_ID"

echo ""
echo "✅ Done! Template '$TEMPLATE_NAME' (ID: $TEMPLATE_ID) is ready."
echo ""
echo "In your terraform.tfvars set:"
echo "  template_name = \"$TEMPLATE_NAME\""
