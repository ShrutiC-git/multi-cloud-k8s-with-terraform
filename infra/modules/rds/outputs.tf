output "endpoint" { 
    value = aws_db_instance.this.address 
}

output "db_credentials_secret_arn" {
  description = "The ARN of the secret containing the database credentials"
  value       = aws_secretsmanager_secret.this.arn
}