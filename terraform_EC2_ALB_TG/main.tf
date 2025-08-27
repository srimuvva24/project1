# ---------------------------
# Provider
# ---------------------------
provider "aws" {
  region = "us-east-2"
}

# ---------------------------
# Data sources for custom VPC
# ---------------------------
data "aws_vpc" "custom" {
  id = "vpc-01a41952ad8fdc4f9"  # Your custom VPC
}

data "aws_subnets" "custom" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.custom.id]
  }
}

# ---------------------------
# Use existing IAM instance profile
# ---------------------------
data "aws_iam_instance_profile" "existing_role_profile" {
  name = "ec2-instance-profile"
}

# ---------------------------
# Security Group
# ---------------------------
resource "aws_security_group" "web_sg" {
  name        = "web-sg-3"
  description = "Allow SSH, HTTP 80, and HTTP 8000"
  vpc_id      = data.aws_vpc.custom.id

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

  ingress {
    from_port   = 80
    to_port     = 80
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

# ---------------------------
# EC2 Instances
# ---------------------------
resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0863fb82a7836e852"  # Amazon Linux 2 in us-east-2
  instance_type = "t2.micro"
  key_name      = "mytest"

  subnet_id              = element(data.aws_subnets.custom.ids, count.index)
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  iam_instance_profile   = data.aws_iam_instance_profile.existing_role_profile.name

  user_data = <<-EOF
    #!/bin/bash
    sudo -u ec2-user bash -c "cd /home/ec2-user/tech-challenge-flask-app-main && source venv/bin/activate && export TC_DYNAMO_TABLE=Candidates && nohup gunicorn -b 0.0.0.0:8000 app:candidates_app &"
  EOF

  tags = {
    Name = "flask-web-app-${count.index}"
  }
}

# ---------------------------
# Conditional ALB + Target Group
# ---------------------------
resource "aws_lb" "app_lb" {
  count              = var.create_alb ? 1 : 0
  name               = "flask-alb-2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = data.aws_subnets.custom.ids

  tags = {
    Name = "flask-alb-2"
  }
}

resource "aws_lb_target_group" "app_tg" {
  count    = var.create_alb ? 1 : 0
  name     = "flask-tg-2"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.custom.id

  health_check {
    path                = "/candidates"
    port                = "8000"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "flask-tg-2"
  }
}

# Attach EC2s to Target Group
resource "aws_lb_target_group_attachment" "tg_attach" {
  count            = var.create_alb ? length(aws_instance.web) : 0
  target_group_arn = aws_lb_target_group.app_tg[0].arn
  target_id        = aws_instance.web[count.index].id
  port             = 8000
}

# Listener for ALB (HTTP 80 → target group)
resource "aws_lb_listener" "http_listener" {
  count             = var.create_alb ? 1 : 0
  load_balancer_arn = aws_lb.app_lb[0].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg[0].arn
  }
}

# ---------------------------
# Output ALB DNS
# ---------------------------
output "alb_dns_name" {
  value       = var.create_alb ? aws_lb.app_lb[0].dns_name : "ALB not created"
  description = "DNS name of the ALB (if created)"
}
