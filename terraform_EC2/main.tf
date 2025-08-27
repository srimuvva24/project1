provider "aws" {
  region = "us-east-2"   # Change to your region
}

# Security Group allowing HTTP (8000) and SSH
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow SSH and HTTP 8000"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Instance
resource "aws_instance" "web" {
  ami           = "ami-0863fb82a7836e852"  # Amazon Linux 2 AMI (update for your region)
  instance_type = "t2.micro"
  key_name      = "mytest"   # Using your existing key
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
    #!/bin/bash
    cd /home/ec2-user/tech-challenge-flask-app-main
    source venv/bin/activate
    export TC_DYNAMO_TABLE=Candidates
    nohup gunicorn -b 0.0.0.0:8000 app:candidates_app &
  EOF

  tags = {
    Name = "flask-web-app"
  }
}

