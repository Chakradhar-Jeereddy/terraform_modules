module "chakra" {
    source = "../modules"
    instance_type = var.instance_type
    ami = var.ami
}

