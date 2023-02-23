#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

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
