resource "aws_eks_addon" "this" {
  cluster_name                  = var.cluster_name
  addon_name                    = var.addon_name
  addon_version                 = var.addon_version
  resolve_conflicts_on_create   = var.resolve_conflicts_on_create
  resolve_conflicts_on_update   = var.resolve_conflicts_on_update
  service_account_role_arn      = var.service_account_role_arn

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${var.addon_name}-addon"
  })
}
