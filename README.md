# terraform-aws-eks-platform
Production-style AWS EKS platform built with Terraform, featuring multi-AZ VPC networking, Spot worker nodes, IRSA, RDS MySQL, Secrets Manager, KMS-encrypted S3, and remote Terraform state management.

## Project Structure

```text
terraform-aws-eks-platform/
├── .gitignore
├── README.md
├── bootstrap/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   └── variables.tf
│
├── infrastructure/
│   ├── backend.tf
│   ├── backend.hcl.example
│   ├── data.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   ├── variables.tf
│   ├── versions.tf
│   │
│   └── modules/
│       ├── network/
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       │
│       ├── eks/
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       │
│       ├── irsa/
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       │
│       ├── database/
│       │   ├── main.tf
│       │   ├── outputs.tf
│       │   └── variables.tf
│       │
│       └── storage/
│           ├── main.tf
│           ├── outputs.tf
│           └── variables.tf
│
└── scripts/
    └── demo.sh
```

| Directory           | Purpose                                                                                                 |
| ------------------- | ------------------------------------------------------------------------------------------------------- |
| `bootstrap/`        | Creates the S3 remote-state bucket and DynamoDB locking table. Run once before the main infrastructure. |
| `infrastructure/`   | Main Terraform root module used to deploy the AWS environment.                                          |
| `modules/network/`  | VPC, public/private subnets, NAT Gateway and routing.                                                   |
| `modules/eks/`      | EKS cluster and Spot managed node group.                                                                |
| `modules/irsa/`     | Pod-specific IAM role and IRSA configuration.                                                           |
| `modules/database/` | RDS MySQL and database networking.                                                                      |
| `modules/storage/`  | KMS-encrypted S3 raw-data bucket.                                                                       |
| `scripts/`          | Commands/scripts used during the live demonstration.                                                    |

