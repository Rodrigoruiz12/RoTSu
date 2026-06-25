provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "RoTSu"
      ManagedBy = "Terraform"
      Course    = "Ingenieria-DevOps"
      Ev        = "Ev3"
    }
  }
}

provider "tls" {}
