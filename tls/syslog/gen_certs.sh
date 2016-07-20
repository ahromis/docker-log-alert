#!/bin/bash

ca_pass=$1
cn=$2

if [ ! ${ca_pass} ]; then
    read -sp "Enter in your CA password: " ca_pass
    while [ ! ${ca_pass} ]; do
        echo "Note: You need to enter in a CA password."
        read -sp "Enter in your CA password: " ca_pass
        echo ""
    done
    echo ""
fi

if [ ! ${cn} ]; then
    read -p "Enter in your certificate CN (Common Name): " cn
    while [ ! ${cn} ]; do
        echo "Note: You need to enter in a certificate Common Name."
        read -p "Enter in your certificate CN (Common Name): " cn
        echo ""
    done
    echo ""
fi

echo 'Creating CA (ca-key.pem, ca.pem)'
openssl genrsa -aes256 -passout pass:${ca_pass} -out ca-key.pem 4096
openssl req -new -passin pass:${ca_pass} -x509 -days 3650  -subj '/CN=DemoCA/C=US' -key ca-key.pem -sha256 -out ca.pem

echo 'Creating server certificates (key.pem, cert.pem)'
openssl genrsa -passout pass:${ca_pass} -out pkcs5-key.pem 4096
openssl req  -passin pass:${ca_pass} -subj "/CN=${cn}" -sha256 -new -key pkcs5-key.pem -out server.csr
echo "subjectAltName = DNS:${cn}" > extfile.cnf
openssl x509 -passin pass:${ca_pass} -req -days 3650 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile.cnf
openssl pkcs8 -in pkcs5-key.pem -topk8 -nocrypt -out pkcs8-key.pem
mv pkcs8-key.pem key.pem

rm -v server.csr extfile.cnf pkcs5-key.pem
chmod -v 0400 ca-key.pem key.pem
chmod -v 0444 ca.pem cert.pem

