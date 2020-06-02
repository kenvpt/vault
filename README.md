# vault

REQUIREMENTS BEFORE RUNNING TERRAFORM
1. An ec2 instance that has admin role attach to it.
2. the ec2 intance must have terraform downloaded. see https://www.terraform.io/downloads.html
3. download aws cli
4. create a public key in your instance. (ssh-keygen command)

In terraform.tfvars, you can change the values you prefer for any variables listed there. 
- userdata variable must have the right full path of the file "vault_server"


