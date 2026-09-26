output "ami" {
    value = aws_instance.takka.ami
}

output "private_ip" {
    value = aws_instance.takka.private_ip
}

output "instance_id" {
    value = aws_instance.takka.id
}