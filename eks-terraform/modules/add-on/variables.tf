variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "addon_name" {
  description = "Nome do add-on EKS"
  type        = string
}

variable "addon_version" {
  description = "Versão do add-on EKS (opcional)"
  type        = string
  default     = null
}

variable "resolve_conflicts_on_create" {
  description = "Política de conflito na criação"
  type        = string
  default     = "NONE"
}

variable "resolve_conflicts_on_update" {
  description = "Política de conflito na atualização"
  type        = string
  default     = "OVERWRITE"
}

variable "service_account_role_arn" {
  description = "ARN do role para service account (opcional)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags para o add-on"
  type        = map(string)
  default     = {}
}
