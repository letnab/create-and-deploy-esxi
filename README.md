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
centos 7 x86_64 minimal (selinux disabled)
yum install unzip git -y
curl -O https://releases.hashicorp.com/packer/1.3.5/packer_1.3.5_linux_amd64.zip
unzip packer_1.3.5_linux_amd64.zip -d /usr/bin && rm -rf packer_1.3.5_linux_amd64.zip
packer version
Packer v1.3.5
```
### Troubleshooting
>On some RedHat-based Linux distributions there is another tool named packer installed by default. You can check for this >using which -a packer. If you get an error like this it indicates there is a name conflict.
```sh
which -a packer
/usr/sbin/packer
```
>To fix this, you can create a symlink to packer that uses a different name like packer.io, or invoke the packer binary you >want using its absolute path, e.g. /usr/bin/packer.
### Download and install ovftool https://www.vmware.com/support/developer/ovf/
```sh
install ovftoos
chmod +x VMware-ovftool-4.3.0-7948156-lin.x86_64.bundle
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
#### If successful, in the output-packer-centos-7-x86_64/ folder.ova/ will be ova file, packer-centos-7-x86_64.ova
### 2) Provider preparation and build for ESXI
#### Download terraform
```sh
curl -O https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
unzip terraform_0.11.13_linux_amd64.zip -d /usr/bin/ && rm terraform_0.11.13_linux_amd64.zip
terraform version
Terraform v0.11.13
```
#### Install golang
```sh
cd /tmp
curl -O https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.10.3.linux-amd64.tar.gz && rm -rf go1.10.3.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version
go version go1.10.3 linux/amd64
```
#### Build provider from ESXi
```sh
go get -u -v golang.org/x/crypto/ssh
go get -u -v github.com/hashicorp/terraform
go get -u -v github.com/josenk/terraform-provider-esxi
export GOPATH="$HOME/go"
cd $GOPATH/src/github.com/josenk/terraform-provider-esxi
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -ldflags '-w -extldflags "-static"' -o terraform-provider-esxi_`cat version`
cp terraform-provider-esxi_`cat version` /usr/bin
```
### Usage
```sh
cd /root/create-and-deploy-esxi/centos7
change metadata
sed -i -e '2d' -e '3i "network": "'$(gzip < network_config.cfg| base64 | tr -d '\n')'",' metadata.json
terraform init
Initializing provider plugins...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.esxi: version = "~> 1.4"
* provider.template: version = "~> 2.1"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

terraform plan
 
terraforn apply
```
#### if everything is configured correctly, the virtual machine will be deployed on the esxi host in 2-3 minutes
