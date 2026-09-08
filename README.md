# terraform-aws-eks-platform
Production-style AWS EKS platform built with Terraform, featuring multi-AZ VPC networking, Spot worker nodes, IRSA, RDS MySQL, Secrets Manager, KMS-encrypted S3, and remote Terraform state management.

# project-stucture
tf-aws-eks-platform/
├── .gitignore
├── README.md
│
├── bootstrap/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── terraform.tfvars.example
│
├── environments/
│   ├── dev/
│   │   ├── backend.hcl
│   │   └── terraform.tfvars
│   ├── uat/
│   │   ├── backend.hcl
│   │   └── terraform.tfvars
│   └── prod/
│       ├── backend.hcl
│       └── terraform.tfvars
│
└── infrastructure/
    ├── backend.tf
    ├── versions.tf
    ├── providers.tf
    ├── variables.tf
    ├── main.tf
    ├── outputs.tf
    └── modules/
        ├── network/
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        ├── eks/
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        ├── storage/
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        ├── database/
        │   ├── main.tf
        │   ├── variables.tf
        │   └── outputs.tf
        └── irsa/
            ├── main.tf
            ├── variables.tf
            └── outputs.tf
