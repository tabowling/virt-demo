source /root/demo_env.sh


satellite-installer --scenario satellite \
--foreman-admin-password redhat \
--foreman-proxy-dns true \
--foreman-proxy-dns-interface eth0 \
--foreman-proxy-dns-zone $DOMAIN \
--foreman-proxy-dns-forwarders 192.168.${OCTET}.1 \
--foreman-proxy-dns-reverse ${OCTET}.168.192.in-addr.arpa \
--foreman-proxy-dhcp true \
--foreman-proxy-dhcp-interface eth0 \
--foreman-proxy-dhcp-range "192.168.${OCTET}.100 192.168.${OCTET}.150" \
--foreman-proxy-dhcp-gateway 192.168.${OCTET}.1 \
--foreman-proxy-dhcp-nameservers 192.168.${OCTET}.200 \
--foreman-proxy-tftp true \
--foreman-proxy-tftp-servername $(hostname) \
--capsule-puppet true \
--foreman-proxy-puppetca true \
--foreman-proxy-plugin-remote-execution-ssh-enabled true \
--enable-foreman-proxy-plugin-remote-execution-ssh \
--enable-foreman-plugin-discovery \
--foreman-initial-organization $ORG \
--foreman-initial-location $LOC

echo "Changing DNS to use Satellite instead of VM host"
#read -n1 -r -p "Press any key to continue."
nmcli c mod eth0 ipv4.dns $(hostname -I)

echo "Setting up hammer"
#read -n1 -r -p "Press any key to continue."
mkdir ~/.hammer
cat > ~/.hammer/cli_config.yml <<EOF
:foreman:
    :host: 'https://$(hostname)'
    :username: 'admin'
    :password: 'redhat'
EOF

echo "Uploading Manifest"
#read -n1 -r -p "Press any key to continue."
wget -O /root/Manifest.zip http://file.rdu.redhat.com/~rjerrido/manifests/Sat61_Field_Manifest_Generated_05May2016_2.zip
hammer subscription upload --organization "${ORG}" --file /root/Manifest.zip

echo "Enabling repos"
#read -n1 -r -p "Press any key to continue."
hammer repository-set enable --organization "${ORG}" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7Server' --name 'Red Hat Enterprise Linux 7 Server (RPMs)'
hammer repository-set enable --organization "${ORG}" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --releasever='7.2' --name 'Red Hat Enterprise Linux 7 Server (Kickstart)'
hammer repository-set enable --organization "${ORG}" --product 'Red Hat Enterprise Linux Server' --basearch='x86_64' --name 'Red Hat Satellite Tools 6.1 (for RHEL 7 Server) (RPMs)'

echo "Setting up Sync plan"
#read -n1 -r -p "Press any key to continue."
hammer sync-plan create --name 'Daily Sync' --description 'Daily Synchronization Plan' --organization "${ORG}" --interval daily --sync-date $(date +"%Y-%m-%d")" 00:00:00" --enabled yes
hammer product set-sync-plan --name 'Red Hat Enterprise Linux Server' --organization "${ORG}" --sync-plan 'Daily Sync'

echo "Starting initial Syncs - THIS WILL TAKE A WHILE - GO HOME FOR THE DAY"
#read -n1 -r -p "Press any key to continue."
hammer repository synchronize --organization "${ORG}" --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.2'
hammer repository synchronize --organization "${ORG}" --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'
hammer repository synchronize --organization "${ORG}" --product 'Red Hat Enterprise Linux Server'  --name  'Red Hat Satellite Tools 6.1 for RHEL 7 Server RPMs x86_64'

echo "Creating Lifecycle Environments"
hammer lifecycle-environment create --organization "${ORG}" --description 'Crash (Testing) Environment' --name 'Crash' --label crash --prior Library  
hammer lifecycle-environment create --organization "${ORG}" --description 'Development' --name 'Development' --label development --prior Crash  
hammer lifecycle-environment create --organization "${ORG}" --description 'Quality Assurance' --name 'Quality Assurance' --label quality_assurance --prior Development  
hammer lifecycle-environment create --organization "${ORG}" --description 'Staging' --name 'Staging' --label staging --prior 'Quality Assurance'  
hammer lifecycle-environment create --organization "${ORG}" --description 'Production' --name 'Production' --label production --prior 'Staging'  

