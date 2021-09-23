#!/usr/bin/env bash
set -e -o pipefail

echo "Enter desired Certificate Authority common name (e.g. server.com):"
read TLS_CA_CN

echo "Enter desired server common name (e.g. vault.server.com) (this will be the same value provided to the module's leader_tls_servername variable):"
read SHARED_SAN

echo "Generating CA private key at rootca.key"
openssl genrsa -out rootca.key 2048
echo "Generating CA public cert at rootca.pem"
openssl req -x509 -new -nodes -key rootca.key -sha256 -days 30 -out rootca.pem -subj "/CN=$TLS_CA_CN" -extensions extensions -config <(cat /etc/ssl/openssl.cnf <(printf "[extensions]\nkeyUsage = keyCertSign,cRLSign\nbasicConstraints=CA:TRUE"))
echo "Generating server private key at vault.key"
openssl genrsa -out vault.key 2048
CERT_REQ_EXT_1="subjectAltName = IP:127.0.0.1,DNS:$SHARED_SAN,DNS:localhost"
CERT_REQ_EXT_2="keyUsage = digitalSignature,keyAgreement,keyEncipherment"
CERT_REQ_EXT_3="extendedKeyUsage = clientAuth,serverAuth"
echo "Generating server cert signing request at vault.csr"
openssl req -new -key vault.key -out vault.csr -subj "/CN=vault.server.com" -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\n$CERT_REQ_EXT_1\n$CERT_REQ_EXT_2\n$CERT_REQ_EXT_3"))
echo "Generating server cert at vault.pem"
openssl x509 -req -in vault.csr -CA rootca.pem -CAkey rootca.key -CAcreateserial -out vault.pem -days 30 -sha256 -extensions SAN -extfile <(cat /etc/ssl/openssl.cnf <(printf "[SAN]\n$CERT_REQ_EXT_1\n$CERT_REQ_EXT_2\n$CERT_REQ_EXT_3"))
echo "Bundling cert, key, and CA cert into certificate-to-import.pfx"
openssl pkcs12 -export -out certificate-to-import.pfx -inkey vault.key -in vault.pem -certfile rootca.pem -passout pass:
