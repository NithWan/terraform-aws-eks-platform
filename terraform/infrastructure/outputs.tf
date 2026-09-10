output "environment" {
  value = var.environment
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "private_subnet_ids" {
  value = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "raw_data_bucket" {
  value = module.storage.bucket_name
}

output "kms_key_arn" {
  value = module.storage.kms_key_arn
}

output "rds_endpoint" {
  value = module.database.db_endpoint
}

output "rds_secret_arn" {
  value = module.database.master_secret_arn
}

output "pod_iam_role_arn" {
  value = module.irsa.iam_role_arn
}

output "kubectl_config_command" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "flask_cloudwatch_log_group" {
  description = "CloudWatch Log Group used by Flask Fluent Bit sidecar"
  value       = aws_cloudwatch_log_group.flask.name
}