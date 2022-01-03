/*
 * Variables
 */

variable "ad" {}
variable "compartment" {}

variable "hostname" {}

variable "vcn_id" {}
variable "subnet_id" {}

variable "image_id" {}
variable "image_os" {}

variable "shape" {}
variable "flex_memory_in_gbs" {}
variable "flex_ocpus" {}

variable "ydns_host" {}

/*
 * Providers
 */

provider "oci" {}

/*
 * Fetch Shape Configurations
 */

data "oci_core_shapes" "ad1" {
  compartment_id      = var.compartment
  availability_domain = var.ad
}

locals {
  shapes_config = {
    for i in data.oci_core_shapes.ad1.shapes : i.name => {
      "memory_in_gbs" = i.memory_in_gbs
      "ocpus"         = i.ocpus
    }
  }

  shape_is_flex = length(regexall("^*.Flex", var.shape)) > 0
}

/*
 * Configuration
 */

//
// Instance
//

resource "oci_core_instance" "free" {
  availability_domain = var.ad
  compartment_id      = var.compartment
  shape               = var.shape

  shape_config {
    memory_in_gbs = local.shape_is_flex == true ? var.flex_memory_in_gbs : local.shapes_config[var.shape]["memory_in_gbs"]
    ocpus         = local.shape_is_flex == true ? var.flex_ocpus : local.shapes_config[var.shape]["ocpus"]
  }

  create_vnic_details {
    hostname_label = var.hostname
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

  freeform_tags = {
    "openvpn_service" = "yes"
    "os"              = var.image_os
    "ydns_host"       = var.ydns_host
  }
}

//
// Network Security Group
//

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

resource "oci_core_network_security_group_security_rule" "openvpn" {
  network_security_group_id = oci_core_network_security_group.free.id

  direction = "INGRESS"
  protocol  = 17 # UDP

  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"

  udp_options {
    destination_port_range {
      min = 1194
      max = 1194
    }
  }
}
