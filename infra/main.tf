# ---------------------------------------------------------------------
# VETRA EVOLUTION - INFRASTRUCTURE AS CODE
# Arquivo: infra/main.tf
# Versão: 1.0 (Genesis)
# Descrição: Configuração do Provider AWS e Terraform State.
# ---------------------------------------------------------------------

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