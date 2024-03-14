#!/usr/bin/env bash
#
# Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved.
#

set -e

CHART_HOME=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/../.. && pwd)
cd ${CHART_HOME}

usage() {
    cat <<EOF
This script is used to generate token secret key for a given pulsar helm release.
Options:
       -h,--help                        prints the usage message
       -n,--namespace                   the k8s namespace to install the pulsar helm chart
       -k,--release                     the pulsar helm release name
       -s,--symmetric                   generate symmetric secret key. If not provided, an asymmetric pair of keys are generated.
Usage:
    $0 --namespace pulsar --release pulsar-dev
EOF
}

symmetric=false

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
    -s|--symmetric)
    symmetric=true
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

source ${CHART_HOME}/scripts/pulsar/common_auth.sh

pulsar::ensure_pulsarctl

namespace=${namespace:-pulsar}
release=${release:-pulsar-dev}

function pulsar::jwt::generate_symmetric_key() {
    local secret_name="${release}-token-symmetric-key"

    tmpfile=$(mktemp)
    trap "test -f $tmpfile && rm $tmpfile" RETURN
    ${PULSARCTL_BIN} token create-secret-key --output-file ${tmpfile}
    mv $tmpfile SECRETKEY
    kubectl create secret generic ${secret_name} -n ${namespace} --from-file=SECRETKEY
    rm SECRETKEY
}

function pulsar::jwt::generate_asymmetric_key() {
    local secret_name="${release}-token-asymmetric-key"

    privatekeytmpfile=$(mktemp)
    trap "test -f $privatekeytmpfile && rm $privatekeytmpfile" RETURN
    publickeytmpfile=$(mktemp)
    trap "test -f $publickeytmpfile && rm $publickeytmpfile" RETURN
    ${PULSARCTL_BIN} token create-key-pair -a RS256 --output-private-key ${privatekeytmpfile} --output-public-key ${publickeytmpfile}
    mv $privatekeytmpfile PRIVATEKEY
    mv $publickeytmpfile PUBLICKEY
    kubectl create secret generic ${secret_name} -n ${namespace} --from-file=PRIVATEKEY --from-file=PUBLICKEY
    rm PRIVATEKEY
    rm PUBLICKEY
}

if [[ "${symmetric}" == "true" ]]; then
    pulsar::jwt::generate_symmetric_key
else
    pulsar::jwt::generate_asymmetric_key
fi
