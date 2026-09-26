resource "aws_instance" "takka" {
  ami  = var.ami
  instance_type = var.instance_type

  tags = var.tags
}