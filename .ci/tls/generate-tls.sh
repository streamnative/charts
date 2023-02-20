#!/bin/bash

# generate ca for 365 days
echo "generate ca certificate..."
openssl genrsa -out ca.key.pem 2048
openssl req -x509 -new -nodes -key ca.key.pem -subj "/CN=CARoot" -days 365 -out ca.cert.pem

# generate broker certificate
echo "generate broker certificate..."
openssl genrsa -out broker.key.pem 2048
openssl pkcs8 -topk8 -inform PEM -outform PEM -in broker.key.pem -out broker.key-pk8.pem -nocrypt
openssl req -new -config conf/broker.conf -key broker.key.pem -out broker.csr.pem -sha256
openssl x509 -req -in broker.csr.pem -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -out broker.cert.pem -days 365 -extensions v3_ext -extfile conf/broker.conf -sha256

# generate proxy certificate
echo "generate proxy certificate..."
openssl genrsa -out proxy.key.pem 2048
openssl pkcs8 -topk8 -inform PEM -outform PEM -in proxy.key.pem -out proxy.key-pk8.pem -nocrypt
openssl req -new -config conf/proxy.conf -key proxy.key.pem -out proxy.csr.pem -sha256
openssl x509 -req -in proxy.csr.pem -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -out proxy.cert.pem -days 365 -extensions v3_ext -extfile conf/proxy.conf -sha256

# generate bookie certificate
echo "generate bookie certificate..."
openssl genrsa -out bookie.key.pem 2048
openssl pkcs8 -topk8 -inform PEM -outform PEM -in bookie.key.pem -out bookie.key-pk8.pem -nocrypt
openssl req -new -config conf/bookie.conf -key bookie.key.pem -out bookie.csr.pem -sha256
openssl x509 -req -in bookie.csr.pem -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -out bookie.cert.pem -days 365 -extensions v3_ext -extfile conf/bookie.conf -sha256

# generate toolset certificate
echo "generate toolset certificate..."
openssl genrsa -out toolset.key.pem 2048
openssl pkcs8 -topk8 -inform PEM -outform PEM -in toolset.key.pem -out toolset.key-pk8.pem -nocrypt
openssl req -new -config conf/toolset.conf -key toolset.key.pem -out toolset.csr.pem -sha256
openssl x509 -req -in toolset.csr.pem -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -out toolset.cert.pem -days 365 -extensions v3_ext -extfile conf/toolset.conf -sha256

# generate zookeeper certificate
echo "generate zookeeper certificate..."
openssl genrsa -out zookeeper.key.pem 2048
openssl pkcs8 -topk8 -inform PEM -outform PEM -in zookeeper.key.pem -out zookeeper.key-pk8.pem -nocrypt
openssl req -new -config conf/zookeeper.conf -key zookeeper.key.pem -out zookeeper.csr.pem -sha256
openssl x509 -req -in zookeeper.csr.pem -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -out zookeeper.cert.pem -days 365 -extensions v3_ext -extfile conf/zookeeper.conf -sha256

# generate recovery certificate
echo "generate recovery certificate..."
openssl genrsa -out recovery.key.pem 2048
openssl pkcs8 -topk8 -inform PEM -outform PEM -in recovery.key.pem -out recovery.key-pk8.pem -nocrypt
openssl req -new -config conf/recovery.conf -key recovery.key.pem -out recovery.csr.pem -sha256
openssl x509 -req -in recovery.csr.pem -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -out recovery.cert.pem -days 365 -extensions v3_ext -extfile conf/recovery.conf -sha256

# moving the certificate to the right place

rm ca.cert.srl
mv ca.cert.pem certs
mv ca.key.pem private
mv broker.* servers/broker
mv bookie.* servers/bookie
mv proxy.* servers/proxy
mv zookeeper.* servers/zookeeper
mv toolset.* servers/toolset
mv recovery.* servers/recovery
