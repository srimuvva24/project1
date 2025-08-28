output "ami_id" {
  value       = aws_ami_from_instance.example.id
  description = "The ID of the created AMI"
}
