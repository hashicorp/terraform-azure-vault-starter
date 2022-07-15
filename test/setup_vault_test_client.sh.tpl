#!/usr/bin/env bash
# Copyright © 2014-2022 HashiCorp, Inc.
#
# This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
#

set -e -o pipefail

# install package

curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt-get update
apt-get install -y python3-pip vault=${vault_version}

# install azure-cli
# the azure-cli package in Ubuntu universe repo would be ideal, but it is broken in the Ubuntu 20.04 universe repo
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt#overview
# instead, it is installed here via pypi (by way of the python3-pip package installed above)
pip3 install --no-warn-script-location --user 'azure-cli~=2.26.0' 'azure-mgmt-core~=1.2.0' 'cryptography~=3.3.2' 'urllib3[secure]~=1.26.5' 'requests~=2.25.1'

# configuring Azure CLI for use with VM managed identity
~/.local/bin/az login --identity

echo "Configuring system time"
timedatectl set-timezone UTC

# removing any default installation files from /opt/vault/tls/
rm -rf /opt/vault/tls/*

# /opt/vault/tls should be readable by all users of the system
chmod 0755 /opt/vault/tls

# vault-key.pem should be readable by the vault group only
touch /opt/vault/tls/vault-key.pem
chown root:vault /opt/vault/tls/vault-key.pem
chmod 0640 /opt/vault/tls/vault-key.pem

secret_result=$(~/.local/bin/az keyvault secret show --id "${key_vault_secret_id}" --query "value" --output tsv)

echo $secret_result | base64 -d | openssl pkcs12 -clcerts -nokeys -passin pass: | openssl x509 -out /opt/vault/tls/vault-cert.pem
echo $secret_result | base64 -d | openssl pkcs12 -cacerts -nokeys -chain -passin pass: | openssl x509 -out /opt/vault/tls/vault-ca.pem
echo $secret_result | base64 -d | openssl pkcs12 -nocerts -nodes -passin pass: | openssl pkcs8 -nocrypt -out /opt/vault/tls/vault-key.pem

echo "${lb_backend_ca_cert}" >> /etc/ssl/certs/ca-certificates.crt
echo "${lb_private_ip_address} ${leader_tls_servername}" >> /etc/hosts

cat << EOH > /etc/profile.d/vault.sh
export VAULT_ADDR="https://${leader_tls_servername}:8200"
export VAULT_CACERT="/opt/vault/tls/vault-ca.pem"
export VAULT_CLIENT_CERT="/opt/vault/tls/vault-cert.pem"
export VAULT_CLIENT_KEY="/opt/vault/tls/vault-key.pem"
EOH
