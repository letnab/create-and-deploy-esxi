provider "esxi" {
  esxi_hostname  = "${var.esxi_hostname}"
  esxi_hostport  = "${var.esxi_hostport}"
  esxi_username  = "${var.esxi_username}"
  esxi_password  = "${var.esxi_password}"
}

# Template for initial configuration bash script template_file is a great way to pass variables to cloud-init

data "template_file" "Default" {
  template = "${file("userdata.tpl")}"
}

data "template_file" "network_config" {
  template = "${file("metadata.json")}"
  vars = {
   HOSTNAME = "${var.vm_hostname}"
 }
}
#  ESXI Guest resource
resource "esxi_guest" "Default" {
  guest_name         = "${var.vm_hostname}"
  disk_store         = "${var.disk_store}"
  ovf_source         = "/root/create-and-deploy-esxi/packer-centos-7-x86_64/packer-centos-7-x86_64.ova/packer-centos-7-x86_64.ova"
  memsize            = "1024"
  network_interfaces = [
    {
      virtual_network = "${var.virtual_network}"
    }
  ]
  guestinfo = {
    userdata.encoding = "gzip+base64"
    userdata = "${base64gzip(data.template_file.Default.rendered)}"
    metadata.encoding = "gzip+base64"
    metadata = "${base64gzip(data.template_file.network_config.rendered)}"
  }
}
