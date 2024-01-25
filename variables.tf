# ----------> Compartment <----------

variable "compartment_name" {
  type    = string
  default = "k8s"
}

variable "region" {
  type    = string
  default = "us-ashburn-1"
}

# ---------->VM's----------

variable "shape" {
  type    = string
  default = "VM.Standard.A1.Flex"
}

variable "ocpus_per_node" {
  type    = number
  default = 1
}

variable "memory_in_gbs_per_node" {
  type    = number
  default = 6
}

variable "image_id" {
  type    = string
  default = "ocid1.image.oc1.iad.aaaaaaaao2zpwcb2osmbtliiuzlphc3y2fqaqmcpp5ttlcf573sidkabml7a"
}
# Link to a list of available images (Be sure to select the correct region and CPU architecture. We are using Oracle-Linux-8.8-aarch64-2023.09.26-0-OKE-1.28.2-653)
# https://docs.cloud.oracle.com/iaas/images/

# ----------> Cluster <----------
variable "k8s_version" {
  type    = string
  default = "v1.28.2"
}

variable "node_size" {
  type    = string
  default = "1"
}

variable "cluster_name" {
  type    = string
  default = "k8s-cluster"
}

# ----------> Network <----------

variable "vcn_name" {
  type    = string
  default = "k8s-vcn"
}

variable "vcn_dns_label" {
  type    = string
  default = "k8svcn"
}

# ----------> Load Balancer <----------

variable "load_balancer_name_space" {
  type    = string
  default = "loadbalancer"
}

variable "node_port" {
  type    = number
  default = 30080
}

variable "listerner_port" {
  type    = number
  default = 80
}

# ----------> Auth <----------

variable "ssh_public_key" {
  type    = string
}

variable "fingerprint" {
  type    = string
}

variable "private_key_path" {
  type    = string
}

variable "tenancy_ocid" {
  type    = string
}

variable "user_ocid" {
  type    = string
}

variable "oci_profile" {
  type    = string
}
