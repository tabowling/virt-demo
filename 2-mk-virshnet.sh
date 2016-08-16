#!/usr/bin/bash
source 1-config.sh

echo "Octet $OCTET"
cat > ${VIRSHNETNAME}.xml << _EOF_

<network>
  <name>$VIRSHNETNAME</name>
  <uuid>27221f2f-003d-4ce5-ac06-d954394689$OCTET </uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='$VIRBR' stp='on' delay='0'/>
  <domain name='example.com'/>
  <dns>
    <host ip='192.168.$OCTET.200'>
      <hostname>server.example.com</hostname>
    </host>
    <host ip='192.168.$OCTET.101'>
      <hostname>client1.example.com</hostname>
    </host>
    <host ip='192.168.$OCTET.102'>
      <hostname>client2.example.com</hostname>
    </host>
    <host ip='192.168.$OCTET.103'>
      <hostname>client3.example.com</hostname>
    </host>
    <host ip='192.168.$OCTET.104'>
      <hostname>client4.example.com</hostname>
    </host>
    <host ip='192.168.$OCTET.105'>
      <hostname>client5.example.com</hostname>
    </host>
    <host ip='192.168.$OCTET.106'>
      <hostname>client6.example.com</hostname>
    </host>
    <host ip='192.168.$OCTET.107'>
      <hostname>client7.example.com</hostname>
    </host>
    <host ip='192.168.$OCTET.108'>
      <hostname>client8.example.com</hostname>
    </host>
    <host ip='192.168.$OCTET.109'>
      <hostname>client9.example.com</hostname>
    </host>
  </dns>
  <ip address='192.168.$OCTET.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.$OCTET.2' end='192.168.$OCTET.254'/>
      <host mac='52:54:00:b3:$OCTET:1a' name='$SATSERV.example$OCTET.com' ip='192.168.$OCTET.200'/>
      <host mac='52:54:00:b3:$OCTET:1c' name='client1.example$OCTET.com'  ip='192.168.$OCTET.101'/>
      <host mac='52:54:00:b3:$OCTET:1d' name='client2.example$OCTET.com'  ip='192.168.$OCTET.102'/>
      <host mac='52:54:00:b3:$OCTET:1e' name='client3.example$OCTET.com'  ip='192.168.$OCTET.103'/>
      <host mac='52:54:00:b3:$OCTET:1f' name='client4.example$OCTET.com'  ip='192.168.$OCTET.104'/>
      <host mac='52:54:00:b3:$OCTET:2a' name='client5.example$OCTET.com'  ip='192.168.$OCTET.105'/>
      <host mac='52:54:00:b3:$OCTET:2b' name='client6.example$OCTET.com'  ip='192.168.$OCTET.106'/>
      <host mac='52:54:00:b3:$OCTET:2c' name='client7.example$OCTET.com'  ip='192.168.$OCTET.107'/>
      <host mac='52:54:00:b3:$OCTET:2d' name='client8.example$OCTET.com'  ip='192.168.$OCTET.108'/>
      <host mac='52:54:00:b3:$OCTET:2e' name='client9.example$OCTET.com'  ip='192.168.$OCTET.109'/>
    </dhcp>
  </ip>
</network>
_EOF_

cat >> /etc/hosts  << _EOF_

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


# make the virt net
 virsh net-define ${VIRSHNETNAME}.xml
 virsh net-start ${VIRSHNETNAME}
 virsh net-autostart ${VIRSHNETNAME}
 virsh net-list --all


#  Stop and delete the virt net
# virsh net-list --all
# virsh net-destroy ${VIRSHNETNAME}
# virsh net-undefine ${VIRSHNETNAME}

#
#
#
