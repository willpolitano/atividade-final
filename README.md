# ATIVIDADE FINAL COM UBUNTU

## INSTALAÇÕES

#### Atualizando os pacotes
```sh
sudo apt update
```

#### Instalando AWS CLI
```sh
sudo apt install awscli
```

#### Instalando TERRAFORM
```sh
wget https://releases.hashicorp.com/terraform/1.1.0/terraform_1.1.0_linux_amd64.zip
unzip terraform_1.1.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

#### Instalando ANSIBLE
```sh
sudo apt install ansible
```

## CONFIGURAR O AWS CLI
#### Crie e acesse o arquivo
```sh
vim ~/.aws/credentials
```
#### Insira as credenciais do seu laboratório
```sh
[default]
aws_access_key_id = seuAccessKey
aws_secret_access_key = seuSecretAccess
aws_session_token = seuSessionToken
```

### CRIAR O PROJETO
#### Crie a pasta atividade-final
```sh
mkdir atividade-final
```

#### Acesse a pasta atividade-final
```sh
cd atividade-final
```

#### Crie e acesse o arquivo main
```sh
vim main.tf
```

#### Insira o código abaixo
```sh
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
```
#### Crie e acesse o arquivo playbook
```sh
vim playbook.yml
```

#### Insira o código abaixo
```sh
---
    - hosts: webservers
      become: true
      vars:
        container_count: 1
        default_container_name: web-server
        default_container_image: nginx
        default_container_command: sleep 1d

      tasks:
        - name: Install aptitude
          apt:
            name: aptitude
            state: latest
            update_cache: true

        - name: Install required system packages
          apt:
            pkg:
              - apt-transport-https
              - ca-certificates
              - curl
              - software-properties-common
              - python3-pip
              - virtualenv
              - python3-setuptools
              - git
            state: latest
            update_cache: true

        - name: Add Docker GPG apt Key
          apt_key:
            url: https://download.docker.com/linux/ubuntu/gpg
            state: present

        - name: Add Docker Repository
          apt_repository:
            repo: deb https://download.docker.com/linux/ubuntu focal stable
            state: present

        - name: Update apt and install docker-ce
          apt:
            name: docker-ce
            state: latest
            update_cache: true

        - name: Add "ansible_ubuntu_demo" user to "docker" group
          remote_user: ubuntu
          user:
            name: "ubuntu"
            groups: "docker"
            append: yes
          tags:
            - docker

        - name: Clone Voting App project
          git:
            repo: https://github.com/Azure-Samples/azure-voting-app-redis.git
            dest: /home/ubuntu/azure-voting-app-redis
            version: master

        - name: Change to project directory
          become: false
          shell: cd /home/ubuntu/azure-voting-app-redis

        - name: Install docker-compose
          get_url:
            url: https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64
            dest: /usr/local/bin/docker-compose
            mode: '755'

        - name: Run Docker Compose
          become: true
          shell: docker-compose up -d
          args:
            chdir: /home/ubuntu/azure-voting-app-redis
```

#### Crie e acesse o arquivo hosts
```sh
vim hosts
```

#### Insira o código abaixo
```sh
[webservers]
ec2-SEU-IP.us-west-2.compute.amazonaws.com ansible_ssh_user=ubuntu ansible_ssh_private_key_file=./keys/keys
```

## CONFIGURAR O PAR DE CHAVES
#### Crie a pasta keys
```sh
mkdir keys
```
#### Acesse a pasta keys
```sh
cd keys
```
#### Gere o par de chaves
```sh
ssh-keygen
```
#### Especifique o caminho onde suas chaves devem ser criadas
```sh
./keys
```
## EXECUTAR O TERRAFORM
#### Acesse a pasta atividade-final
```sh
cd ..
```
#### Inicie o terraform
```sh
terraform init
```
#### Valide o conteudo e sintaxe do arquivo
```sh
terraform validate
```
#### Crie um plano de execução
```sh
terraform plan
```
#### Aplique as alterações planejadas
```sh
terraform apply
```
## EXECUTAR O PLAYBOOK COM ANSIBLE
#### Execute o playbook especificando o iventário
```sh
ansible-playbook -i hosts playbook.yml
```
