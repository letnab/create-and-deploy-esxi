#!/bin/bash
yum install epel-release -y ;
yum -y install open-vm-tools  python-ldap ; 
yum install -y https://github.com/vmware/cloud-init-vmware-guestinfo/releases/download/v1.1.0/cloud-init-vmware-guestinfo-1.1.0-1.el7.noarch.rpm ; 
cloud-init clean;

# Force logs rotate and remove old logs
/usr/sbin/logrotate -f /etc/logrotate.conf
/bin/rm -f /var/log/*-???????? /var/log/*.gz
/bin/rm -f /var/log/dmesg.old
/bin/rm -rf /var/log/anaconda

# Truncate the audit logs
/bin/cat /dev/null > /var/log/audit/audit.log
/bin/cat /dev/null > /var/log/wtmp
/bin/cat /dev/null > /var/log/lastlog
/bin/cat /dev/null > /var/log/grubby

# Remove udev persistent rules
/bin/rm -f /etc/udev/rules.d/70*

# Remove mac address and uuids from any interface
/bin/sed -i '/^(HWADDR|UUID)=/d' /etc/sysconfig/network-scripts/ifcfg-*

# Clean /tmp
/bin/rm -rf /tmp/*
/bin/rm -rf /var/tmp/*

# Remove ssh keys
/bin/rm -f /etc/ssh/*key*

# Remove root's SSH history and other cruft
/bin/rm -rf ~root/.ssh/
/bin/rm -f ~root/anaconda-ks.cfg

# Remove root's and users history
/bin/rm -f ~root/.bash_history
/bin/rm -f /home/*/.bash_history
unset HISTFILE
