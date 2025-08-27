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
