variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket for Terraform state"
  type = string
}

variable "lock_table_name" {
  description = "DynamoDB table for Terraform state locking"
  type    = string
  default = "terraform-state-lock-dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "tf-aws-eks-app"
}