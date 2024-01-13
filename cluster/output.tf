output "node_pool_id" {
  value = oci_containerengine_node_pool.k8s_node_pool.id
}

output "cluster_id" {
  value = oci_containerengine_cluster.k8s_cluster.id
}