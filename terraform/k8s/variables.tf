variable "image_repo" {
  description = "Repositorio Docker Hub (publico) de la imagen. ECR no disponible en AWS Academy Learner Lab."
  type        = string
  default     = "rotsu/frontend"
}

variable "image_tag" {
  description = "Tag de la imagen a desplegar (default: latest)"
  type        = string
  default     = "latest"
}

locals {
  image = "${var.image_repo}:${var.image_tag}"
}
