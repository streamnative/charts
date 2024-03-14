#!/usr/bin/env bash
PULSAR_CHART_HOME=$(unset CDPATH && cd $(dirname "${BASH_SOURCE[0]}")/.. && pwd)
cd ${PULSAR_CHART_HOME}

source ${PULSAR_CHART_HOME}/hack/common.sh

hack::ensure_kubectl
hack::ensure_helm

usage() {
    cat <<EOF
This script use kind to create Kubernetes cluster, about kind please refer: https://kind.sigs.k8s.io/
Before run this script, please ensure that:
* have installed docker
* have installed kind and kind's version == ${KIND_VERSION}
Options:
       -h,--help               prints the usage message
       -n,--name               name of the Kubernetes cluster,default value: kind
       -c,--nodeNum            the count of the cluster nodes,default value: 6
       -k,--k8sVersion         version of the Kubernetes cluster,default value: v1.20.15
       -v,--volumeNum          the volumes number of each kubernetes node,default value: 9
Usage:
    $0 --name testCluster --nodeNum 4 --k8sVersion v1.12.9
EOF
}

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -n|--name)
    clusterName="$2"
    shift
    shift
    ;;
    -c|--nodeNum)
    nodeNum="$2"
    shift
    shift
    ;;
    -k|--k8sVersion)
    k8sVersion="$2"
    shift
    shift
    ;;
    -v|--volumeNum)
    volumeNum="$2"
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

clusterName=${clusterName:-pulsar-dev}
nodeNum=${nodeNum:-6}
k8sVersion=${k8sVersion:-v1.20.15}
volumeNum=${volumeNum:-9}

echo "clusterName: ${clusterName}"
echo "nodeNum: ${nodeNum}"
echo "k8sVersion: ${k8sVersion}"
echo "volumeNum: ${volumeNum}"

# check requirements
for requirement in kind docker
do
    echo "############ check ${requirement} ##############"
    if hash ${requirement} 2>/dev/null;then
        echo "${requirement} have installed"
    else
        echo "this script needs ${requirement}, please install ${requirement} first."
        exit 1
    fi
done

matchedCluster=$(kind get clusters --quiet | grep ${clusterName})
if [[ "${matchedCluster}" == "${clusterName}" ]]; then
    echo "############# Cleanup existing cluster:[${clusterName}] #############"
    kind delete cluster --name=${clusterName}
fi

echo "############# start create cluster:[${clusterName}] #############"
workDir=${HOME}/kind/${clusterName}
mkdir -p ${workDir}

data_dir=${workDir}/data

echo "clean data dir: ${data_dir}"
if [ -d ${data_dir} ]; then
    rm -rf ${data_dir}
fi

configFile=${workDir}/kind-config.yaml

cat <<EOF > ${configFile}
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
EOF

for ((i=0;i<${nodeNum};i++))
do
    mkdir -p ${data_dir}/worker${i}
    cat <<EOF >>  ${configFile}
- role: worker
  extraMounts:
EOF
    for ((k=1;k<=${volumeNum};k++))
    do
        mkdir -p ${data_dir}/worker${i}/vol${k}
        cat <<EOF >> ${configFile}
  - containerPath: /mnt/disks/vol${k}
    hostPath: ${data_dir}/worker${i}/vol${k}
EOF
    done
done

echo "start to create k8s cluster"
kind create cluster --config ${configFile} --image kindest/node:${k8sVersion} --name=${clusterName}
export KUBECONFIG=${workDir}/kubeconfig.yaml
kind get kubeconfig --name=${clusterName} > ${KUBECONFIG}

echo "############# success create cluster:[${clusterName}] #############"
echo "To start using your cluster, run:"
echo "    export KUBECONFIG=${KUBECONFIG}"
echo ""
echo <<EOF
NOTE: In kind, nodes run docker network and cannot access host network.
If you configured local HTTP proxy in your docker, images may cannot be pulled
because http proxy is inaccessible.
If you cannot remove http proxy settings, you can either whitelist image
domains in NO_PROXY environment or use 'docker pull <image> && kind load
docker-image <image>' command to load images into nodes.
EOF