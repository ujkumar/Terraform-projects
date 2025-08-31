# Terraform output values......

# output for public ip
output "aws_instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.ec2_instance.public_ip
  }

# output for public dns
output "aws_instance_public_dns" {
  description = "The public dns address of the EC2 instance"
  value       = aws_instance.ec2_instance.public_dns
}