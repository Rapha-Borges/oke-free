output "load_balancer_public_ip" {
    value = "${oci_network_load_balancer_network_load_balancer.nlb.ip_addresses[0].ip_address}"
}
