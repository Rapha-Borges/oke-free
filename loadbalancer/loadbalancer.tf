data "oci_core_instances" "instances" {
  compartment_id = var.compartment_id
}

resource "oci_network_load_balancer_network_load_balancer" "nlb" {
  compartment_id = var.compartment_id
  display_name   = "k8s-nlb"
  subnet_id      = var.public_subnet_id

  is_private                     = false
  is_preserve_source_destination = false
}

resource "oci_network_load_balancer_backend_set" "nlb_backend_set" {
  health_checker {
    protocol = "TCP"
  }
  name                     = "k8s-backend-set-nginx"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  policy                   = "FIVE_TUPLE"
  depends_on               = [oci_network_load_balancer_network_load_balancer.nlb]

  is_preserve_source = false
}

resource "oci_network_load_balancer_backend" "nlb_backend" {
  backend_set_name         = oci_network_load_balancer_backend_set.nlb_backend_set.name
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = var.node_port
  depends_on               = [oci_network_load_balancer_backend_set.nlb_backend_set]
  count                    = var.node_size
  target_id                = data.oci_core_instances.instances.instances[count.index].id
}

resource "oci_network_load_balancer_listener" "nlb_listener" {
  default_backend_set_name = oci_network_load_balancer_backend_set.nlb_backend_set.name
  name                     = "k8s-nlb-listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  port                     = var.listerner_port
  protocol                 = "TCP"
  depends_on               = [oci_network_load_balancer_backend.nlb_backend]
}