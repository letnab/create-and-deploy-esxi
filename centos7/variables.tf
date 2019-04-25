variable "esxi_hostname" {
  default = "10.10.0.10"
}
variable "esxi_hostport" {
  default = "22"
}
variable "esxi_username" {
  default = "root"
}
variable "esxi_password" {
  default = "passwd-to-esxi-server"
}

variable "virtual_network"    {
  default = "VM Network"
}
variable "disk_store"    {
  default = "datastore1"
}

variable "vm_hostname"   {
  default = "centos7-test"
}
