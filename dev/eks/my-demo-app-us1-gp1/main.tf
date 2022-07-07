terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket = "cacruz-my-demo-app-eks"
    key    = "terraform/state.tfstate"
    region = "us-east-1"
  }

}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_id]
  }
}

# DATA #
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "cacruz-my-demo-app-vpc"
    key    = "terraform/state.tfstate"
    region = var.aws_region
  }
}

/*
resource "aws_iam_openid_connect_provider" "default" {
  url = aws_eks_cluster.primary.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = [var.oidc_thumbprint]
}
*/

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = "${var.base_name}-cluster"
  cluster_version = "1.21"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  ##################################
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }
  ##################################
  /*
  cluster_encryption_config = [{
    provider_key_arn = "ac01234b-00d9-40f6-ac95-e42345f78b00"
    resources        = ["secrets"]
  }]
  */

  vpc_id     = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.vpc.outputs.subnets_ids

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    disk_size      = 50
    instance_types = ["t2.micro", "t2.micro", "t2.micro", "t2.micro"]
  }

  eks_managed_node_groups = {
    my_web_app_gp1_us1 = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"

      # ami_type = "AL2_x86_64"

      # launch_template 
      k8s_labels = {
        Environment = "dev"
      }
    }
  }

  # aws-auth configmap
  # create_aws_auth_configmap = true
  manage_aws_auth_configmap = true


  /*
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::123456789:role/role1"
      username = "role1"
      groups   = ["system:masters"]
    },
  ]
  */
  aws_auth_accounts = [
    "${data.aws_caller_identity.current.arn}",
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
