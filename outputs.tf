output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = aws_instance.ec2_instance.id
}

output "instance_public_ip" {
  description = "The public IP of the EC2 instance"
  value       = aws_instance.ec2_instance.public_ip
}

output "ssm_instance_role_name" {
  description = "The IAM instance profile role"
  value       = aws_iam_role.ssm_role.name
}
