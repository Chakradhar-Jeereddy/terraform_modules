variable "ami_id" {
    type = string
    default = "ami-0220d79f3f480ecf5"
    description = "This is the AMI used for creating EC2 instance"
}

variable "instance_type" {
    type = string
    description = "This is the AMI used for creating EC2 instance"
    validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Please select either t3 micro or small or medium"
  }
}

variable "tags" {
    type = map 
    default = {}
}