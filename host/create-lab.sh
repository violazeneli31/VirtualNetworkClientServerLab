#!/bin/bash
# Creates the NAT Network and both virtual machines in VirtualBox.
# Run it on YOUR computer (Mac or Linux), not inside a VM.
#
#   bash host/create-lab.sh  <ubuntu-server.iso>  <ubuntu-desktop.iso>
#
# Example:
#   bash host/create-lab.sh ~/Downloads/ubuntu-24.04.3-live-server-amd64.iso ~/Downloads/ubuntu-24.04.3-desktop-amd64.iso

SERVER_ISO="$1"
DESKTOP_ISO="$2"
if [ -z "$SERVER_ISO" ] || [ -z "$DESKTOP_ISO" ]; then
  echo "Usage: bash host/create-lab.sh <ubuntu-server.iso> <ubuntu-desktop.iso>"
  exit 1
fi

# 1. The NAT Network: 222.22.22.0/24 with DHCP
VBoxManage natnetwork add --netname group22_nat --network "222.22.22.0/24" --dhcp on
VBoxManage natnetwork start --netname group22_nat

# 2. One function that builds a VM: 4096 MB RAM, 2 CPUs, 25 GB disk, on group22_nat
make_vm() {
  NAME="$1"; ISO="$2"
  DISK="$HOME/VirtualBox VMs/$NAME/$NAME.vdi"
  VBoxManage createvm --name "$NAME" --ostype Ubuntu_64 --register
  VBoxManage modifyvm "$NAME" --memory 4096 --cpus 2 --vram 16 --graphicscontroller vmsvga \
                              --nic1 natnetwork --nat-network1 group22_nat
  VBoxManage createmedium disk --filename "$DISK" --size 25600
  VBoxManage storagectl "$NAME" --name SATA --add sata --controller IntelAhci
  VBoxManage storageattach "$NAME" --storagectl SATA --port 0 --device 0 --type hdd --medium "$DISK"
  VBoxManage storageattach "$NAME" --storagectl SATA --port 1 --device 0 --type dvddrive --medium "$ISO"
}

make_vm UbuntuServer  "$SERVER_ISO"
make_vm UbuntuDesktop "$DESKTOP_ISO"

# 3. Start both so you can install Ubuntu
VBoxManage startvm UbuntuServer
VBoxManage startvm UbuntuDesktop

echo
echo "Done. Install Ubuntu in both windows:"
echo "  UbuntuServer  -> server name: group22-02, username: group22"
echo "  UbuntuDesktop -> computer name: group22-01, username: group22"
