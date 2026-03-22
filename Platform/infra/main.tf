#backend
terraform {
  backend "s3" {
    bucket       = var.backend_bucket
    key          = var.backend_key
    region       = var.region
    encrypt      = true
    use_lockfile = true
  }
}



# --- Provider Configuration ---
provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

# --- 1. Network (VPC) ---
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.vpc_name}-${var.environment}"
  cidr = var.vpc_cidr
  azs = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true


  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}




#EKS Block
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name    = "${var.cluster_name}-${var.environment}"
  kubernetes_version = "1.35"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Access Settings
  enable_cluster_creator_admin_permissions = true
  authentication_mode                      = "API_AND_CONFIG_MAP"

  endpoint_public_access       = true
  endpoint_public_access_cidrs = ["0.0.0.0/0"] #

  # Cluster Addons
  addons = {
    coredns    = { most_recent = true }
    kube-proxy = { most_recent = true }
    vpc-cni    = { 
      most_recent              = true
      before_compute           = true 
      resolve_conflicts_on_update = "PRESERVE"
    }
  }

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      
      min_size     = var.min_size
      max_size     = var.max_size
      desired_size = var.desired_size

    }
  }
}





# --- 3. Identity (OIDC & Team Roles) ---
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}


resource "aws_iam_role" "team_roles" {
  for_each = toset(var.teams)
  name     = "${each.value}-eks-deployer"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub": "repo:${var.github_org}/*"
        }
      }
    }]
  })
}




# ADDED: ECR & EKS permissions for the IAM roles
resource "aws_iam_role_policy" "team_permissions" {
  for_each = toset(var.teams) # Use the variable here
  name     = "${each.value}-base-permissions"
  role     = aws_iam_role.team_roles[each.key].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeRepositories",
          "ecr:CreateRepository"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["eks:DescribeCluster"]
        Resource = module.eks.cluster_arn
      }
    ]
  })
}

# --- 4. Cluster Bridge (Access Entries) ---
resource "aws_eks_access_entry" "team_entries" {
  for_each      = toset(var.teams) # Use the variable here
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_iam_role.team_roles[each.key].arn
  kubernetes_groups = ["group-${each.value}"]
  type          = "STANDARD"
  depends_on = [module.eks]

}

# --- 5. Namespace Isolation (K8s RBAC) ---
resource "kubernetes_namespace" "teams" {
  for_each = toset(var.teams) # Use the variable here
  metadata { name = each.value }
  depends_on = [module.eks]

}

resource "kubernetes_role_binding" "team_bindings" {
  for_each = toset(var.teams) # Use the variable here
  metadata {
    name      = "${each.value}-mgr"
    namespace = kubernetes_namespace.teams[each.key].metadata[0].name
  }
  subject {
    kind      = "Group"
    name      = "group-${each.value}"
    api_group = "rbac.authorization.k8s.io"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "edit"
    api_group = "rbac.authorization.k8s.io"
  }
  depends_on = [module.eks]

}

resource "kubernetes_namespace" "obs" {
  metadata { name = "observability" }
  depends_on = [module.eks]
}
