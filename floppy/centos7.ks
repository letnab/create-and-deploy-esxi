#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
#graphical
text
# Run the Setup Agent on first boot
firstboot --enable
ignoredisk --only-use=sda
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=static --device=eth0 --gateway=10.10.0.254 --ip=10.10.0.22 --nameserver=10.10.0.254 --netmask=255.255.255.0 --ipv6=auto --activate
network  --hostname=cloud-vm

# Root password
rootpw --iscrypted $6$GL4F80.CKLU67lTu$Bwqq6BJ3YjltnpUVBhnN85K3aWQ0f130t0IHJloWUTnXHHjH36PamVvIdAcPEjoG3Obxu965BrdZleW7OX/4L1
# System services
services --disabled="chronyd"
# System timezone
timezone Europe/Moscow --isUtc --nontp
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=sda
autopart --type=lvm
# Partition clearing information
clearpart --none --initlabel

%packages
@^minimal
@core
kexec-tools

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

reboot
