cluster_name = "shiv"
environment  = "dev"

github_org    = "shivtestac"
github_branch = "main"
vpc_name = "shiv"

team_config = {
  "team-a" = "shivtestac/app1-repo"
  "team-b" = "other-org/app2-repo"
  "team-c" = "external-user/project-x"
}

azs = ["eu-central-1a", "eu-central-1b"]

private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

node_instance_type = "t3.medium"
desired_size       = 1
min_size           = 1
max_size           = 1
