#TODO Hardcoded values in this module 
resource "aws_instance" "tunnel" {
  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = ["${var.tunnel_sg}"]
  subnet_id              = var.public_subnets[0]

  key_name             = var.key_name
  iam_instance_profile = "sandbox_ec2_role"

  tags = {
    Name = "${var.namespace}-tunnel"
  }
}

resource "aws_eip" "public_ip" {
  instance = aws_instance.tunnel.id
}