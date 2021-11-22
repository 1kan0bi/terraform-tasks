terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.16.0"
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
  ssh_keys = ["${digitalocean_ssh_key.my_ssh_key.fingerprint}", "${data.digitalocean_ssh_key.ter02.fingerprint}"]
}

data "digitalocean_ssh_key" "ter02" {
  name       = "REBRAIN.SSH.PUB.KEY"
 }

resource "digitalocean_ssh_key" "my_ssh_key" {
  name       = "my ssh key"
  public_key = var.ssh_key
}


output "droplet_output" {
  value = digitalocean_droplet.ter02.ipv4_address
}

