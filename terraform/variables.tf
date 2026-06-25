variable "aws_region" {
  description = "Region de AWS para desplegar la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre del proyecto (prefijo para recursos)"
  type        = string
  default     = "rotsu"
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "Tipo de instancia EC2 para el nodo Kubernetes (t3.small = 2GB RAM, suficiente para kubeadm single-node)"
  type        = string
  default     = "t3.small"
}

variable "ssh_public_key" {
  description = "Llave publica SSH para acceder a la EC2. Solo aplica si enable_ssh_access=true. Si vacio y SSH habilitado, se genera un par nuevo."
  type        = string
  default     = ""
}

variable "allowed_ssh_cidr" {
  description = "CIDR autorizado para SSH a la EC2. Por defecto solo desde cualquier lado (restringir en prod)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "use_spot" {
  description = "Si true, usa Spot Instances para reducir costo. AWS Academy Learner Lab bloquea Spot, dejar en false."
  type        = bool
  default     = false
}

variable "spot_max_price" {
  description = "Precio maximo por hora para la Spot Instance (USD)"
  type        = string
  default     = "0.020"
}

variable "aws_account_id" {
  description = "ID de cuenta AWS. Se obtiene via data source si vacio."
  type        = string
  default     = ""
}

variable "docker_image_repo" {
  description = "Repositorio Docker Hub (publico) para la imagen del microservicio (ECR no esta disponible en AWS Academy Learner Lab)"
  type        = string
  default     = "rotsu/frontend"
}

variable "enable_ssh_access" {
  description = "Si true, crea key pair SSH y abre puerto 22. Recomendado: false (usar SSM Session Manager)"
  type        = bool
  default     = false
}

variable "ssm_kubeconfig_name" {
  description = "Nombre del SSM Parameter donde se almacena el kubeconfig (cifrado KMS)"
  type        = string
  default     = "/rotsu/k8s/kubeconfig"
}
