rovider "aws"{
     region = "us-west-1"
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = "aws_vpc"
  cidr = "10.0.0.0/16"
  azs = ["eu-west-1a", "eu-west-1b"]
  private_subnet = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnet = ["10.0.101.0/24", "10.0.102.0/24"]


  enable_nat_gateway = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.36.0"

  cluster_name = "eks_cluster"
  cluster_version = "1.31"
  subnet_id = module.vpc.private_subnet
  vpc_id = module.vpc.vpc_id

  eks_managed_node_groups = {
     default = {
          desired_capacity = 1
          max_capacity = 2
          min_capacity = 1

          instance_types = ["t3.medium"]
     }
  }
  enable_isra = true
}

data "aws_eks_cluster_auth" "cluster" {
     name = module.eks.cluster_name
}

