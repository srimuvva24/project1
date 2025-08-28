# Create AMI from existing instance
resource "aws_ami" "from_existing_instance" {
  name               = "my-ami-from-${var.ec2_instance_id}-${timestamp()}"
  source_instance_id = var.ec2_instance_id
  description        = "AMI created from EC2 instance ${var.ec2_instance_id}"
  # Optional: reboot the instance before creating AMI
  reboot = false

  tags = {
    Name = "AMI-from-${var.ec2_instance_id}"
  }
}
