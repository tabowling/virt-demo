#!/usr/bin/bash

#source this file to ease setting ENV VARs
DEMOSEAT=$1
DOMTYPE=$2

if [ -n "$1" ]; then
        echo "You have specified DEMOSEAT $1."
        export DEMOSEAT=$1
	export SATSERV="sat6demo${DEMOSEAT}"

elif [ -e "/root/virt_demo/demo_env.sh" ]; then
        echo "Using DEMOSEAT $DEMOSEAT from demo_env.sh."
        source ./demo_env.sh
else
        echo "You must provide DEMOSEAT env variable."
        echo "./1-config.sh   X  DOMTYPE"
        echo 'Where X is your demoseat number and DOMTYPE is "sat" or "client"'
        exit 1;
fi


export OCTET="${DEMOSEAT}${DEMOSEAT}"
export VIRSHNETNAME=SATLAB${OCTET}
export VIRBR=virbr$OCTET
export RHPASS="redhat"
export PUBRSA=`cat ~/.ssh/id_rsa.pub`


if [ "$2" == "sat" ]; then
	export DOMNAME=$SATSERV
elif [ "$2" == "client" ]; then
	export DOMNAME="client${DEMOSEAT}"
else 
        echo "You did not specify DOMTYPE, assuming client."
	export DOMNAME="client${DEMOSEAT}"
fi


echo "Saving env vars"
cat > ./demo_env.sh <<_EOF_
    export DEMOSEAT=$DEMOSEAT
    export SATSERV=$SATSERV
    export DOMAIN=example${OCTET}.com
    export ORG=example${OCTET}
    export LOC=Indianapolis
_EOF_

#export VMPATH=/share/VirtualMachines
#export ISOPATH=/share/ISO
#export VMPATH=/home/tbowling/VirtualMachines
#export ISOPATH=/home/tbowling/Downloads/ISOS
#export VMPATH=/var/lib/libvirt/images

export MAC=SetMAC
export VMPATH=/home/VirtualMachines
export ISOPATH=$VMPATH/ISOs
export TEMPLATE=$ISOPATH/rhel-guest-image-7.2-20160302.0.x86_64.qcow2
export ISOIMG=$ISOPATH/RHEL-7.2-20151030.0-Server-x86_64-dvd1.iso
export KS=./7ks.cfg



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

echo $DEMOSEAT
echo $DOMNAME
echo $SATSERV
#echo $VMPATH
#echo $ISOPATH
#echo $TEMPLATE
#echo $KS
#echo $MAC
#echo $PUBRSA

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

