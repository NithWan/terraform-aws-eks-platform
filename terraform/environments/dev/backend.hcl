bucket         = "terraform-state-lock-bucket-dev-22192"
key            = "eks-platform/dev/terraform.tfstate"
region         = "us-west-2"
dynamodb_table = "terraform-state-lock-dev"
encrypt        = true