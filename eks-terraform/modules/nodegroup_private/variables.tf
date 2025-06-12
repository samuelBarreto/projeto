variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "region" {
  type = string
}

variable "instance_types" {
  type    = list(string)
  default = ["t3.medium"] 
  description = "Lista de tipos de instâncias para o grupo de nós EKS"
}


variable "desired_size" {
  type    = number
  description = "Quantidade desejada de nodes no grupo de nós EKS"
}

variable "max_size" {
  type    = number
  description = "Quantidade máxima de nodes no grupo de nós EKS"
}

variable "min_size" {
  type    = number
  description = "Quantidade mínima de nodes no grupo de nós EKS"
}

variable "tags" {
  description = "Tags para os recursos"
  type        = map(string)
  default     = {}
}