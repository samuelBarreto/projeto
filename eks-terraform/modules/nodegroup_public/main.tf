resource "aws_iam_role" "eks_node_role" {
  name = "${var.cluster_name}-${var.environment}-eks-public-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Effect = "Allow",
      Sid    = ""
    }]
  })

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned",
    Name = "${var.cluster_name}-eks-public-node-role"
  })
}

resource "aws_iam_role_policy_attachment" "eks_node_attach" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = "${var.cluster_name}-public-ng"
  subnet_ids      = var.subnet_ids
  node_role_arn   = aws_iam_role.eks_node_role.arn

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types
  depends_on     = [aws_iam_role_policy_attachment.eks_node_attach]

  tags = merge(var.tags, {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned",
    Name = "${var.cluster_name}-ng"
  })
}

