variable "instance_type" {
    type = string
}

variable "ami" {
    type = string
}

variable "tags" {
    type = map 
    default = {}
}

