#!/usr/bin/env bash
#
# Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved.
#

set -e

CHART_HOME=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/../.. && pwd)
cd ${CHART_HOME}

usage() {
    cat <<EOF
This script is used to retrieve token for a given pulsar role.
Options:
       -h,--help                        prints the usage message
       -n,--namespace                   the k8s namespace to install the pulsar helm chart
       -k,--release                     the pulsar helm release name
       -r,--role                        the pulsar role
Usage:
    $0 --namespace pulsar --release pulsar-dev -r <pulsar-role>
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
    -r|--role)
    role="$2"
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

if [[ "x${role}" == "x" ]]; then
    echo "No pulsar role is provided!"
    usage
    exit 1
fi

source ${CHART_HOME}/scripts/pulsar/common_auth.sh

pulsar::ensure_pulsarctl

namespace=${namespace:-pulsar}
release=${release:-pulsar-dev}

function pulsar::jwt::get_token() {
    local token_name="${release}-token-${role}"

    local token=$(kubectl get -n ${namespace} secrets ${token_name} -o jsonpath="{.data['TOKEN']}" | base64 --decode)
    local token_type=$(kubectl get -n ${namespace} secrets ${token_name} -o jsonpath="{.data['TYPE']}" | base64 --decode)

    echo "token type: ${token_type}"
    echo "-------------------------"
    echo "${token}"
}

pulsar::jwt::get_token
