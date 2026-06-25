# =============================================================================
# Backend S3 + DynamoDB para el estado de Terraform
# -----------------------------------------------------------------------------
# Como el usuario prefiere state local (no S3), este archivo es informativo.
# Si se desea habilitar state remoto para trabajo en pareja / CI:
#   1. Descomentar el bloque backend en versions.tf
#   2. Ejecutar: terraform init -reconfigure
#
# El siguiente script crea el bucket + tabla DynamoDB necesarios.
# =============================================================================

resource "aws_s3_bucket" "tfstate" {
  count  = var.enable_remote_backend ? 1 : 0
  bucket = "${var.project_name}-tfstate"

  tags = {
    Name = "${var.project_name}-tfstate"
  }
}

resource "aws_s3_bucket_versioning" "tfstate" {
  count  = var.enable_remote_backend ? 1 : 0
  bucket = aws_s3_bucket.tfstate[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  count  = var.enable_remote_backend ? 1 : 0
  bucket = aws_s3_bucket.tfstate[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tflock" {
  count        = var.enable_remote_backend ? 1 : 0
  name         = "${var.project_name}-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "${var.project_name}-tflock"
  }
}

variable "enable_remote_backend" {
  description = "Habilitar backend S3 + DynamoDB para state remoto"
  type        = bool
  default     = false
}
