resource "aws_cloudwatch_log_group" "flask" {
  name              = "/eks/flask-app"
  retention_in_days = 7

  tags = {
    Environment = var.environment
    Application = "flask-app"
  }
}