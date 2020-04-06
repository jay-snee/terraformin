terraform {
  backend "s3" {
    bucket         = "bloomreach-tf-state-store"
    key            = "deploy/terraform/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "bloomreach-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "kubernetes" {}