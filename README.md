# Terraform + Ansible — AWS Homelab DevOps

Projeto de estudo DevOps que provisiona uma stack web completa na AWS com Terraform e a configura automaticamente com Ansible.

## Arquitetura

```
AWS (us-east-1)
└── VPC (10.0.0.0/16)
    ├── Subnet Pública (10.0.1.0/24) — AZ: us-east-1a
    │   ├── EC2 Ubuntu 22.04 (t3.micro)
    │   └── Internet Gateway
    ├── Subnet Privada A (10.0.2.0/24) — AZ: us-east-1a
    │   └── RDS PostgreSQL 16 (db.t3.micro)
    ├── Subnet Privada B (10.0.3.0/24) — AZ: us-east-1b
    │   └── RDS Subnet Group (multi-AZ obrigatório)
    ├── Security Group: ec2-web-sg   → porta 22 (SSH) + 80 (HTTP)
    ├── Security Group: rds-postgres-sg → porta 5432 (apenas da EC2)
    └── S3 Bucket (privado, versionado)
```

Após o provisionamento, o Ansible configura a EC2 com:

| Role | O que faz |
|---|---|
| `common` | Atualiza pacotes e instala ferramentas essenciais + AWS CLI |
| `docker` | Instala Docker CE e adiciona o usuário ao grupo docker |
| `nginx` | Instala Nginx e cria página de boas-vindas |
| `s3_notify` | Gera log de deploy e envia para o S3 bucket |

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/) >= 2.12
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) configurado (`aws configure`)
- Par de chaves SSH gerado em `~/.ssh/id_rsa` e `~/.ssh/id_rsa.pub`
- Conta AWS com permissões para EC2, VPC, S3 e RDS

## Como usar

### 1. Clone o repositório

```bash
git clone https://github.com/Luckers1/Terraform-AWS.git
cd Terraform-AWS
```

### 2. Configure as variáveis do Terraform

```bash
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars com seus valores (região, nome do bucket, senha do banco)
```

> ⚠️ O nome do S3 bucket deve ser **globalmente único** na AWS.

### 3. Provisione a infraestrutura

```bash
terraform init
terraform plan
terraform apply
```

Os outputs exibirão o IP público da EC2, o endpoint do RDS e o nome do bucket S3.

> ⏱️ O RDS demora cerca de 5-10 minutos para ficar disponível.

### 4. Configure o inventário do Ansible

```bash
cp ansible/inventory.ini.example ansible/inventory.ini
# Substitua <IP_PUBLICO_EC2> pelo IP exibido no output do Terraform
```

### 5. Execute o playbook Ansible

```bash
cd ansible
ansible-playbook -i inventory.ini playbook.yml
```

### 6. Destrua os recursos ao terminar

```bash
cd ..
terraform destroy
```

> ⚠️ Lembre-se de destruir os recursos para evitar cobranças inesperadas na AWS.

## Estrutura do projeto

```
.
├── main.tf                             # VPC, EC2, S3, RDS, Security Groups
├── variables.tf                        # Definição de variáveis
├── outputs.tf                          # IP da EC2, endpoint RDS, nome do S3
├── terraform.tfvars.example            # Template de variáveis
├── .gitignore                          # Exclui tfstate, tfvars, inventory.ini
└── ansible/
    ├── playbook.yml                    # Playbook principal
    ├── inventory.ini.example           # Template de inventário
    ├── group_vars/
    │   └── all.yml                     # Variáveis globais
    └── roles/
        ├── common/tasks/main.yml       # Pacotes + AWS CLI
        ├── docker/tasks/main.yml       # Docker CE
        ├── nginx/
        │   ├── tasks/main.yml          # Nginx + página de boas-vindas
        │   └── handlers/main.yml       # Handler restart
        └── s3_notify/tasks/main.yml    # Envia log de deploy para o S3
```

## Tecnologias

- **Terraform** — IaC para provisionar recursos na AWS (`hashicorp/aws ~> 5.0`)
- **Ansible** — Configuration Management com 4 roles
- **AWS EC2** — Instância Ubuntu 22.04 LTS (t3.micro)
- **AWS S3** — Bucket privado e versionado para assets e logs
- **AWS RDS** — PostgreSQL 16 em subnet privada (db.t3.micro)
- **Docker** + **Nginx** — Configurados via Ansible

## Segurança

- Credenciais AWS, IPs e senhas **nunca** são commitados (ver `.gitignore`)
- O RDS fica em subnet **privada** — acessível apenas pela EC2 via Security Group
- O S3 bucket tem **acesso público bloqueado** por padrão
- Em produção, use [remote state](https://developer.hashicorp.com/terraform/language/state/remote) com S3 + DynamoDB para lock
