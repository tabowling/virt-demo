#!/usr/bin/bash

#source this file to ease setting ENV VARs

#  source 1-config.sh

#RHPASS=""

#**  set these manually **
DEMOSEAT=1
SATSERV="sat6demo${DEMOSEAT}"
#DOMNAME=$SATSERV
#DOMNAME="client${DEMOSEAT}"

if [ "$DEMOSEAT" == "" ]
then
        echo "You need to set and export DEMOSEAT and DOMNAME env variable."
        exit 1;
fi
if [ "$DOMNAME" == "" ]
then
        echo "You need to set and export DEMOSEAT and DOMNAME env variable."
        exit 1;
fi


#VMPATH=/share/VirtualMachines
#ISOPATH=/share/ISO
#VMPATH=/home/tbowling/VirtualMachines
#ISOPATH=/home/tbowling/Downloads/ISOS

MAC=SetMAC
VMPATH=/home/VirtualMachines
#VMPATH=/var/lib/libvirt/images
ISOPATH=$VMPATH/ISOs
TEMPLATE=$ISOPATH/rhel-guest-image-7.2-20160302.0.x86_64.qcow2
ISOIMG=$ISOPATH/RHEL-7.2-20151030.0-Server-x86_64-dvd1.iso

KS=./7ks.cfg

OCTET="${DEMOSEAT}${DEMOSEAT}"
VIRSHNETNAME=SATLAB${OCTET}
VIRBR=virbr$OCTET

#PUBRSA=`cat /root/.ssh/id_rsa.pub`

#cat >> $KS << _EOF_
#echo "$PUBRSA" >> /root/.ssh/authorized_keys 
#
#%end
#
#_EOF_

for i in DOMNAME MAC VMPATH ISOPATH  KS TEMPLATE OCTET VIRSHNETNAME VIRBR PUBRSA; do \
	export $i;
done;

#./1.2-modks.sh

echo $DOMNAME
echo $SATSERV
echo $VMPATH
echo $ISOPATH
echo $TEMPLATE
echo $KS
echo $MAC
echo $PUBRSA

#echo Do not forget to set RHPASS!!!!



serverMac="52:54:00:b3:$OCTET:1a"
client1Mac="52:54:00:b3:$OCTET:1b"
client2Mac="52:54:00:b3:$OCTET:1c"
client3Mac="52:54:00:b3:$OCTET:1d"
client4Mac="52:54:00:b3:$OCTET:1e"
client5Mac="52:54:00:b3:$OCTET:1f"
client6Mac="52:54:00:b3:$OCTET:2a"
client7Mac="52:54:00:b3:$OCTET:2b"
client8Mac="52:54:00:b3:$OCTET:2c"
client9Mac="52:54:00:b3:$OCTET:2d"

