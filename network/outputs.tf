output "public_subnet_id" {
  value = "${oci_core_subnet.vcn_public_subnet.id}"
}

output "vcn_private_subnet_id" {
  value = "${oci_core_subnet.vcn_private_subnet.id}"
}