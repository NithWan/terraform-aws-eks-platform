resource "aws_iam_role" "vpc_cni" {
  name = "${var.cluster_name}-vpc-cni-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "pods.eks.amazonaws.com"
      }
      Action = [
        "sts:AssumeRole",
        "sts:TagSession"
      ]
    }]
  })

  tags = {
    Environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "vpc_cni" {
  role       = aws_iam_role.vpc_cni.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}


module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  endpoint_public_access  = true
  endpoint_private_access = true

  enable_irsa = true
  
  enable_cluster_creator_admin_permissions = true

  addons = {
    eks-pod-identity-agent = {
      before_compute = true
      most_recent    = true
    }

    vpc-cni = {
      before_compute = true
      most_recent    = true

      pod_identity_association = [{
        role_arn        = aws_iam_role.vpc_cni.arn
        service_account = "aws-node"
      }]

      resolve_conflicts_on_create = "OVERWRITE"
      resolve_conflicts_on_update = "OVERWRITE"
    }

    kube-proxy = {
      before_compute = true
      most_recent    = true
    }

    coredns = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    spot_workers = {
      name = "${var.cluster_name}-spot-workers"

      instance_types = var.node_instance_types
      capacity_type  = "SPOT"

      min_size     = var.node_min_size
      desired_size = var.node_desired_size
      max_size     = var.node_max_size

      subnet_ids = var.private_subnet_ids
      iam_role_name = "${var.cluster_name}-node-role"
      iam_role_use_name_prefix = false

      labels = {
        environment = var.environment
        capacity    = "spot"
      }
    }
  }

  tags = {
    Environment = var.environment
  }

}