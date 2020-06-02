variable "region" {}
variable "vpc_cidr"{}
variable "public_subnet_cidr"{}
variable "instance_type"{}

variable "tags"{
    type = "map"
}

variable "key_name"{}
variable "public_key_path"{}
variable "userdata"{}