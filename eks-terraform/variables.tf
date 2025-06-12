variable "aws_region" {
  description = "Região da AWS onde o cluster será criado"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: dev, staging, prod)"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_types" {
  description = "Lista de tipos de instâncias para o grupo de nós EKS"
  type        = list(string)
  default     = ["t3.medium"] # Tipo de instância padrão para o grupo de nós
}


variable "eks_version" {
  description = "Versão do Kubernetes para o cluster EKS"
  type        = string
  default     = "1.32"
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}