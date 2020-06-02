data "aws_availability_zones" "availability_zone" {}

data "aws_ami" "centos" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }
}
provider "aws" {
  region = "${var.region}"
}

#VPC
resource "aws_vpc" "my_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = "${merge(var.tags, map("Name", "my_vpc"))}"

}
#INTERNET GATEWAY
resource "aws_internet_gateway" "my_internet_gateway" {
    vpc_id = "${aws_vpc.my_vpc.id}"
    tags = "${merge(aws_vpc.my_vpc.tags, map("Name", "igw"))}"
}

resource "aws_key_pair" "my_key" { #this will have the key pairs for the instances
    key_name = "${var.key_name}"
    public_key = "${file(var.public_key_path)}"
    tags = "${merge(aws_vpc.my_vpc.tags, map("Name", "bastion_keypair"))}"
}

#SUBNETS PUBLIC

resource "aws_subnet" "public_subnet" {
    vpc_id = "${aws_vpc.my_vpc.id}"
    count = "${length(data.aws_availability_zones.availability_zone.names)}"
    cidr_block = "${element(var.public_subnet_cidr,count.index)}"
    map_public_ip_on_launch = true
    availability_zone = "${element(data.aws_availability_zones.availability_zone.names,count.index)}"
    tags = "${merge(aws_vpc.my_vpc.tags, map("Name", "public_subnet${count.index + 1}"))}"
    
}
resource "aws_route_table_association" "public_assoc" {
    count = "${length(data.aws_availability_zones.availability_zone.names)}"
    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_route_table" "public_rt" {
    vpc_id = "${aws_vpc.my_vpc.id}"
    tags = "${merge(aws_vpc.my_vpc.tags, map("Name", "public_rt"))}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.my_internet_gateway.id}"
    }

}   
resource "aws_instance" "my_instance" {
    instance_type = "${var.instance_type}"
    ami = "${data.aws_ami.centos.id}"
    count = "${length(data.aws_availability_zones.availability_zone.names)}"
    availability_zone = "${element(data.aws_availability_zones.availability_zone.names,count.index)}"
    tags = "${merge(aws_vpc.my_vpc.tags, map("Name", "vault_instance"))}"
    key_name = "${aws_key_pair.my_key.key_name}"
    vpc_security_group_ids = ["${aws_security_group.sg_http_https.id}","${aws_security_group.sg_ssh.id}"]
    subnet_id = "${element(aws_subnet.public_subnet.*.id, count.index)}"
    user_data = "${file(var.userdata)}"
}
resource "aws_security_group" "sg_http_https" {
    name = "sg_http_https"
    description = "http and https"
    vpc_id = "${aws_vpc.my_vpc.id}"
    tags = "${merge(aws_vpc.my_vpc.tags, map("Name", "http_https"))}"
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_security_group" "sg_ssh" {
    name = "sg_ssh"
    description = "ssh"
    vpc_id = "${aws_vpc.my_vpc.id}"
    tags = "${merge(aws_vpc.my_vpc.tags, map("Name", "ssh"))}"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}