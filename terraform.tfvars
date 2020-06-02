region = "us-east-2"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidr = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
]
instance_type = "t2.micro"
tags = {
   Name = "Vault_Server"
}

key_name = "bastion_key"
public_key_path = "~/.ssh/id_rsa.pub"
userdata = "/home/centos/vault/vault_server"