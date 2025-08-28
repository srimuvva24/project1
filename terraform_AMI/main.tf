# Create AMI from existing instance
resource "aws_ami_from_instance" "example" {
  name               = "my-ami-${var.ec2_instance_id}-${formatdate("YYYYMMDD", timestamp())}"
  source_instance_id = var.ec2_instance_id
  description        = "AMI created from EC2 instance ${var.ec2_instance_id}"
  
  tags = {
    Name = "AMI-from-${var.ec2_instance_id}"
  }
}
