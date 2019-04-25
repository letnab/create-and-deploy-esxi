# create-and-deploy-esxi
Creating an image using Packer and deploying to an esxi server using Terraform
## Build for CentOS VMs on ESXI.
### 1)  Configure ESXI server
First, configure the ESXI host to allow Packer to find IP addresses of VMs:
```sh
esxcli system settings advanced set -o /Net/GuestIPHack -i 1
```
Next, open VNC ports on the ESXI host firewall:
```sh
chmod 644 /etc/vmware/firewall/service.xml
chmod +t /etc/vmware/firewall/service.xml
vi /etc/vmware/firewall/service.xml
```
Add this to bottom of the file (above ):
```sh
<service id="1000">
  <id>packer-vnc</id>
  <rule id="0000">
    <direction>inbound</direction>
    <protocol>tcp</protocol>
    <porttype>dst</porttype>
    <port>
      <begin>5900</begin>
      <end>6000</end>
    </port>
  </rule>
  <enabled>true</enabled>
  <required>true</required>
</service>
```
Reload the firewall:
```sh
chmod 444 /etc/vmware/firewall/service.xml
esxcli network firewall refresh
```
For the ISO, either add it to the ./iso directory or let Packer pull it remotely.

### Virtual machine where the build and deployment will take place
```sh
centos 7 x86_64 minimal
yum install unzip git -y
curl -O https://releases.hashicorp.com/packer/1.4.0/packer_1.4.0_linux_amd64.zip
unzip packer_1.4.0_linux_amd64.zip -d /usr/bin && rm -rf packer_1.4.0_linux_amd64.zip
packer version
Packer v1.4.0
```
### Download and install ovftool https://www.vmware.com/support/developer/ovf/
```sh
install ovftoos
./VMware-ovftool-4.3.0-7948156-lin.x86_64.bundle
Extracting VMware Installer...done.
You must accept the VMware OVF Tool component for Linux End User
License Agreement to continue.  Press Enter to proceed.
VMWARE END USER LICENSE AGREEMENT
Do you agree? [yes/no]:yes
The product is ready to be installed.  Press Enter to begin
installation or Ctrl-C to cancel. 
Installing VMware OVF Tool component for Linux 4.3.0
    Configuring...
[######################################################################] 100%
Installation was successful.
```
### Troubleshooting
>On some RedHat-based Linux distributions there is another tool named packer installed by default. You can check for this >using which -a packer. If you get an error like this it indicates there is a name conflict.
```sh
which -a packer
/usr/sbin/packer
```
>To fix this, you can create a symlink to packer that uses a different name like packer.io, or invoke the packer binary you >want using its absolute path, e.g. /usr/bin/packer.

# Build
```sh
git clone https://github.com/letnab/create-and-deploy-esxi.git && cd create-and-deploy-esxi
packer build centos-7-base.json
```
If for some reason it does not work, you need to replace
```sh
centos-7-base.json
- "boot_command": [
-        "<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/floppy/centos7.ks<enter><wait>"
-      ]
      
+       "boot_command": [
+            "<tab> text biosdevname=0 net.ifnames=0 ks=hd:fd0:/centos7.ks<enter><wait>"
+        ],
+        "floppy_files": [
+          "floppy/centos7.ks"
+        ]
```
#### If successful, in the packer-centos-7-x86_64/packer-centos-7-x86_64 folder.ova/ will be ova file, packer-centos-7-x86_64.ova
