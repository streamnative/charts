#!/usr/bin/env bash
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

BASEDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $BASEDIR

usage() {
    cat <<EOF
This script is used to create pulsar tokens before deploying a helm chart.
Options:
       -h,--help                        prints the usage message
       -n,--namespace                   the k8s namespace to install the pulsar helm chart
       -k,--release                     the pulsar helm release name
       -v,--vault-addr                  the vault server address
       -r,--root-token                  the vault root token
       -s,--pulsar-superusers           the superusers of pulsar cluster. a comma separated list of super users.
       -ros,--pulsar-ro-superusers      the readonly superusers of pulsar cluster. a comma separated list of super users.
Usage:
    $0 --namespace pulsar --release pulsar-release --pulsar-superusers admin,broker-admin,proxy-admin,super
EOF
}


while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -n|--namespace)
    namespace="$2"
    shift
    shift
    ;;
    -k|--release)
    release="$2"
    shift
    shift
    ;;
    -v|--vault-addr)
    vault_addr="$2"
    shift
    shift
    ;;
    -r|--root-token)
    vault_root_token="$2"
    shift
    shift
    ;;
    -s|--pulsar-superusers)
    pulsar_superusers="$2"
    shift
    shift
    ;;
    -ros|--pulsar-ro-superusers)
    pulsar_ro_superusers="$2"
    shift
    shift
    ;;
    -h|--help)
    usage
    exit 0
    ;;
    *)
    echo "unknown option: $key"
    usage
    exit 1
    ;;
esac
done

namespace=${namespace:-default}
release=${release:-pulsar-dev}
pulsar_superusers=${pulsar_superusers:-"super,proxy-admin,broker-admin"}
pulsar_ro_superusers=${pulsar_ro_superusers:-"admin"}
vault_addr=${vault_addr:-"http://127.0.0.1:8200"}

export VAULT_ADDR=${vault_addr}

vault login ${vault_root_token}

echo "Enable secrets engine ..."
vault secrets enable -path=secret --version=2 kv
echo "Enable userpass ..."
vault auth enable userpass

vault policy write super ${BASEDIR}/superuser.hcl
vault policy write pulsar-superuser-ro ${BASEDIR}/ro-superuser.hcl

vault auth tune -max-lease-ttl=31536000 token
vault auth tune -default-lease-ttl=31536000 token

function createSuperUser() {
    local user=$1
    local superToken=$(vault token create --policy super --ttl 0 --display-name ${user} --metadata=username=${user} --metadata=isSuper=true | grep token | grep -v _ | awk '{ print $2 }')

    vault kv put secret/pulsar/token-${user} role="${user}" isSuper=true
    kubectl delete secret -n ${namespace} \
        ${release}-token-${user}
    kubectl create secret generic -n ${namespace} \
        ${release}-token-${user} \
        --from-literal="TOKEN=${superToken}" \
        --from-literal="TYPE=vault"
}

function createSuperUserRO() {
    local user=$1
    local superToken=$(vault token create --policy pulsar-superuser-ro --ttl 0 --display-name ${user} --metadata=username=${user} --metadata=isSuper=true | grep token | grep -v _ | awk '{ print $2 }')

    vault kv put secret/pulsar/token-${user} role="${user}" isSuper=true
    kubectl delete secret -n ${namespace} \
        ${release}-token-${user}
    kubectl create secret generic -n ${namespace} \
        ${release}-token-${user} \
        --from-literal="TOKEN=${superToken}" \
        --from-literal="TYPE=vault"
}

echo "generate the tokens for the super-users: ${pulsar_superusers}"

IFS=', ' read -r -A superusers <<< "$pulsar_superusers"
for user in "${superusers[@]}"
do
    echo "generate the token for $user"
    createSuperUser $user
done

echo "generate the tokens for the readonly super-users: ${pulsar_ro_superusers}"

IFS=', ' read -r -A ro_superusers <<< "$pulsar_ro_superusers"
for user in "${ro_superusers[@]}"
do
    echo "generate the token for $user"
    createSuperUserRO $user
done

echo "The jwt tokens for superusers are generated and stored as below:"
for user in "${superusers[@]}"
do
    echo "    - '${user}':secret('${release}-token-${user}')"
done
echo

echo "The jwt tokens for readonly superusers are generated and stored as below:"
for user in "${ro_superusers[@]}"
do
    echo "    - '${user}':secret('${release}-token-${user}')"
done
echo
