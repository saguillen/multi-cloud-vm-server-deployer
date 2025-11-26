provider "aws" {
  region = "us-east-2"
}

# Security Group
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for web server"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere for now
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-0c1c30571d2dae5c9" # Amazon Linux 2023
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from AWS EC2 via Terraform</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "web-server-aws"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}