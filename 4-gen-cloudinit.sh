# Here we create the meta-data and user-data files for cloud-init,
# generate the iso, and copy it to $VMPATH
#
source 1-config.sh

if [ "$RHPASS" == "" ]
then
	echo "You need to set and export RHPASS env variable."
	exit 1;
fi	

# grab hypervisor root user's ssh key to insert
PUBRSA=`cat ~/.ssh/id_rsa.pub`
echo $PUBRSA
echo $PWD
FOREMAN_RSA=`cat foreman.id_rsa`
FOREMAN_PUB=`cat foreman.id_rsa.pub`

FOREMAN_KEY_SETUP=""
if [ "$DOMNAME" == "sat6demo[1-9]" ]
then 
	# pregenerate foreman keys  /usr/bin/ssh-keygen -qt rsa -f ./foreman.id_rsa -C "foreman@${SATSERV}" -N ""
	cat foreman.id_rsa.pub >> /root/.ssh/known_hosts;
#	FOREMAN_RSA=`cat ./foreman.id_rsa`;
#	FOREMAN_PUB=`cat ./foreman.id_rsa.pub`;
	#FORMAN_KEY_SETUP="  - mkdir -p /usr/share/foreman/.ssh/;  - echo $FOREMAN_RSA > /usr/share/foreman/.ssh/id_rsa;  - echo $FOREMAN_PUB > /usr/share/foreman/.ssh/id_rsa.pub;";
	#echo $FOREMAN_KEY_SETUP";
fi


# Create meta-data for cloud-init
cat > meta-data << _EOF_
instance-id: $DOMNAME
local-hostname: ${DOMNAME}.example${OCTET}.com
_EOF_


# Create user-data for cloud-init
#    sudo: ["ALL=(ALL) ALL:ALL"]
cat > user-data << _EOF_
#cloud-config
users:
  - default
  - name: cloud-user
    chpasswd: {expire: False}
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    groups: users,wheel,adm,systemd-journal
    ssh_pwauth: True
    ssh_authorized_keys:
      - $PUBRSA
  - name: root
    ssh_pwauth: True
    ssh_authorized_keys:
      - $PUBRSA
chpasswd:
  list: |
    root:redhat
    cloud-user:redhat
  expire: False
rh_subscription:
  username: $RHNUSER
  password: $RHNPASS
  add-pool:
    - 8a85f9833e1404a9013e3cddf95a0599
    - 8a85f981501430fe015019593a930646
  disable-repo:
    - '*'
  enable-repo:
    - rhel-7-server-rpms
    - rhel-server-rhscl-7-rpms
    - rhel-7-server-satellite-6.2-rpms
runcmd:
  - subscription-manager repos --disable=*
  - subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-server-rhscl-7-rpms --enable=rhel-7-server-satellite-6.2-rpms
  - yum -y install firewalld
  - systemctl start firewalld.service
  - systemctl enable firewalld.service
  - firewall-cmd --permanent --add-service=RH-Satellite-6 --add-service=dns --add-service=dhcp --add-service=tftp --add-service=http --add-service=https && firewall-cmd --permanent --add-port="5674/tcp" && firewall-cmd --reload
  - yum -y install satellite
  - yum -y groupinstall "Server with GUI"
  - echo $FOREMAN_RSA > /usr/share/foreman/.ssh/id_rsa
  - echo $FOREMAN_PUB > /usr/share/foreman/.ssh/id_rsa.pub

_EOF_

# Create the image and move into place
genisoimage -output ${DOMNAME}-cloudinit.iso -volid cidata -joliet -rock user-data meta-data

mv ${DOMNAME}-cloudinit.iso $ISOPATH/

ls -lh $ISOPATH/