echo "Creating Content Views"
  
hammer content-view create --organization "${ORG}" --name 'RHEL7_Base' --label rhel7_base --description 'Core Build for RHEL 7'    
hammer content-view add-repository --organization "${ORG}" --name 'RHEL7_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server RPMs x86_64 7Server'    
hammer content-view add-repository --organization "${ORG}" --name 'RHEL7_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Enterprise Linux 7 Server Kickstart x86_64 7.2'    
hammer content-view add-repository --organization "${ORG}" --name 'RHEL7_Base' --product 'Red Hat Enterprise Linux Server' --repository 'Red Hat Satellite Tools 6.1 for RHEL 7 Server RPMs x86_64'

echo "Publishing Content Views"
hammer content-view publish --name "RHEL7_Base" --description "RHEL 7 Base OS" --organization "${ORG}"
hammer content-view version promote --content-view "RHEL7_Base" --version 1 --to-lifecycle-environment "Crash" --organization "${ORG}"
hammer content-view version promote --content-view "RHEL7_Base" --version 1 --to-lifecycle-environment "Development" --organization "${ORG}"
hammer content-view version promote --content-view "RHEL7_Base" --version 1 --to-lifecycle-environment "Quality Assurance" --organization "${ORG}"
hammer content-view version promote --content-view "RHEL7_Base" --version 1 --to-lifecycle-environment "Staging" --organization "${ORG}"
hammer content-view version promote --content-view "RHEL7_Base" --version 1 --to-lifecycle-environment "Production" --organization "${ORG}"

echo "Creating Activation Keys"
RHEL_SUB_ID=$(hammer --csv --csv-separator ':' subscription list --organization "${ORG}" | grep 'Red Hat Enterprise Linux Server, Premium (1-2 sockets)' | head -n1 | cut -f 1 -d ':')

hammer activation-key create --organization "${ORG}" --description 'Basic RHEL7 Key for Registering to Crash' --content-view 'RHEL7_Base' --unlimited-hosts --name ak-Reg_To_Crash --lifecycle-environment 'Crash'  
hammer activation-key create --organization "${ORG}" --description 'Basic RHEL7 Key for Registering to Dev' --content-view 'RHEL7_Base' --unlimited-hosts --name ak-Reg_To_Dev --lifecycle-environment 'Development' 
hammer activation-key create --organization "${ORG}" --description 'Basic RHEL7 Key for Registering to Prod' --content-view 'RHEL7_Base' --unlimited-hosts --name ak-Reg_To_Prod --lifecycle-environment 'Production'
hammer activation-key create --organization "${ORG}" --description 'Basic RHEL7 Key for Registering to QA' --content-view 'RHEL7_Base' --unlimited-hosts --name ak-Reg_To_QA --lifecycle-environment 'Quality Assurance'
hammer activation-key create --organization "${ORG}" --description 'Basic RHEL7 Key for Registering to Stage' --content-view 'RHEL7_Base' --unlimited-hosts --name ak-Reg_To_Stage --lifecycle-environment 'Staging'

echo "Adding Subscriptions to Keys"
hammer activation-key add-subscription --organization "${ORG}" --name ak-Reg_To_Crash --subscription-id $RHEL_SUB_ID  
hammer activation-key add-subscription --organization "${ORG}" --name ak-Reg_To_Dev --subscription-id $RHEL_SUB_ID  
hammer activation-key add-subscription --organization "${ORG}" --name ak-Reg_To_QA --subscription-id $RHEL_SUB_ID  
hammer activation-key add-subscription --organization "${ORG}" --name ak-Reg_To_Stage --subscription-id $RHEL_SUB_ID  
hammer activation-key add-subscription --organization "${ORG}" --name ak-Reg_To_Prod --subscription-id $RHEL_SUB_ID  

echo "Updating Domain"
hammer domain update --name "${ORG}.com" --organizations "${ORG}" --dns $(hostname) --locations "${LOC}"

