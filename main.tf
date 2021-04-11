variable "ad" {}
variable "compartment" {}
variable "vcn_id" {}
variable "subnet_id" {}
variable "image_id" {}

provider "oci" {}

resource "oci_core_network_security_group" "free" {
  compartment_id = var.compartment
  vcn_id         = var.vcn_id
}

resource "oci_core_network_security_group_security_rule" "ssh" {
  network_security_group_id = oci_core_network_security_group.free.id

  direction = "INGRESS"
  protocol  = 6 # TCP

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_instance" "free" {
  availability_domain = var.ad
  compartment_id      = var.compartment
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    hostname_label = "free1"
    subnet_id      = var.subnet_id

    assign_public_ip = true
    nsg_ids          = [oci_core_network_security_group.free.id]
  }

  metadata = {
    ssh_authorized_keys = file("${path.module}/ssh/oracle.pub")
  }

  source_details {
    boot_volume_size_in_gbs = 50
    source_type             = "image"
    source_id               = var.image_id
  }
}
