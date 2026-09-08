variable "aws_region" {
  type = string
}

variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "single_nat_gateway" {
  type    = bool
  default = true
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 2
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "db_name" {
  type    = string
  default = "appdb"
}

variable "db_username" {
  type    = string
  default = "appadmin"
}

variable "db_allocated_storage" {
  type    = number
  default = 20
}

variable "application_namespace" {
  type    = string
  default = "app"
}

variable "application_service_account" {
  type    = string
  default = "app-service-account"
}