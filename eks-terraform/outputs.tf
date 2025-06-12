output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnets" {
  value = module.vpc.private_subnets
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "nodegroup_private_name" {
  value = module.nodegroup_private.nodegroup_name
}

output "nodegroup_public_name" {
  value = module.nodegroup_public.nodegroup_name
}