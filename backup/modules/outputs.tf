output "public_ip" {
    value = aws_instance.mod_instance.public_ip
    description = "Public IP of the instance created"
}

output "private_ip" {
    value = aws_instance.mod_instance.private_ip
    description = "rivate IP of the instance created"
}

output "instance_id" {
  value = aws_instance.mod_instance.id
}