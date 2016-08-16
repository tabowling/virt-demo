#!/usr/bin/bash

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

# add to kickstart %post section
cat >> $KS << _EOF_
PUBRSA=`cat /root/.ssh/id_rsa.pub`
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

%end

_EOF_


