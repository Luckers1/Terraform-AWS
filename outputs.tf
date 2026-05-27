output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.web.public_ip
}

output "ec2_public_dns" {
  description = "DNS público da instância EC2"
  value       = aws_instance.web.public_dns
}

output "s3_bucket_name" {
  description = "Nome do bucket S3 criado"
  value       = aws_s3_bucket.assets.bucket
}

output "rds_endpoint" {
  description = "Endpoint de conexão do RDS PostgreSQL"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_port" {
  description = "Porta do RDS PostgreSQL"
  value       = aws_db_instance.postgres.port
}
