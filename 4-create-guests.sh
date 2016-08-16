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
	SAT6demo[1-9])
		MAC=$serverMac
		RAM=" --ram 13000 "
		VCPUS=" --vcpus 6"

                echo "Creating $DOMNAME disk"
                sudo qemu-img create -f qcow2 -b $TEMPLATE $VMPATH/${DOMNAME}.qcow2 120G

                ## cloud-init version
                sudo virt-install -v \
                --name $DOMNAME $RAM $VCPUS \
                --disk bus=virtio,path=$VMPATH/${DOMNAME}.qcow2    $DATADISK \
                --disk device=cdrom,path=$VMPATH/${DOMNAME}-cloudinit.iso \
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
	client1)        
		MAC=$client1Mac
		RAM=" --ram 1024 "
		VCPUS=" --vcpus 1"
		;;
	client2)       
		MAC=$client2Mac
		RAM=" --ram 1024 "
		VCPUS=" --vcpus 1"
		;;
	client3)       
		MAC=$client3Mac
		RAM=" --ram 1024 "
		VCPUS=" --vcpus 1"
		;;
	client4)       
		MAC=$client4Mac
		RAM=" --ram 1024 "
		VCPUS=" --vcpus 1"
		;;
	client5)       
		MAC=$client5Mac
		RAM=" --ram 1024 "
		VCPUS=" --vcpus 1"
		;;
	client6)       
		MAC=$client6Mac
		RAM=" --ram 1024 "
		VCPUS=" --vcpus 1"
		;;
	client7)       
		MAC=$client7Mac
		RAM=" --ram 1024 "
		VCPUS=" --vcpus 1"
		;;
	client8)       
		MAC=$client8Mac
		RAM=" --ram 1024 "
		VCPUS=" --vcpus 1"
		;;
	client9)       
		MAC=$client9Mac
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
--disk device=cdrom,path=$VMPATH/${DOMNAME}-cloudinit.iso \
-w network=${VIRSHNETNAME},model=virtio,mac=$MAC \
--graphics spice \
--noautoconsole 





