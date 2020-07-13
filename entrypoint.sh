#!/bin/bash

# Get IP addr
MY_IP=$(/ipxe/utils/get-ip)
echo $MY_IP


# Find and replace value in file
sed -i "s/<IP_ADDRESS>/${MY_IP}/g" /ipxe/boot/boot.ipxe


# Embed script into ipxe
cd /ipxe/src && \
make bin/ipxe.pxe bin/undionly.kpxe bin-x86_64-efi/ipxe.efi EMBED=/ipxe/boot/boot.ipxe #DEBUG=open,tcp,bnxt,bnx2,pci,netdevice

echo Running: pixiecore "$@"
exec /ipxe/pixiecore $@