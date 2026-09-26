output "ami" {
  value = module.chakra.ami
}

output "instance_id" {
    value = module.chakra.instance_id
}

output "private_ip" {
   value = module.chakra.private_ip
}