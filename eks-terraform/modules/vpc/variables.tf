variable "cidr_block" {
  description = "CIDR principal da VPC"
  type        = string
}

variable "region" {
  description = "Região onde os recursos serão criados"
  type        = string
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
