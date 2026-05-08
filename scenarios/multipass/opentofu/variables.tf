variable "cluster_name" {
  description = "Prefix used for Multipass instance names."
  type        = string
  default     = "productive-k3s-mp"
}

variable "image" {
  description = "Multipass image or release string."
  type        = string
  default     = "24.04"
}

variable "base_domain" {
  description = "Internal DNS suffix used for Rancher and registry hostnames."
  type        = string
  default     = "k3s.lab.internal"
}

variable "remote_dir" {
  description = "Path inside the VMs where productive-k3s will be copied."
  type        = string
  default     = "/home/ubuntu/productive-k3s"
}

variable "server_cpus" {
  type    = number
  default = 4
}

variable "server_memory" {
  type    = string
  default = "8G"
}

variable "server_disk" {
  type    = string
  default = "40G"
}

variable "agent_cpus" {
  type    = number
  default = 2
}

variable "agent_memory" {
  type    = string
  default = "4G"
}

variable "agent_disk" {
  type    = string
  default = "30G"
}
