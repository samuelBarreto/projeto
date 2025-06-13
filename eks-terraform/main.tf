module "vpc" {
  source      = "./modules/vpc"
  cidr_block  = var.vpc_cidr
  region      = var.aws_region
  environment = var.environment
  tags = {
    Environment = var.environment
    ClusterName = var.cluster_name
  }
}


module "eks" {
  source       = "./modules/eks"
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  region       = var.aws_region
  eks_version  = var.eks_version
  environment  = var.environment
  tags = {
    Environment = var.environment
    ClusterName = var.cluster_name
  }
}

module "nodegroup_private" {
  source         = "./modules/nodegroup_private"
  cluster_name   = module.eks.cluster_name
  subnet_ids     = module.vpc.private_subnets
  region         = var.aws_region
  instance_types = var.instance_types
  environment    = var.environment
  desired_size   = 2
  max_size       = 3
  min_size       = 1
  tags = {
    Environment = var.environment
    ClusterName = var.cluster_name
  }

}

module "nodegroup_public" {
  source         = "./modules/nodegroup_public"
  cluster_name   = module.eks.cluster_name
  subnet_ids     = [module.vpc.public_subnets[0]]
  region         = var.aws_region
  instance_types = var.instance_types
  desired_size   = 1
  max_size       = 1
  min_size       = 1
  environment    = var.environment
  tags = {
    Environment = var.environment
    ClusterName = var.cluster_name
  }

}

module "addon_kube_proxy" {
  source                      = "./modules/add-on"
  cluster_name                = module.eks.cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = "v1.32.0-eksbuild.2"
  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags = {
    Environment = var.environment
    ClusterName = var.cluster_name
  }
  depends_on = [module.eks]
}

module "addon_coredns" {
  source                      = "./modules/add-on"
  cluster_name                = module.eks.cluster_name
  addon_name                  = "coredns"
  addon_version               = "v1.11.4-eksbuild.14"
  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags = {
    Environment = var.environment
    ClusterName = var.cluster_name
  }
  depends_on = [module.eks]
}

module "addon_vpc_cni" {
  source                      = "./modules/add-on"
  cluster_name                = module.eks.cluster_name
  addon_name                  = "vpc-cni"
  addon_version               = "v1.19.2-eksbuild.1"
  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags = {
    Environment = var.environment
    ClusterName = var.cluster_name
  }
  depends_on = [module.eks]
}
                                                                                                                                               
                                              
                                                                                                                                                                            11,7          Top 