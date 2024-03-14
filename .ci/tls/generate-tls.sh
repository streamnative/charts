#!/bin/bash

# Generate CA
echo "Generating ca certificate"
openssl genrsa -out private/ca.key.pem 2048
openssl req -x509 -new -nodes -key private/ca.key.pem -subj "/CN=pulsar-ci/O=StreamNative" -days 3650 -out certs/ca.cert.pem

# Generate component certs
for item in zookeeper bookie recovery broker proxy toolset; do
  echo "Generating certificate for" $item
  openssl genrsa -out servers/${item}/${item}.key.pem 2048
  openssl pkcs8 -topk8 -inform PEM -outform PEM -in servers/${item}/${item}.key.pem -out servers/${item}/${item}.key-pk8.pem -nocrypt
  openssl req -new -config conf/${item}.conf -key servers/${item}/${item}.key.pem -out servers/${item}/${item}.csr.pem -sha256
  openssl x509 -req -in servers/${item}/${item}.csr.pem -CA certs/ca.cert.pem -CAkey private/ca.key.pem -CAcreateserial -out servers/${item}/${item}.cert.pem -days 3650 -extensions v3_ext -extfile conf/${item}.conf -sha256
done
