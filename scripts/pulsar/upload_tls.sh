#!/usr/bin/env bash
#
# Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved.
#

set -e

CHART_HOME=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/../.. && pwd)
cd ${CHART_HOME}

namespace=${namespace:-pulsar}
release=${release:-pulsar-dev}
tlsdir=${tlsdir:-"${HOME}/.config/pulsar/security_tool/gen/ca"}
clientComponents=${clientComponents:-""}
serverComponents=${serverComponents:-"bookie,broker,proxy,recovery,zookeeper,toolset"}

usage() {
    cat <<EOF
This script is used to upload tls for a given pulsar helm deployment.
The tls certs are generated by using "pulsarctl security-tool".
Options:
       -h,--help                        prints the usage message
       -n,--namespace                   the k8s namespace to install the pulsar helm chart. Defaut to ${namespace}.
       -k,--release                     the pulsar helm release name. Default to ${release}.
       -d,--dir                         the dir for storing tls certs. Default to ${tlsdir}.
       -c,--client-components           the client components of pulsar cluster. a comma separated list of components. Default to ${clientComponents}.
       -s,--server-components           the server components of pulsar cluster. a comma separated list of components. Default to ${serverComponents}.
Usage:
    $0 --namespace pulsar --release pulsar-dev
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
    -d|--dir)
    tlsdir="$2"
    shift
    shift
    ;;
    -c|--client-components)
    clientComponents="$2"
    shift
    shift
    ;;
    -s|--server-components)
    serverComponents="$2"
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

ca_cert_file=${tlsdir}/certs/ca.cert.pem

function upload_ca() {
    local tls_ca_secret="${release}-ca-tls"
    kubectl create secret generic ${tls_ca_secret} -n ${namespace} --from-file="ca.crt=${ca_cert_file}"
}

function upload_server_cert() {
    local component=$1
    local server_cert_secret="${release}-tls-${component}"
    local tls_cert_file="${tlsdir}/servers/${component}/${component}.cert.pem"
    local tls_key_file="${tlsdir}/servers/${component}/${component}.key-pk8.pem"

    kubectl create secret generic ${server_cert_secret} \
        -n ${namespace} \
        --from-file="tls.crt=${tls_cert_file}" \
        --from-file="tls.key=${tls_key_file}" \
        --from-file="ca.crt=${ca_cert_file}"
}

function upload_client_cert() {
    local component=$1
    local client_cert_secret="${release}-tls-${component}"
    local tls_cert_file="${tlsdir}/clients/${component}/${component}.cert.pem"
    local tls_key_file="${tlsdir}/clients/${component}/${component}.key-pk8.pem"

    kubectl create secret generic ${client_cert_secret} \
        -n ${namespace} \
        --from-file="tls.crt=${tls_cert_file}" \
        --from-file="tls.key=${tls_key_file}" \
        --from-file="ca.crt=${ca_cert_file}"
}

upload_ca

IFS=', ' read -r -a server_components <<< "$serverComponents"
for component in "${server_components[@]}"
do
    upload_server_cert ${component}
done

IFS=', ' read -r -a client_components <<< "$clientComponents"
for component in "${client_components[@]}"
do
    upload_client_cert ${component}
done
