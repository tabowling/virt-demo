# Here we create the meta-data and user-data files for cloud-init,
# generate the iso, and copy it to $VMPATH
#
source 1-config.sh

if [ "$RHPASS" == "" ]
then
	echo "You need to set and export RHPASS env variable."
	exit 1;
fi	

PUBRSA=`cat ~/.ssh/id_rsa.pub`
echo $PUBRSA

# Create meta-data for cloud-init
cat > meta-data << _EOF_
instance-id: $DOMNAME
local-hostname: ${DOMNAME}.example.com
_EOF_


# Create user-data for cloud-init
#    sudo: ["ALL=(ALL) ALL:ALL"]
cat > user-data << _EOF_
#cloud-config
users: 
  - default
  - name: cloud-user
    chpasswd: {expire: True}
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    groups: wheel,adm,systemd-journal
    ssh_pwauth: True
    ssh_authorized_keys:
      - $PUBRSA
  - name: root
    chpasswd: {expire: True}
    ssh_pwauth: True
    ssh_authorized_keys:
      - $PUBRSA
chpasswd: 
  list: |
    root:$RHPASS
    cloud-user:$RHPASS
  expire: False

write_files:
  - path: /etc/systemd/system/cockpitws.service
    permissions: '0644'
    owner: root:root
    encoding: b64
    content: $PUBRSA


# package_upgrade: true
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
runcmd:
  - systemctl daemon-reload
  - systemctl enable cockpitws.service
_EOF_

# Create the image and move into place
genisoimage -output ${DOMNAME}-cloudinit.iso -volid cidata -joliet -rock user-data meta-data

sudo mv ${DOMNAME}-cloudinit.iso $VMPATH/
