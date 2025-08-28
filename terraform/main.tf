terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.92.0"
    }
  }

  backend "s3" {
    bucket         = "tf-state-s3-bucket-gha-kavs-2025"    # Ensure this bucket exists
    key            = "ec2/terraform.tfstate"              # State file path in S3
    region         = "ap-south-1"
    encrypt        = true
    #dynamodb_table = "tf-state-locks"                     # Recommended for state locking
  }
}

provider "aws" {
  region = "ap-south-1"
}

# -------------------------------
# Get Default VPC and Subnet Data
# -------------------------------
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# -------------------------------
# EC2 Instance
# -------------------------------
resource "aws_instance" "web" {
  ami           = "ami-0861f4e788f5069dd"  # Ensure AMI is valid in ap-south-1
  instance_type = "t3.micro"
  subnet_id     = "subnet-093a924eb18ee558c"

  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "Hello, World!" > /var/www/html/index.html
  EOF

  tags = {
    Name = "HelloWorld"
  }
}

# -------------------------------
# Output the EC2 Public IP
# -------------------------------
output "instance_public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of the EC2 instance"
}
