#!/usr/bin/bash

# see 1-config.sh for 2 digit number for unique virshnet class C domain and MAC id 

# Copy from our $TEMPLATE RHEL image
# Create $DOMNAME, using the cloud-init.iso to configure it.
source 1-config.sh
DATADISK=""

case $DOMNAME in 
	server)         
		MAC=$serverMac;
		RAM=" --ram 8192 ";
		VCPUS=" --vcpus 4";
		;;
	sat6demo[1-9])
		MAC=$serverMac
		RAM=" --ram 13000 "
		VCPUS=" --vcpus 6"

                echo "Creating $DOMNAME disk"
                sudo qemu-img create -f qcow2 -b $TEMPLATE $VMPATH/${DOMNAME}.qcow2 120G

                ## cloud-init version
                sudo virt-install -v \
                --name $DOMNAME $RAM $VCPUS \
                --disk bus=virtio,path=$VMPATH/${DOMNAME}.qcow2    $DATADISK \
                --disk device=cdrom,path=$ISOPATH/${DOMNAME}-cloudinit.iso \
                -w network=${VIRSHNETNAME},model=virtio,mac=$MAC \
                --graphics spice \
                --noautoconsole

#               sudo qemu-img create -f qcow2 $VMPATH/${DOMNAME}.qcow2 120G
#
#               # DATADISK="--disk bus=virtio,path=$VMPATH/${DOMNAME}-data.qcow2"
#               sudo virt-install -v \
#               --name $DOMNAME $RAM $VCPUS \
#               --disk bus=virtio,path=$VMPATH/${DOMNAME}.qcow2    $DATADISK \
#               -w network=${VIRSHNETNAME},model=virtio,mac=$MAC \
#               --graphics spice \
#               -l $ISOIMG \
#               --initrd-inject=$KS \
#               --extra-args="ks=file:/7ks.cfg" \
#               --noautoconsole 
		exit 1
		;;
	template)         
		MAC=$serverMac
		RAM=" --ram 1024 "
		VCPUS=" --vcpus 1"
		;;
	client[1-9])        
		MAC=$client1Mac
		RAM=" --ram 1024 "
		VCPUS=" --vcpus 1"
		;;
	*)
		MAC=SetMAC
		echo $MAC
		exit 1
esac

#create a thin provisioned QCOW2 image file for the base image
echo "Creating $DOMNAME disk"
sudo qemu-img create -f qcow2 -b $TEMPLATE $VMPATH/${DOMNAME}.qcow2

## cloud-init version
sudo virt-install -v \
--name $DOMNAME $RAM $VCPUS \
--disk bus=virtio,path=$VMPATH/${DOMNAME}.qcow2    $DATADISK \
--disk device=cdrom,path=$ISOPATH/${DOMNAME}-cloudinit.iso \
-w network=${VIRSHNETNAME},model=virtio,mac=$MAC \
--graphics spice \
--noautoconsole 





