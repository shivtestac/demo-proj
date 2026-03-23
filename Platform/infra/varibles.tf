variable "team_config" {
  type = map(string)
  description = "Map of team name to their GitHub repository (org/repo)"
}

variable "region" {
  description = "AWS region"
  default     = "eu-central-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
}

variable "environment" {
  description = "Environment name"
  default     = "dev"
}

variable "vpc_name" {
  default = "platform-vpc"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "azs" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "public_subnets" {
  type = list(string)
}

variable "node_instance_type" {
  default = "t3.medium"
}

variable "desired_size" {
  default = 2
}

variable "min_size" {
  default = 2
}

variable "max_size" {
  default = 5
}




variable "github_branch" {
  description = "Allowed branch"
  default     = "main"
}


variable "iam_role_name" {
  default = "github-actions-role"
}

variable "github_oidc_url" {
  default = "https://token.actions.githubusercontent.com"
}
