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
  default     = "terraformin-helm"
}

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "terraformin-helm-release"
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

variable "chart_version" {
  description = "Application Helm chart version"
  type        = string
  default     = "0.3"
}

variable "services_subnet_cidr_block" {
  description = "Subnet CIDR block to use for services"
  type        = string
  default     = "172.20.12.0/22"
}