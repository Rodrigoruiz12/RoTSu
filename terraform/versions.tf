terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }

  # Backend S3 + DynamoDB para state remoto y locking.
  # DESCOMENTAR y rellenar tras crear el bucket/DDB con bootstrap.tf
  # backend "s3" {
  #   bucket         = "rotsu-tfstate"
  #   key            = "rotsu/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "rotsu-tflock"
  #   encrypt        = true
  # }
}
