# create provider
provider "aws" {
  region = "us-east-1"
}

# #locking part
# resource "aws_dynamodb_table" "tf_remote_state_locking" {
#   hash_key = "LockID"
#   name = "21b-centos-locking-RDS"
#   attribute {
#     name = "LockID"
#     type = "S"
#   }
#   billing_mode = "PAY_PER_REQUEST"
# }
# create s3 bucket for the backend
terraform {
  backend "s3" {
    bucket = "21b-centos"
    key    = "RDS_EKS/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "21b-centos-locking-RDS"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "21b-centos"                                // Bucket from where to GET Terraform State
    key    = "eks_cluster/terraform.tfstate"             // Object name in the bucket to GET Terraform state
    region = "us-east-1"                                 // Region where bycket created
  }
}
data "aws_availability_zones" "available" {}

# create database subnet group
resource "aws_db_subnet_group" "database-subnet-group" {
    name        = "database_subnets"
    subnet_ids   = data.terraform_remote_state.network.outputs.private_subnet_ids
    description = "Subnet for Database Instance"
    tags = {
        Name = "Database Subnet"
    }
}

# create database instance
resource "aws_db_instance" "postgres_db" {
  identifier = var.identifier
  allocated_storage    = var.allocated_storage
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  name                 = var.name
  username             = var.username
  password             = var.password
  parameter_group_name = var.parameter_group_name
  skip_final_snapshot  = var.skip_final_snapshot
  multi_az             = var.multi_az
  port                 = var.port
  storage_type         = var.storage_type
  apply_immediately = var.apply_immediately
  db_subnet_group_name = aws_db_subnet_group.database-subnet-group.name

  tags = {
    Name = "${var.project} - DB"
  }
}

resource "aws_security_group" "rds-eks-sg" {
  name        = "DB SG"
  description = "DB SG"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  ingress = [{
      description      = "access from EKS cluster"
      from_port        = 5432
      to_port          = 5432
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = [data.terraform_remote_state.network.outputs.cluster_security_group_id]
      self = false
  } ]
  egress = [ 
    {
      description      = "ssh from everywhere"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]
  tags = {
    Name = "${var.project} - DB SG"
  }
}