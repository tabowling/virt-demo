#!/usr/bin/bash
source 1-config.sh

read -d '' MYHOSTS <<  _EOF_

192.168.$OCTET.200  $SATSERV.example$OCTET.com $SATSERV
192.168.$OCTET.101  client1.example$OCTET.com
192.168.$OCTET.102  client2.example$OCTET.com
192.168.$OCTET.103  client3.example$OCTET.com
192.168.$OCTET.104  client4.example$OCTET.com
192.168.$OCTET.105  client5.example$OCTET.com
192.168.$OCTET.106  client6.example$OCTET.com
192.168.$OCTET.107  client7.example$OCTET.com
192.168.$OCTET.108  client8.example$OCTET.com
192.168.$OCTET.109  client9.example$OCTET.com

_EOF_

# hypervisor hosts file
echo "$MYHOSTS" >> /etc/hosts

PUBRSA=`cat /root/.ssh/id_rsa.pub`

# add to kickstart %post section
cat >> $KS << _EOF_

%post --log=/root/ks-post.log
/usr/bin/ssh-keygen  -qt rsa -N "" -f /root/.ssh/id_rsa
echo "$PUBRSA" >> /root/.ssh/authorized_keys 

echo "192.168.$OCTET.200  $SATSERV.example$OCTET.com $SATSERV" >> /etc/hosts
echo "192.168.$OCTET.101  client1.example$OCTET.com" >> /etc/hosts
echo "192.168.$OCTET.102  client2.example$OCTET.com" >> /etc/hosts
echo "192.168.$OCTET.103  client3.example$OCTET.com" >> /etc/hosts
echo "192.168.$OCTET.104  client4.example$OCTET.com" >> /etc/hosts
echo "192.168.$OCTET.105  client5.example$OCTET.com" >> /etc/hosts
echo "192.168.$OCTET.106  client6.example$OCTET.com" >> /etc/hosts
echo "192.168.$OCTET.107  client7.example$OCTET.com" >> /etc/hosts
echo "192.168.$OCTET.108  client8.example$OCTET.com" >> /etc/hosts
echo "192.168.$OCTET.109  client9.example$OCTET.com" >> /etc/hosts

/usr/sbin/subscription-manager register  --username=$RHNUSER --password $RHNPASS
/usr/sbin/subscription-manager attach --pool=$RHNPOOL
/usr/sbin/subscription-manager repos --disable=rh*
/usr/sbin/subscription-manager repos  \
        --enable=rhel-7-server-rpms \
        --enable=rhel-7-server-eus-rpms \
        --enable=rhel-7-server-extras-rpms \
        --enable=rhel-7-server-optional-rpms 

yum -y update 

%end

_EOF_


