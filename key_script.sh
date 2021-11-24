#!/bin/bash

curl -X GET "https://api.digitalocean.com/v2/account/keys?page=3" -H "Authorization: Bearer $TF_VAR_DO_token" | jq  '.ssh_keys[] | select(.name == "REBRAIN.SSH.PUB.KEY") | {fingerprint}'
