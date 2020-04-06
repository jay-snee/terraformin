variable "region" {
  description = "AWS deployment region"
  type        = string
}

variable "namespace" {
  description = "Application Kubernetes namespace"
  type        = string
}

variable "redis_host" {
  description = "Redis/ElasticCache hostname"
  type        = string
  default     = "localhost" 
}

variable "redis_port" {
  description = "Redis/ElasticCache port number"
  type        = string
  default     = "6789" 
}

variable "http_username" {
  description = "HTTP Basic auth username"
  type        = string
  default     = "change-me" 
}
variable "http_password" {
  description = "HTTP Basic auth password"
  type        = string
  default     = "change-me" 
}
variable "app_secret" {
  description = "Secret string rendered behind /supersecret app endpoint"
  type        = string
  default     = "change-me" 
}

variable "release_name" {
  description = "Helm release name"
  type        = string
  default     = "bloomreach-release"
}