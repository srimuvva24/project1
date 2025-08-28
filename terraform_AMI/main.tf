provider "aws" {
  region = "us-east-1"
}

# Create AMI from existing instance
resource "aws_ami" "from_existing_instance" {
  name               = "my-ami-from-${var.ec2_instance_id}-${timestamp()}"
  source_instance_id = var.ec2_instance_id
  description        = "AMI created from EC2 instance ${var.ec2_instance_id}"
  # Optional: reboot the instance before creating AMI
  reboot = true

  tags = {
    Name = "AMI-from-${var.ec2_instance_id}"
  }
}

# Output the AMI ID
output "ami_id" {
  value       = aws_ami.from_existing_instance.id
  description = "The ID of the created AMI"
}
