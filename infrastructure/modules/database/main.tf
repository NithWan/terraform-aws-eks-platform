resource "aws_db_subnet_group" "mysql" {
  name = "${var.project_name}-${var.environment}-mysql"

  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-${var.environment}-mysql"
  }
}

resource "aws_security_group" "mysql" {
  name_prefix = "${var.project_name}-${var.environment}-mysql-"
  description = "Allow MySQL access from EKS worker nodes"
  vpc_id      = var.vpc_id

  ingress {
    description     = "MySQL from EKS nodes"
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    security_groups = [var.eks_node_security_group_id]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "mysql" {
  identifier = "${var.project_name}-${var.environment}-mysql"

  engine         = "mysql"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = 100
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password   = true
  master_user_secret_kms_key_id = var.kms_key_arn

  port = 3306

  db_subnet_group_name = aws_db_subnet_group.mysql.name

  vpc_security_group_ids = [
    aws_security_group.mysql.id
  ]

  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1

  auto_minor_version_upgrade = true

  skip_final_snapshot = true
  deletion_protection = false

  apply_immediately = true
}