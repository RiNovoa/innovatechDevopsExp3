variable "aws_region" {
  description = "Region AWS donde se despliega la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nombre base del proyecto"
  type        = string
  default     = "innovatech-ep3"
}

variable "cluster_name" {
  description = "Nombre del cluster EKS"
  type        = string
  default     = "innovatech-ep3-eks"
}
