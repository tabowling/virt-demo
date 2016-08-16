#!/usr/bin/bash
#source 1-config.sh

echo Destroying and deleting $DOMNAME
echo Images for $DOMNAME before delete:
sudo ls -lh $VMPATH | grep -i $DOMNAME

sudo virsh destroy $DOMNAME
sudo virsh undefine $DOMNAME
sudo rm $VMPATH/${DOMNAME}-cloudinit.iso
sudo rm $VMPATH/${DOMNAME}.qcow2
sudo rm $VMPATH/${DOMNAME}-data.qcow2
sudo virsh list --all

echo Images for $DOMNAME after delete:
sudo ls -lh $VMPATH | grep -i $DOMNAME

