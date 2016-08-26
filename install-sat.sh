source 1-config.sh
cat >> /etc/hosts  << _EOF_
192.168.$OCTET.200  $SATSERV.example$OCTET.com $SATSERV

_EOF_

# You will need to create an ssh key for the root user on the satellite to connect to your 
# virtualization host if you would like to have the ability to provision VM's from within satellite.. 
/usr/bin/ssh-keygen -qt rsa -f /root/.ssh/id_rsa -N "" 
/usr/bin/ssh-keyscan 192.168.${OCTET}.1 


echo "setting up firewalld"
yum -y install firewalld
systemctl start firewalld.service  
systemctl enable firewalld.service  
firewall-cmd --permanent --add-service=RH-Satellite-6 --add-service=dns --add-service=dhcp --add-service=tftp --add-service=http --add-service=https 
firewall-cmd --permanent --add-port="5674/tcp" 
firewall-cmd --reload  

echo "Setting up env vars"
cat >> /root/.bashrc <<EOF
export DEMOSEAT=$DEMOSEAT
export SATSERV=$SATSERV
export DOMAIN=example${OCTET}.com
export ORG=example${OCTET}
export LOC=Indianapolis
EOF

#echo "Setting up internal repos"
cat > /etc/yum.repos.d/internal.repo <<EOF
[sat62]  
name=Satellite 6.2  
baseurl=http://pulp-read.dist.prod.ext.phx2.redhat.com/content/beta/rhel/server/7/x86_64/satellite/6/os/  
enabled=1  
gpgcheck=0  
  
[RHEL]  
name=Red Hat Enterprise Linux  
baseurl=http://pulp-read.dist.prod.ext.phx2.redhat.com/content/dist/rhel/server/7/7Server/x86_64/os/  
enabled=1  
gpgcheck=0  
  
[RHSCL]  
name=Red Hat Enterprise Linux  
baseurl=http://pulp-read.dist.prod.ext.phx2.redhat.com/content/dist/rhel/server/7/7Server/x86_64/rhscl/1/os/  
enabled=1  
gpgcheck=0  
EOF

#echo "doing Satellite install"
#read -n1 -r -p "Press any key to continue."
#yum -y update
#yum -y groupinstall "Server with GUI"
#yum -y install satellite
#echo $(hostname -I) $(hostname) $(hostname -s) >> /etc/hosts

su - foreman -s /bin/bash -c '/usr/bin/ssh-keygen -qt rsa -f /usr/share/foreman/.ssh/id_rsa -C "foreman@sat6demo$(hostname -s)" -N "" '
su - foreman -s /bin/bash -c "ssh-keyscan 192.168.${OCTET}.1 >> /usr/share/foreman/.ssh/known_hosts"

echo
echo "Complete.  Please execute the following commands from your HYPERVISOR to copy ssh keypairs."
echo "ssh sat6demo$DEMOSEAT  "cat /root/.ssh/id_rsa.pub" >> /root/.ssh/authorized_keys"
echo "ssh sat6demo$DEMOSEAT  "cat /usr/share/foreman/.ssh/id_rsa.pub" >> /root/.ssh/authorized_keys"
echo



