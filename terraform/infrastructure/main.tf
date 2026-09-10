locals {
  cluster_name = "${var.project_name}-${var.environment}"
}

module "network" {
  source = "./modules/network"

  project_name = var.project_name
  environment  = var.environment

  vpc_cidr = var.vpc_cidr

  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  single_nat_gateway = var.single_nat_gateway
}

module "eks" {
  source = "./modules/eks"

  cluster_name    = local.cluster_name
  cluster_version = var.cluster_version

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  node_instance_types = var.node_instance_types

  node_min_size     = var.node_min_size
  node_desired_size = var.node_desired_size
  node_max_size     = var.node_max_size

  environment = var.environment
}

module "storage" {
  source = "./modules/storage"

  project_name = var.project_name
  environment  = var.environment
}

module "database" {
  source = "./modules/database"

  project_name = var.project_name
  environment  = var.environment

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  eks_node_security_group_id = module.eks.node_security_group_id

  kms_key_arn = module.storage.kms_key_arn

  db_instance_class    = var.db_instance_class
  db_name              = var.db_name
  db_username          = var.db_username
  db_allocated_storage = var.db_allocated_storage
}

module "irsa" {
  source = "./modules/irsa"

  aws_region = var.aws_region
  project_name = var.project_name
  environment  = var.environment

  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider     = module.eks.oidc_provider

  namespace            = var.application_namespace
  service_account_name = var.application_service_account

  bucket_arn  = module.storage.bucket_arn
  kms_key_arn = module.storage.kms_key_arn
}

resource "kubernetes_namespace_v1" "app" {
  metadata {
    name = var.application_namespace
  }

  depends_on = [
    module.eks
  ]
}

resource "kubernetes_service_account_v1" "app" {
  metadata {
    name      = var.application_service_account
    namespace = kubernetes_namespace_v1.app.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa.iam_role_arn
    }
  }
}

data "aws_secretsmanager_secret_version" "database" {
  secret_id = module.database.master_secret_arn
}

locals {
  db_secret = jsondecode(
    data.aws_secretsmanager_secret_version.database.secret_string
  )
}

resource "kubernetes_secret_v1" "database" {
  metadata {
    name      = "database-credentials"
    namespace = kubernetes_namespace_v1.app.metadata[0].name
  }

  data = {
    DB_HOST     = module.database.db_endpoint
    DB_PORT     = tostring(module.database.db_port)
    DB_NAME     = module.database.db_name
    DB_USERNAME = local.db_secret.username
    DB_PASSWORD = local.db_secret.password
  }

  type = "Opaque"
}

