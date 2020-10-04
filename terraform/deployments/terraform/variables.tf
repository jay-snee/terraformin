variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "terraformin.example.com"
}

variable "region" {
  description = "AWS deployment region"
  type        = string
  default     = "eu-west-1"
}

variable "namespace" {
  description = "Flask app Kubernetes namespace"
  type        = string
  default     = "terraformin-terraform"
}

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "terraformin-terraform-release"
}

variable "http_username" {
  description = "HTTP Basic auth username"
  type        = string
  default     = "bob" 
}
variable "http_password" {
  description = "HTTP Basic auth password"
  type        = string
  default     = "thebuilder" 
}
variable "app_secret" {
  description = "Secret string rendered behind /supersecret app endpoint"
  type        = string
  default     = "I love cookies." 
}

variable "services_subnet_cidr_block" {
  description = "Subnet CIDR block to use for services"
  type        = string
  default     = "172.20.16.0/22"
}