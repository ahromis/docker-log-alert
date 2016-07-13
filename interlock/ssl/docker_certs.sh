#!/bin/bash

ca_pass=$1
wildcard_cn=$2

if [ ! ${ca_pass} ]; then
    echo "No CA pass specified."
    read -sp "Enter in your CA password: " ca_pass
    echo ""
fi

if [ ! ${wildcard_cn} ]; then
    echo "No wildcard domain specified. Enter in a domain like this: domain.com"
    read -p "Enter in wildcard domain to generate self-signed certs for: " wildcard_cn
fi

echo 'Creating CA (ca-key.pem, ca.pem)'
openssl genrsa -aes256 -passout pass:${ca_pass} -out ca-key.pem 4096
openssl req -new -passin pass:${ca_pass} -x509 -days 3650  -subj '/CN=DemoCA/C=US' -key ca-key.pem -sha256 -out ca.pem

echo 'Creating server certificates (key.pem, cert.pem)'
openssl genrsa -passout pass:${ca_pass} -out key.pem 4096
openssl req  -passin pass:${ca_pass} -subj "/CN=${wildcard_cn}" -sha256 -new -key key.pem -out server.csr
echo "subjectAltName = DNS:*.${wildcard_cn}" > extfile.cnf
openssl x509 -passin pass:${ca_pass} -req -days 3650 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile.cnf

rm -v server.csr extfile.cnf
chmod -v 0400 ca-key.pem key.pem
chmod -v 0444 ca.pem cert.pem

