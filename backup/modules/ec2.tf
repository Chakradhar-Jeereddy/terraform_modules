resource "aws_instance" "mod_instance" {
  ami           = local.ami_id
  instance_type = var.instance_type

  tags = var.tags # optional
}