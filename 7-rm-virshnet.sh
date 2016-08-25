#!/usr/bin/bash
source 1-config.sh

echo "Octet $OCTET"
echo "$VIRSHNETNAME"

#  Stop and delete the virt net
 virsh net-list --all
 virsh net-destroy ${VIRSHNETNAME}
 virsh net-undefine ${VIRSHNETNAME}
 virsh net-list --all

