#cloud-config

users:
  - name: admin
    sudo: ALL=(ALL) NOPASSWD:ALL
    ssh_import_id: None
    lock_passwd: true
    ssh_authorized_keys:
      - ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAyxXkYdu/5QF6BJZw8+xUb1Pr3h98T3WO9Mtxb1e4Sq+Og0zhOfp5fjvReTnzv/seQrcAw+5NMoJEA74XEw7fsPiNDBukO9cCdcOC7NGZPyfA09Llq3Ut62HJSGWUtYKOiHHe5ZxkryGIear0VXKZ4ZCfmNjqODCdVjvRC+HBSgxvp062EquETeNozKVbUmA4r8QGFI/CnlGyotnlSSftkA4ioT893TAl/vMAkauQk1XGYWD4pO2LdG64rYwidwb4GzWPMxH2wlBw3bNrU4uSUvfURBXEN2+ZyMMK7AMpoKEHvgDeJXPptqFEYfneqFv9353D62rAAF8JVRDezAuMZQ== root@ibmserv
