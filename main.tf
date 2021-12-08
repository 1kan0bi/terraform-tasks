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
    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "aws" {
  region     = "us-west-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "digitalocean_tag" "ter02" {
  name = "bulutovstas_at_mail_ru"
}

resource "random_string" "random" {
  count  = length(var.devs)
  length = 16
}

resource "digitalocean_droplet" "ter02" {
  count    = length(var.devs)
  image    = "ubuntu-18-04-x64"
  name     = "ubuntu-${format("%02d", count.index + 1)}"
  region   = "ams3"
  size     = "s-1vcpu-1gb"
  tags     = [digitalocean_tag.ter02.name]
  ssh_keys = ["${digitalocean_ssh_key.my_ssh_key.fingerprint}", "${data.digitalocean_ssh_key.rebrain_key.fingerprint}"]

provisioner "remote-exec" {
 
script = "${path.module}/script-${count.index}.sh"

  connection {
    type        = "ssh"
    user        = "root"
    host        = self.ipv4_address
    private_key = file(var.private_ssh_key)
    script_path = "/root/script.sh"
  }
}
}
resource "aws_route53_record" "domain" {
  count   = length(var.devs)
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.devs[count.index].login}-${var.devs[count.index].prefix}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = ["${element(digitalocean_droplet.ter02.*.ipv4_address, count.index)}"]
}

resource "digitalocean_ssh_key" "my_ssh_key" {
  name       = "my ssh key"
  public_key = var.ssh_key
}


data "digitalocean_ssh_key" "rebrain_key" {
  name = "REBRAIN.SSH.PUB.KEY"
}

data "aws_route53_zone" "selected" {
  name = "devops.rebrain.srwx.net"
}

data "template_file" "my_machines" {
  template = file("${path.module}/services.tmpl")
  count    = length(var.devs)
  vars = {
    dns      = aws_route53_record.domain[count.index].name
    number   = count.index + 1
    ip       = digitalocean_droplet.ter02[count.index].ipv4_address
    password = random_string.random[count.index].result
  }
}

data "template_file" "script_tpml" {

  template = file("${path.module}/pass_script.tmpl")
  count    = length(var.devs)
  vars = {
    machine_pass = random_string.random[count.index].result
  }

}

resource "local_file" "pass_script" {
  count    = length(var.devs)
  filename = "${path.module}/script-${count.index}.sh"
  content  = data.template_file.script_tpml[count.index].rendered
}
resource "local_file" "foo" {
  filename = "${path.module}/created_services.txt"
  content  = <<-EOT
%{for temp in data.template_file.my_machines.*.rendered}${temp}%{endfor}
EOT
}

output "droplet_output" {
  value = digitalocean_droplet.ter02.*.ipv4_address
}

output "aws_output" {
  value = aws_route53_record.domain.*.name
}

output "password_output" {
  value = random_string.random.*.result
}
