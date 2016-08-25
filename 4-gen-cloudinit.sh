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
  service-level: self-support
  add-pool 8a85f9833e1404a9013e3cddf95a0599
  add-pool 8a85f981501430fe015019593a930646
packages:
  - git
  - screen
  - vim-enhanced
  - redhat-support-tool
  - pcp
  - sos
  - chrony
  - kexec-tools
  - abrt-addon-kerneloops
  - abrt-addon-ccpp
  - abrt-cli
  - spice-vdagent
  - openssh-clients
  - wget

_EOF_

# rh_subscription
#  auto-attach: True

# Create the image and move into place
genisoimage -output ${DOMNAME}-cloudinit.iso -volid cidata -joliet -rock user-data meta-data

sudo mv ${DOMNAME}-cloudinit.iso $ISOPATH/

ls -lh $ISOPATH/



