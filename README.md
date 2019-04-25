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

# Build
```sh
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
