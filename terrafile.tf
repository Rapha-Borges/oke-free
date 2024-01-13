module "compartment" {
  source                            = "./compartment"
  compartment_name                  = var.compartment_name
}

module "vcn" {
  source                            = "oracle-terraform-modules/vcn/oci"
  version                           = "3.6.0"

  compartment_id                    = module.compartment.compartment_id
  region                            = var.region

  internet_gateway_route_rules      = null
  local_peering_gateways            = null
  nat_gateway_route_rules           = null

  vcn_name                          = var.vcn_name
  vcn_dns_label                     = var.vcn_dns_label
  vcn_cidrs                         = ["10.0.0.0/16"]

  create_internet_gateway           = true
  create_nat_gateway                = true
  create_service_gateway            = true
}

module "network" {
  source                            = "./network"
  compartment_id                    = module.compartment.compartment_id
  vcn_id                            = module.vcn.vcn_id
  nat_route_id                      = module.vcn.nat_route_id
  ig_route_id                       = module.vcn.ig_route_id
}

module "cluster" {
  source                            = "./cluster"
  compartment_id                    = module.compartment.compartment_id
  cluster_name                      = var.cluster_name
  k8s_version                       = var.k8s_version
  node_size                         = var.node_size
  shape                             = var.shape
  memory_in_gbs_per_node            = var.memory_in_gbs_per_node
  ocpus_per_node                    = var.ocpus_per_node
  image_id                          = var.image_id
  ssh_public_key                    = var.ssh_public_key
  public_subnet_id                  = module.network.public_subnet_id
  vcn_id                            = module.vcn.vcn_id
  vcn_private_subnet_id             = module.network.vcn_private_subnet_id
}

module "loadbalancer" {
  source                            = "./loadbalancer"
  depends_on                        = [ module.cluster, module.network, module.compartment, module.vcn ]
  namespace                         = var.load_balancer_name_space
  node_pool_id                      = module.cluster.node_pool_id
  compartment_id                    = module.compartment.compartment_id
  public_subnet_id                  = module.network.public_subnet_id
  node_size                         = var.node_size
  node_port                         = var.node_port
  listerner_port                    = var.listerner_port
}

module "kubeconfig" {
  source                            = "./kubeconfig"
  cluster_id                        = module.cluster.cluster_id
  depends_on                        = [ module.loadbalancer ]
}

output "public_ip" {
  value = module.loadbalancer.load_balancer_public_ip
}