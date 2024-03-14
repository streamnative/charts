#!/usr/bin/env bash
#
# Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved.
#

set -e

CHART_HOME=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/../.. && pwd)
cd ${CHART_HOME}

usage() {
    cat <<EOF
This script is used to decommission a bookkeeper cluster.
Options:
       -h,--help                                prints the usage message
       -n,--namespace                           the k8s namespace to run the bookkeeper cluster
       -r,--replicas                            the number of bookies of the bookkeeper cluster
       -s,--statefulset                         the name of the bookkeeper statefulset
       -an,--autorecovery-namespace             the k8s namespace to run the bookkeeper autorecovery
       -ap,--autorecovery-pod                   the pod name of the bookkeeper autorecovery pod
Usage:
    $0 -n old -r 3 -s old-cluster -an new -ap new-bookie-autorecovery
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
    -r|--replicas)
    replicas="$2"
    shift
    shift
    ;;
    -s|--statefulset)
    statefulset="$2"
    shift
    shift
    ;;
    -an|--autorecovery-namespace)
    autorecovery_namespace="$2"
    shift
    shift
    ;;
    -ap|--autorecovery-pod)
    autorecovery_pod="$2"
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
replicas=${replicas:-3}
statefulset=${statefulset:-dev}
autorecovery_namespace=${autorecovery_namespace:-pulsar}
autorecovery_pod=${autorecovery_pod:-autorecovery}

for ((i=replicas; i>=1; i--))
do
    j=$((i-1))
    echo kubectl -n ${namespace} scale --replicas=${j} sts/${statefulset}
    kubectl -n ${namespace} scale --replicas=${j} sts/${statefulset}
    echo kubectl -n ${autorecovery_namespace} exec -it ${autorecovery_pod} -- bin/bookkeeper shell decommissionbookie -bookieid ${statefulset}-${j}.${statefulset}.${namespace}.svc.cluster.local:3181
    kubectl -n ${autorecovery_namespace} exec -it ${autorecovery_pod} -- bin/bookkeeper shell decommissionbookie -bookieid ${statefulset}-${j}.${statefulset}.${namespace}.svc.cluster.local:3181
done
