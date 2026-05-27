variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Nome da instância EC2"
  type        = string
  default     = "ec2-devops-lab"
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "ssh_public_key_path" {
  description = "Caminho para a chave pública SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "s3_bucket_name" {
  description = "Nome do bucket S3 (deve ser globalmente único)"
  type        = string
  default     = "homelab-assets-devops"
}

variable "db_name" {
  description = "Nome do banco de dados PostgreSQL"
  type        = string
  default     = "homelabdb"
}

variable "db_username" {
  description = "Usuário administrador do RDS"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Senha do banco de dados RDS (use terraform.tfvars, nunca commite)"
  type        = string
  sensitive   = true
}
