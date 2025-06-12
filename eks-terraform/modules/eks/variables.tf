variable "cluster_name" {
  type = string
  description = "Nome do cluster EKS" 
}

variable "eks_version" {
  description = "Versão do Kubernetes para o cluster EKS"
  type        = string
  default     = "1.32"
}

variable "vpc_id" {
  type = string
  description = "ID da VPC onde o cluster EKS será criado"
}

variable "subnet_ids" {
  type = list(string)
  description = "Lista de IDs de sub-redes onde os nós do cluster EKS serão criados"
}

variable "region" {
  type = string
  description = "Região da AWS onde o cluster EKS será criado"
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Nome do ambiente (ex: dev, staging, prod)"
  type        = string
}