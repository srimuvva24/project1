# terraform-alb-vpc:

This Terraform project creates an AWS networking setup along with an Application Load Balancer (ALB).

🚀 What This Code Does

Creates a new VPC

Creates multiple Public Subnets (based on variables)

Creates an Internet Gateway and attaches it to the VPC

Creates a Public Route Table and associates it with subnets

Creates a Security Group for the ALB

Provisions an Application Load Balancer (ALB)

Creates a Target Group with health checks

Creates a Listener to forward traffic to targets
