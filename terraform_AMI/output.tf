output "ami_id" {
  value       = aws_ami.from_existing_instance.id
  description = "The ID of the created AMI"
}
