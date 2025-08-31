# creating an security group for SSH login
resource "aws_security_group" "sg_ssh" {
  name = "sg_ssh"
  description = "Allow SSH access"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg_ssh"
  }
}


# creating an security group for web login.
resource "aws_security_group" "sg_web" {
    name = "sg_web"
    description = "Allow for web access"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }

    tags = {
      Name = "sg_web"
    }
}