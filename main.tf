terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>3.0"
    }
  }
}
#Configure the AWS provider
provider "aws" {
  region     = "us-east-2"
  access_key = ""
  secret_key = ""
}

#create VPC
resource "aws_vpc" "my-lab-vpc" {
  cidr_block = var.cidr_block[0]

  tags = {
    Name = "my-lab-vpc"
  }
}
#create subnet
resource "aws_subnet" "my-lab-subnet1" {
  vpc_id     = aws_vpc.my-lab-vpc.id
  cidr_block = var.cidr_block[1]
  tags = {
    Name = "my-lab-subnet1"
  }
}
#Create internet gateway
resource "aws_internet_gateway" "my-lab-internetgw" {
  vpc_id = aws_vpc.my-lab-vpc.id
  tags = {
    Name = "my-lab-internetgw"
  }
}
#Create security grp
resource "aws_security_group" "my-lab-secugrp" {
  name        = "my lab security grp"
  description = "for rules"
  vpc_id      = aws_vpc.my-lab-vpc.id
  dynamic "ingress" {
    iterator = port
    for_each = var.ports
    content {
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = port.value
      protocol    = "TCP"
      to_port     = port.value
    }

  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
  tags = {
    name = "allow everything"
  }
}
#create route table and resources
resource "aws_route_table" "my-lab-routetable" {
  vpc_id = aws_vpc.my-lab-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-lab-internetgw.id
  }
}

#create route table assosi
resource "aws_route_table_association" "my-lab-route-tb-assos" {
  subnet_id      = aws_subnet.my-lab-subnet1.id
  route_table_id = aws_route_table.my-lab-routetable.id
}
#create instance- kuberntes master01

resource "aws_instance" "tesing-resources1" {
  ami                         = data.aws_ami.dev_ami.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.devopsdxb.key_name
  user_data                   = file("./installmaster.sh")
  vpc_security_group_ids      = [aws_security_group.my-lab-secugrp.id]
  subnet_id                   = aws_subnet.my-lab-subnet1.id
  associate_public_ip_address = true
  tags = {
    Name = "master01"
  }
}
resource "aws_key_pair" "devopsdxb" {
  key_name   = "devopsdxb"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAqWWKLK7A9OHLJcyTBXmN83TCuejjGyWeHfQWyLDqlcdlv1Z7ngB68IdF0QPaLIQCFYFXigKl8e00O4YWKpASgDdFhvBWvO4UGuh3peXlxG5H6wJ3SwcTd38cTIDUbRoOO5S/PsXq4kU/zuY1sLYWxfo++0GTqLlM7tnWWmX++w6pgp4kAfqZ12/OuZRYoGD/qCFIte0Seajuo+7pxmomrpfb6mJlIHAI/ZEIjqZUcCs5qI5oZAHGDXuLuynL6aq9fjQWrInH8R5f3Ze5PyBpd5m1yVPspk+wOpqLmLoLk4jT2xmFbWLVATQm8NvKtnwRsZbdM8LZyIlZOKg4/l82aQ== rsa-key-20220823"
}

data "aws_ami" "dev_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel*"]
  }

}
#create worker instace
resource "aws_instance" "tesing-resources2" {
  ami                         = data.aws_ami.dev_ami.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.devopsdxb.key_name
  user_data                   = file("./installworker01.sh")
  vpc_security_group_ids      = [aws_security_group.my-lab-secugrp.id]
  subnet_id                   = aws_subnet.my-lab-subnet1.id
  associate_public_ip_address = true
  tags = {
    Name = "worker01"
  }
}
resource "aws_instance" "tesing-resources3" {
  ami                         = data.aws_ami.dev_ami.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.devopsdxb.key_name
  user_data                   = file("./installworker02.sh")
  vpc_security_group_ids      = [aws_security_group.my-lab-secugrp.id]
  subnet_id                   = aws_subnet.my-lab-subnet1.id
  associate_public_ip_address = true
  tags = {
    Name = "worker02"
  }
}
