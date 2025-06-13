resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "eks.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned",
    Name = "${var.cluster_name}-eks-cluster-role"
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_attach" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "this" {
  name     = "${var.cluster_name}-${var.environment}"
  role_arn = aws_iam_role.eks_cluster_role.arn

  version = var.eks_version  # Optional: specify EKS version, e.g., "1.21"

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_attach]

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned",
    Name = "${var.cluster_name}-eks-cluster"
  })
}
