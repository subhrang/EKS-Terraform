module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  subnets      = module.vpc.private_subnets

  tags = {
    Environment = "training"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
    auto-delete = "no"
  }

  vpc_id = module.vpc.vpc_id

  node_groups = [
    {
      name                          = "node-group-1"
      instance_type                 = "t2.small"
      desired_capacity          = 2
      min_capacity		= 2
      source_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    {
      name                          = "node-group-2"
      instance_type                 = "t2.medium"
      source_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
      desired_capacity          = 1
      min_capacity		= 1
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
