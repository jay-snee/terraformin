terraform {
  backend "s3" {
    bucket         = "terraformin-tf-state-store"
    key            = "deploy/helm/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "terraformin-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "kubernetes" {}

provider "helm" {}