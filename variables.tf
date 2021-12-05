variable "do_token" {
  type        = string
  description = "DigitalOcean token"
}

variable "ssh_key" {
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC3bzMRba74RNonnt79crON4QegCbwGXheaUtR0L0jCPf3+Ge4URvyT+KuJci3f6XwijCfOU5tAxcX81v6HHKum6DLt8d0afbKqMWC4NmNZJKO1sMLVSzgF/9FXd72iCq5qEmTG6Fy9OY09jlZf6PUc/hcVKeEN00m4c6qHrUL5BAQe90U5/cRrGkbaOHIOXhri3XvOIEzoCBezsLGDutvaLtxHRQV5POk4zkc/N1WKCu04Jz+TzVLtOTyReShYp5IdAjrKV0YTewOSxLydRvMoxs3XbJ3R+FHW/2gvMN0jK5rHCRjqwJT6mZXGSbcJjvv95SfnA+tNijAn7IG+hDQiTOfoMSwB+uTiLCjP/TaIcnBdESFMfGB/aob6zaYGjJxDDHZ/+8HCa/KJ015cRpjQh/0fHHyxB+OhRNbZBCHuIQQyJF0z/BE8gXa+/mtZ3rgSZlRQOMWKw+Iv3gboVLmvM8OaGtBmPJ9qyVvipBSX2dQowUDH1mViAc4uzohuHx0= kanobi@LAPTOP-8LVA9EO9"
  description = "Public ssh-key"

}
variable "secret_key" {
  type        = string
  description = "My secret AWS key"

}
variable "access_key" {
  type        = string
  description = "My access AWS key"

}

variable "count_of_servers" {
  type        = number
  description = "Count of created servers"
}

variable "private_ssh_key" {
type = string
description = "Private SSH key for execute commands"

}
