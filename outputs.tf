output "command-to-create-kubeconfig" {
  value = "oci ce cluster create-kubeconfig --cluster-id ${module.cluster.cluster_id} --file ~/.kube/config --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT --auth security_token" 
}