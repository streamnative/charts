#!/usr/bin/env bash
#
# Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved.
#

CHART_HOME=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/../.. && pwd)
cd ${CHART_HOME}

usage() {
    cat <<EOF
This script is used to cleanup the credentials for a given pulsar helm release. 
Options:
       -h,--help                        prints the usage message
       -n,--namespace                   the k8s namespace to install the pulsar helm chart
       -k,--release                     the pulsar helm release name
       -d,--delete-namespace            flag to delete k8s namespace.
Usage:
    $0 --namespace pulsar --release pulsar-release
EOF
}


while [[ $# -gt 0 ]]
do
key="$1"

delete_namespace=false

case $key in
    -n|--namespace)
    namespace="$2"
    shift
    shift
    ;;
    -d|--delete-namespace)
    delete_namespace=true
    shift
    ;;
    -k|--release)
    release="$2"
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

namespace=${namespace:-pulsar}
release=${release:-pulsar-dev}

function delete_namespace() {
    if [[ "${delete_namespace}" == "true" ]]; then
        kubectl delete namespace ${namespace}
    fi
}

# delete the cc admin secrets
kubectl delete -n ${namespace} secret ${release}-admin-secret

# delete tokens
kubectl get secrets -n ${namespace} | grep ${release}-token- | awk '{print $1}' | xargs kubectl delete secrets -n ${namespace}

# delete namespace
delete_namespace
