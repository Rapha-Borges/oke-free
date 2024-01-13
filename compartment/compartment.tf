resource "oci_identity_compartment" "_" {
  name          = var.compartment_name
  description   = var.compartment_name
  enable_delete = true
}