# =============================================================================
# Terraform Test File with Intentional Errors
# Tests for tflint and terraform fmt
# =============================================================================

# Error: Missing terraform version constraint
terraform {
  # required_version = ">= 1.0"  # Missing version constraint
  required_providers {
    aws = {
      source = "hashicorp/aws"
      # version = "~> 5.0"  # Missing version constraint
    }
  }
}

# Error: Provider without version constraint
provider "aws" {
  region = "us-east-1"  # Hardcoded region
  # profile = var.aws_profile  # Should use variable
}

# Error: Missing variable description and type
variable "instance_type" {
  # description = "EC2 instance type"  # Missing description
  # type        = string               # Missing type
  default = "t2.micro"
}

# Error: Variable with no default and not marked as required
variable "environment" {
  # No default value and no description
}

# Error: Output without description
output "instance_id" {
  value = aws_instance.example.id
  # description = "ID of the EC2 instance"  # Missing description
}

# Error: Resource with hardcoded values
resource "aws_instance" "example" {
  ami           = "ami-12345678"  # Hardcoded AMI
  instance_type = "t2.micro"      # Hardcoded instead of using variable
  
  # Error: Using deprecated argument
  network_interface {
    device_index = 0
    network_interface_id = "eni-12345"
  }
  
  # Error: Missing required tags
  # tags = {
  #   Name        = "Example Instance"
  #   Environment = var.environment
  # }
}

# Error: Using count instead of for_each for resources with unique configurations
resource "aws_instance" "counted" {
  count         = 3
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  # Should use for_each for better resource management
}

# Error: Security group with overly permissive rules
resource "aws_security_group" "too_open" {
  name = "too-open-sg"
  
  # Error: Open to the world
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open to internet
  }
  
  # Error: All traffic allowed
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # All protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Error: S3 bucket without encryption
resource "aws_s3_bucket" "insecure" {
  bucket = "my-insecure-bucket-12345"  # Hardcoded bucket name
  
  # Missing server_side_encryption_configuration
  # Missing versioning
  # Missing lifecycle rules
}

# Error: S3 bucket ACL allowing public access
resource "aws_s3_bucket_acl" "public" {
  bucket = aws_s3_bucket.insecure.id
  acl    = "public-read"  # Public access
}

# Error: IAM policy with wildcards
resource "aws_iam_policy" "too_permissive" {
  name = "overly-permissive-policy"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"  # All actions
        Resource = "*"  # All resources
      }
    ]
  })
}

# Error: RDS instance without backup
resource "aws_db_instance" "no_backup" {
  identifier     = "mydb"
  engine         = "mysql"
  engine_version = "5.7"  # Old version
  instance_class = "db.t2.micro"
  
  # Error: Credentials in plain text
  username = "admin"
  password = "password123"  # Hardcoded password!
  
  # Error: No backup configuration
  backup_retention_period = 0  # No backups
  skip_final_snapshot    = true  # No final snapshot
  
  # Error: Not encrypted
  storage_encrypted = false
}

# Error: Using data source without proper error handling
data "aws_ami" "example" {
  most_recent = true
  owners      = ["self"]
  
  # No filter specified - might return unexpected results
}

# Error: Local values with complex expressions
locals {
  # Error: Using complex conditionals without proper formatting
  environment_prefix = var.environment == "prod" ? "production" : var.environment == "staging" ? "staging" : "development"
  
  # Error: Referencing potentially null values
  instance_name = "${var.environment}-${aws_instance.example.id}"
}

# Error: Module without version constraint
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  # version = "5.0.0"  # Missing version
  
  # Missing required variables
}

# Error: Resource with deprecated interpolation syntax
resource "aws_instance" "old_syntax" {
  ami           = "${var.ami_id}"  # Old interpolation syntax
  instance_type = "${var.instance_type}"
  
  tags = {
    Name = "${var.environment}-instance"  # Unnecessary interpolation
  }
}

# Error: Null resource with local-exec (often antipattern)
resource "null_resource" "local_exec" {
  provisioner "local-exec" {
    command = "echo 'This is often an antipattern'"
  }
  
  # No triggers defined
}

# Error: Random password without keeper
resource "random_password" "db_password" {
  length  = 8  # Too short for production
  special = false  # Weak password
  # No keepers to track changes
}

# Error: For expression without proper filtering
locals {
  # Error: Not handling potential null values
  instance_ids = [for i in aws_instance.counted : i.id]
}

# Error: Dynamic block without proper conditions
resource "aws_security_group" "dynamic_rules" {
  name = "dynamic-sg"
  
  dynamic "ingress" {
    for_each = var.ingress_rules  # var.ingress_rules might be null
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

# Error: Conditional resource creation without proper count
resource "aws_instance" "conditional" {
  # count = var.create_instance ? 1 : 0  # Should use this pattern
  
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}

# Error: Backend configuration in main file (should be separate)
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
    # Missing encryption and state locking
  }
}

# Error: Provider alias without clear naming
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

# Error: Resource without lifecycle management
resource "aws_instance" "no_lifecycle" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  # Should consider:
  # lifecycle {
  #   create_before_destroy = true
  #   prevent_destroy       = true
  # }
}

# Error: Map variable without proper validation
variable "instance_types" {
  type = map(string)
  default = {
    dev  = "t2.micro"
    prod = "t2.micro"  # Prod should probably be larger
  }
  # No validation block
}

# Error: Sensitive variable without marking
variable "api_key" {
  type    = string
  default = "secret-key-123"  # Default for sensitive value!
  # sensitive = true  # Should be marked sensitive
}

# Error: Data source depending on resource (circular dependency risk)
data "aws_instance" "lookup" {
  instance_id = aws_instance.example.id  # Depends on resource
}

# Error: Missing moved blocks for refactored resources
# Should use moved blocks when renaming resources

# Error: Import block without proper configuration
# import {
#   to = aws_instance.example
#   id = "i-1234567890abcdef0"
# }

# Error: Check block without proper assertions (Terraform 1.5+)
# check "health_check" {
#   assert {
#     condition     = aws_instance.example.instance_state == "running"
#     error_message = "Instance is not running"
#   }
# }

# Error: Variable validation with poor error message
variable "instance_count" {
  type = number
  validation {
    condition     = var.instance_count > 0
    error_message = "Invalid"  # Poor error message
  }
}

# Error: Using terraform_remote_state without proper error handling
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-state"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
  # No outputs validation
}

# Error: Resource with embedded inline policies
resource "aws_iam_role" "inline_policies" {
  name = "role-with-inline-policies"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  
  # Inline policies should be separate resources
  inline_policy {
    name = "inline-policy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["s3:*"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
}

# Error: Using depends_on unnecessarily
resource "aws_instance" "dependent" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  depends_on = [aws_security_group.too_open]  # Often unnecessary
}

# Error: Formatting issues (terraform fmt will fix these)
resource    "aws_instance"    "formatting" {
ami = "ami-12345678"
  instance_type= "t2.micro"
    tags ={
Name="BadlyFormatted"
    Environment = "test"
}
}

# Error: Comments in wrong places
resource "aws_instance" /* inline comment */ "commented" {
  ami = "ami-12345678" # End of line comment in resource block
  instance_type = /* another inline */ "t2.micro"
}
