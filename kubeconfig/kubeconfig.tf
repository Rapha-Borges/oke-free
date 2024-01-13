resource "null_resource" "create_kubeconfig" {
  provisioner "local-exec" {
    command = "oci ce cluster create-kubeconfig --cluster-id ${var.cluster_id} --file ~/.kube/config --token-version 2.0.0 --kube-endpoint PUBLIC_ENDPOINT"
  }
}