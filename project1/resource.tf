resource "aws_instance" "apache_server" {
  ami = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
  user_data = file("${path.module}/install_apache.sh")
  tags = {
    Name = "ApacheServerInstance"
  }
}