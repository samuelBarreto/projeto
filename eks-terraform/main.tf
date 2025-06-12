module "vpc" {
  source     = "./modules/vpc"
  cidr_block = var.vpc_cidr
  region     = var.aws_region
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
  subnet_ids   = module.vpc.private_subnets
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
  subnet_ids     = concat(module.vpc.private_subnets, module.vpc.public_subnets)
  region         = var.aws_region
  instance_types = var.instance_types
  desired_size = 1
  max_size     = 1
  min_size     = 1
  environment  = var.environment
  tags = {
    Environment = var.environment
    ClusterName = var.cluster_name
  }

}