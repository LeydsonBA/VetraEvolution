# infra/main.tf

provider "aws" {
  region = "us-east-1" # ou sua região preferida (ex: sa-east-1 para SP)
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}