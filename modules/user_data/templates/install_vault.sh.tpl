#!/usr/bin/env bash
set -e -o pipefail

export instance_name="$(curl -sH Metadata:true --noproxy '*' 'http://169.254.169.254/metadata/instance/compute/name?api-version=2020-09-01&format=text')"
export local_ipv4="$(curl -sH Metadata:true --noproxy '*' 'http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2020-09-01&format=text')"

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

cat << EOF > /etc/vault.d/vault.hcl
disable_performance_standby = true
ui = true
disable_mlock = true

storage "raft" {
  path    = "/opt/vault/data"
  node_id = "$instance_name"
  retry_join {
    auto_join = "provider=azure subscription_id=${subscription_id} resource_group=${resource_group_name} vm_scale_set=${vm_scale_set_name}"
    auto_join_scheme = "https"
    leader_tls_servername = "${leader_tls_servername}"
    leader_ca_cert_file = "/opt/vault/tls/vault-ca.pem"
    leader_client_cert_file = "/opt/vault/tls/vault-cert.pem"
    leader_client_key_file = "/opt/vault/tls/vault-key.pem"
  }
}

cluster_addr = "https://$local_ipv4:8201"
api_addr = "https://$local_ipv4:8200"

listener "tcp" {
  address            = "0.0.0.0:8200"
  tls_disable        = false
  tls_cert_file      = "/opt/vault/tls/vault-cert.pem"
  tls_key_file       = "/opt/vault/tls/vault-key.pem"
  tls_client_ca_file = "/opt/vault/tls/vault-ca.pem"
}

seal "azurekeyvault" {
  tenant_id = "${tenant_id}"
  vault_name = "${key_vault_name}"
  key_name = "${key_vault_key_name}"
}

EOF

# vault.hcl should be readable by the vault group only
chown root:root /etc/vault.d
chown root:vault /etc/vault.d/vault.hcl
chmod 640 /etc/vault.d/vault.hcl

systemctl enable vault
systemctl start vault

echo "Setup Vault profile"
cat <<EOF > /etc/profile.d/vault.sh
export VAULT_ADDR="https://127.0.0.1:8200"
export VAULT_CACERT="/opt/vault/tls/vault-ca.pem"
EOF
