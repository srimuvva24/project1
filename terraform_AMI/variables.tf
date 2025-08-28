variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

# Input variable for the existing EC2 instance ID
variable "ec2_instance_id" {
  description = "The ID of the existing EC2 instance to create an AMI from"
  type        = string
}
