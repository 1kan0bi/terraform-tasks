terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_tag" "ter02" {
  name = "bulutovstas_at_mail_ru"
}

resource "random_string" "random" {
  count  = var.count_of_servers
  length = 16
}

resource "digitalocean_droplet" "ter02" {
  count    = var.count_of_servers
  image    = "ubuntu-18-04-x64"
  name     = "ubuntu-${format("%02d", count.index + 1)}"
  region   = "ams3"
  size     = "s-1vcpu-1gb"
  tags     = [digitalocean_tag.ter02.name]
  ssh_keys = ["${digitalocean_ssh_key.my_ssh_key.fingerprint}", "${data.digitalocean_ssh_key.rebrain_key.fingerprint}"]

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "echo root:${random_string.random[count.index].result} | chpasswd"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      host        = self.ipv4_address
      private_key = file("~/.ssh/id_rsa_DO_keys/id_rsa_DO")
    }
  }
}

resource "digitalocean_ssh_key" "my_ssh_key" {
  name       = "my ssh key"
  public_key = var.ssh_key
}

provider "aws" {
  region     = "us-west-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_route53_record" "domain" {
  count   = var.count_of_servers
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.devs[1]}-${var.devs[0]}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = ["${element(digitalocean_droplet.ter02.*.ipv4_address, count.index)}"]
}

data "digitalocean_ssh_key" "rebrain_key" {
  name = "REBRAIN.SSH.PUB.KEY"
}

data "aws_route53_zone" "selected" {
  name = "devops.rebrain.srwx.net"
}

output "droplet_output" {
  value = digitalocean_droplet.ter02.*.ipv4_address
}

output "aws_output" {
  value = aws_route53_record.domain.*
}

output "password_output" {
  value = random_string.random.*.result
}