echo "Setting up network MAKE GUI CHANGE -  In the UI under infrastructure->capsules, select import subnets (Bug 1120805)"
read -n1 -r -p "Press any key to continue."

hammer subnet update --name "${ORG}" --dhcp-id 1 --dns-id 1 --tftp-id 1 --organizations "${ORG}" --domains "${ORG}.com" --locations "${LOC}"

echo "Creating Boot Medium"

hammer medium create --name "RHEL7" --path "https://sat6demo2.${ORG}.com/Library/Red_Hat_Server/Red_Hat_Enterprise_Linux_7_Server_Kickstart_x86_64_7_2"

echo "Setting up Host Groups"
hammer hostgroup create --architecture x86_64 --content-source-id 1 --content-view RHEL7_Base --domain "${ORG}.com" --lifecycle-environment Crash --locations "${LOC}" --name RHEL7_Crash_Servers --organization "${ORG}" --puppet-ca-proxy $(hostname) --subnet "${ORG}" --partition-table 'Kickstart default' --operatingsystem 'RedHat 7.2' --medium "RHEL7"
      
hammer hostgroup create --architecture x86_64 --content-source-id 1 --content-view RHEL7_Base --domain "${ORG}.com" --lifecycle-environment Development --locations "${LOC}" --name RHEL7_Development_Servers --organization "${ORG}" --puppet-proxy $(hostname) --subnet "${ORG}" --partition-table 'Kickstart default' --operatingsystem 'RedHat 7.2' --medium "RHEL7"
      
hammer hostgroup create --architecture x86_64 --content-source-id 1 --content-view RHEL7_Base --domain "${ORG}.com" --lifecycle-environment 'Quality Assurance' --locations "${LOC}" --name RHEL7_QA_Servers --organization "${ORG}" --puppet-proxy $(hostname) --subnet "${ORG}" --partition-table 'Kickstart default' --operatingsystem 'RedHat 7.2' --medium "RHEL7"
      
hammer hostgroup create --architecture x86_64 --content-source-id 1 --content-view RHEL7_Base --domain "${ORG}.com" --lifecycle-environment Staging --locations "${LOC}" --name RHEL7_Staging_Servers --organization "${ORG}" --puppet-ca-proxy $(hostname) --subnet "${ORG}" --partition-table 'Kickstart default' --operatingsystem 'RedHat 7.2' --medium "RHEL7" 
      
hammer hostgroup create --architecture x86_64 --content-source-id 1 --content-view RHEL7_Base --domain "${ORG}.com" --lifecycle-environment Production --locations "${LOC}" --name RHEL7_Production_Servers --organization "${ORG}" --puppet-ca-proxy $(hostname) --subnet "${ORG}" --partition-table 'Kickstart default' --operatingsystem 'RedHat 7.2' --medium "RHEL7"
      
echo "Creating Forman SSH Key"
su - foreman -s /bin/bash -c '/usr/bin/ssh-keygen -qt rsa -f /usr/share/foreman/.ssh/id_rsa -N ""'
scp /usr/share/foreman/.ssh/id_rsa.pub root@192.168.${OCTET}.1:/tmp/id_rsa_1.pub
ssh root@192.168.${OCTET}.1 'cat /tmp/id_rsa_1.pub >> /root/.ssh/authorized_keys'
touch /usr/share/foreman/.ssh/known_hosts
chmod 644 /usr/share/foreman/.ssh/known_hosts
chown foreman:foreman /usr/share/foreman/.ssh/known_hosts
su - foreman -s /bin/bash -c 'ssh-keyscan 192.168.${OCTET}.1 >> /usr/share/foreman/.ssh/known_hosts'

echo "Creating Compute Resource"
hammer compute-resource create --description 'LibVirt Compute Resource' --locations ${LOC} --name Libvirt_CR --organizations "${ORG}" --url 'qemu+ssh://root@192.168.${OCTET}.1/system/' --provider libvirt --set-console-password 0
firewall-cmd --add-port=5910-5930/tcp  
firewall-cmd --add-port=5910-5930/tcp --permanent  


