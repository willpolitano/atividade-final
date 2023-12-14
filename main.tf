terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-west-2"
}

resource "aws_instance" "app_server" {
  ami           = "ami-03d5c68bab01f3496"
  instance_type = "t2.micro"
  key_name = "chave-ssh"

  vpc_security_group_ids = [
    "acesso_geral"
  ] 
}

resource "aws_key_pair" "chaveSSH" {
    key_name = "chave-ssh"
    public_key = file("./keys/keys.pub")
}

resource "aws_security_group" "acesso_geral" {
  name = "acesso_geral"
  description = "grupo do Dev"
  ingress{
      cidr_blocks = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
      from_port = 0
      to_port = 0
      protocol = "-1"
  }
  egress{
      cidr_blocks = [ "0.0.0.0/0" ]
      ipv6_cidr_blocks = [ "::/0" ]
      from_port = 0
      to_port = 0
      protocol = "-1"
  }
  tags = {
    Name = "acesso_geral"
  }
}

output "IP_publico" {
  value = aws_instance.app_server.public_ip
}