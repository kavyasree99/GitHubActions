terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.92.0"
    }
  }

  backend "s3" {
    bucket         = "tf-state-s3-bucket-gha"
    key            = "ec2/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    #dynamodb_table = "tf-state-locks"   # optional but recommended for state locking
  }
}

provider "aws" {
  region = "ap-south-1"
}

## ec2 ##
resource "aws_instance" "web" {
  ami           = "ami-0861f4e788f5069dd"
  instance_type = "t3.micro"

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

output "instance_public_ip" {
  value       = aws_instance.web.public_ip
  description = "EC2 instance public IP"
}
