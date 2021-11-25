terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_tag" "ter02" {
  name = "bulutovstas_at_mail_ru"
}
resource "digitalocean_droplet" "ter02" {
  image    = "ubuntu-18-04-x64"
  name     = "ter-task-02"
  region   = "ams3"
  size     = "s-1vcpu-1gb"
  tags     = [digitalocean_tag.ter02.name]
  ssh_keys = ["${digitalocean_ssh_key.my_ssh_key.fingerprint}", "${data.external.ter02.result.fingerprint}"]
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

resource "aws_route53_record" "bulutovstas" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "bulutovstas.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = [digitalocean_droplet.ter02.ipv4_address]
}

data "external" "ter02" {
  program = ["bash", "${path.module}/key_script.sh"]
}

data "aws_route53_zone" "selected" {
  name         = "devops.rebrain.srwx.net"
}

output "droplet_output" {
  value = digitalocean_droplet.ter02.ipv4_address
}
