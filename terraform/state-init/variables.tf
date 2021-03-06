variable "region" {
  description = "AWS deployment region"
  type        = string
  default     =  "eu-west-1"
}

variable "tf_state" {
  description = "S3 bucket to store Terraform state"
  type        = string
  default     = "terraformin-tf-state-store"
}

variable "tf_state_lock_table" {
  description = "DynamoDB table name for TF state locks"
  type        = string
  default     = "terraformin-tf-locks"
}

variable "k8s_state" {
  description = "S3 bucket to store Kubernetes state"
  type        = string
  default     = "terraformin-k8s-state-store"
}