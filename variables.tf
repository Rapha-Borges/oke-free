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
  default = "VM.Standard.E3.Flex"
}

variable "ocpus_per_node" {
  type    = number
  default = 1
}

variable "memory_in_gbs_per_node" {
  type    = number
  default = 1
}

variable "image_id" {
  type    = string
  default = "ocid1.image.oc1.iad.aaaaaaaazi34xyxv6og7qgn3nqvaykfvg5ntkkx7yhlkjzpn4z45l72l53wa"
}
# Link to a list of available images (Be sure to select the correct region and CPU architecture. We are using Oracle-Linux-8.8-2023.12.13-0)
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

# ----------> SSH <----------

variable "ssh_public_key" {
  type    = string
}