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
