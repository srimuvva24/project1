provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group allowing HTTP (8000) and SSH
resource "aws_security_group" "web_sg" {
  name        = "web-sg-1"
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

# IAM Role Profile
resource "aws_iam_instance_profile" "existing_role_profile" {
  name = "ec2-instance-profile"
  role = "mypocrole"
}

# EC2 Instances in two AZs
resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0863fb82a7836e852"
  instance_type = "t2.micro"
  key_name      = "mytest"
  security_groups = [aws_security_group.web_sg.name]
  iam_instance_profile = aws_iam_instance_profile.existing_role_profile.name
  availability_zone = element(["us-east-2a", "us-east-2b"], count.index)

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
  name               = "flask-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
 # pick all default subnets
  subnets = data.aws_subnets.default.ids

  tags = {
    Name = "flask-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  count    = var.create_alb ? 1 : 0
  name     = "flask-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    port                = "8000"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = {
    Name = "flask-tg"
  }
}

# Attach EC2s to Target Group
resource "aws_lb_target_group_attachment" "tg_attach" {
  count            = var.create_alb ? length(aws_instance.web) : 0
  target_group_arn = aws_lb_target_group.app_tg[0].arn
  target_id        = aws_instance.web[count.index].id
  port             = 8000
}

# Listener for ALB (redirect HTTP 80 to target group)
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

