variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}
variable "create_alb" {
  description = "Whether to create ALB and target group"
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The ID of the VPC to use"
  type        = string

  validation {
    condition     = length(var.vpc_id) > 0
    error_message = "vpc_id cannot be empty. Please provide a valid VPC ID."
  }
}

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
}

variable "tg_name" {
  description = "Name of the TargetGroup Name"
  type        = string
}
