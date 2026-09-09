aws_region      = "us-west-2"
project_name    = "eks-platform"
environment     = "dev"
cluster_version = "1.30"

vpc_cidr = "10.10.0.0/16"

public_subnet_cidrs = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

private_subnet_cidrs = [
  "10.10.11.0/24",
  "10.10.12.0/24"
]

node_instance_types = ["t3.medium"]

node_min_size     = 2
node_desired_size = 2
node_max_size     = 2

single_nat_gateway = true

db_instance_class = "db.t3.micro"
db_name           = "appdb"
db_username       = "appadmin"
db_allocated_storage = 20

application_namespace       = "app"
application_service_account = "app-service-account"