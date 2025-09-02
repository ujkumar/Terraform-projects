# Creating an EC2 instance
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ami_details.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.sg_ssh.id, aws_security_group.sg_web.id]
  user_data              = templatefile("${path.module}/install_apache.sh", {})
  

tags = {
    Name = "Ec2 Resource Provisioning using terraform.."
  }
}
