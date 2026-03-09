TEMPLATE_ID=9000
STORAGE="local-lvm"
BRIDGE="vmbr0"
IMAGE_URL="https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
IMAGE_FILE="/tmp/ubuntu-22.04-cloud.img"

# Install tools
apt-get install -y --no-install-recommends libguestfs-tools wget

# Download image
wget -q --show-progress -O "$IMAGE_FILE" "$IMAGE_URL"

# Inject guest agent
virt-customize -a "$IMAGE_FILE" \
  --install qemu-guest-agent \
  --run-command "systemctl enable qemu-guest-agent" \
  --run-command "apt-get clean" \
  --truncate /etc/machine-id

# Create VM
qm create $TEMPLATE_ID --name "ubuntu-22.04-cloud" --memory 2048 --cores 2 --net0 virtio,bridge=$BRIDGE --ostype l26 --machine q35 --scsihw virtio-scsi-single --agent enabled=1

# Import disk
qm importdisk $TEMPLATE_ID "$IMAGE_FILE" $STORAGE
qm set $TEMPLATE_ID --scsi0 $STORAGE:vm-${TEMPLATE_ID}-disk-1,discard=on,iothread=1
qm set $TEMPLATE_ID --ide2 $STORAGE:cloudinit
qm set $TEMPLATE_ID --boot c --bootdisk scsi0
qm set $TEMPLATE_ID --serial0 socket --vga serial0

# Convert to template
qm template $TEMPLATE_ID

echo "Done!"