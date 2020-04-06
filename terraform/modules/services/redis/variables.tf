variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "region" {
  description = "AWS deployment region"
  type        = string
}

variable "release_name" {
  description = "Application name"
  type        = string
  default = "unknown"
}

variable "services_subnet_cidr_block" {
  description = "CIDR block for Services subnet"
  type        = string
  default     = "172.20.128.0/19"
}

variable "redis_engine" {
  description = "ElasticCache redis engine"
  type        = string
  default     = "redis"
}

variable "redis_node_type" {
  description = "ElasticCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "redis_num_cache_nodes" {
  description = "ElasticCache redis node count"
  type        = string
  default     = 1
}

variable "redis_parameter_group_name" {
  description = "ElasticCache redis parameter group name"
  type        = string
  default     = "default.redis3.2"
}

variable "redis_engine_version" {
  description = "ElasticCache redis engine version"
  type        = string
  default = "3.2.10"
}

variable "redis_port" {
  description = "ElasticCache redis port number"
  type        = string
  default = "6379"
}