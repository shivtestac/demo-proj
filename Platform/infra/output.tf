output "team_role_arns" {
  description = "ARNs for the team execution roles. Copy these to GitHub Actions Secrets."
  value       = { for k, v in aws_iam_role.team_roles : k => v.arn }
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}
