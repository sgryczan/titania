#!/bin/bash

# Embed script into ipxe
cd /ipxe/src && \
make bin/ipxe.pxe bin/undionly.kpxe bin-x86_64-efi/ipxe.efi EMBED=/ipxe/boot/boot.ipxe