#!/bin/bash

set -e

REGION=${REGION:-"us-east1"}
ZONE_EXTENSION=${ZONE_EXTENSION:-"b"}
ZONE=${REGION}-${ZONE_EXTENSION}
CLUSTER_NAME=${CLUSTER_NAME:-"pulsar-dev"}
MACHINE_TYPE=${MACHINE_TYPE:-"n1-standard-4"}
NUM_NODES=${NUM_NODES:-"4"}
INT_NETWORK=${INT_NETWORK:-"default"}
PREEMPTIBLE=${PREEMPTIBLE-false}
EXTRA_CREATE_ARGS=${EXTRA_CREATE_ARGS:-""}
USE_LOCAL_SSD=${USE_LOCAL_SSD-false}
LOCAL_SSD_COUNT=${LOCAL_SSD_COUNT:-"4"}
CONFDIR=${CONFDIR:-"${HOME}/.config/streamnative"}

# MacOS does not support readlink, but it does have perl
KERNEL_NAME=$(uname -s)
BINDIR=$(dirname "$0")
SCRIPTS_DIR=`cd ${BINDIR};pwd`

source ${SCRIPTS_DIR}/common.sh;

function bootstrap(){
  set -e
  validate_gke_required_tools;

  # Use the default cluster version for the specified zone if not provided
  if [ -z "${CLUSTER_VERSION}" ]; then
    CLUSTER_VERSION=$(gcloud container get-server-config --zone $ZONE --project $PROJECT --format='value(defaultClusterVersion)');
  fi

  if $PREEMPTIBLE; then
    EXTRA_CREATE_ARGS="$EXTRA_CREATE_ARGS --preemptible"
  fi
  if ${USE_LOCAL_SSD}; then
    EXTRA_CREATE_ARGS="$EXTRA_CREATE_ARGS --local-ssd-count ${LOCAL_SSD_COUNT}"
  fi

  gcloud container clusters create $CLUSTER_NAME \
    --zone $ZONE \
    --cluster-version $CLUSTER_VERSION \
    --machine-type $MACHINE_TYPE \
    --scopes "default","https://www.googleapis.com/auth/ndev.clouddns.readwrite" \
    --node-version ${CLUSTER_VERSION} \
    --num-nodes $NUM_NODES \
    --enable-ip-alias \
    --network $INT_NETWORK \
    --project $PROJECT \
    $EXTRA_CREATE_ARGS;

  mkdir -p ${CONFDIR}/.kube;
  touch ${CONFDIR}/.kube/config;
  export KUBECONFIG=${CONFDIR}/.kube/config;

  gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT;

  echo "Wait for metrics API service"
  # Helm 2.15 and 3.0 bug https://github.com/helm/helm/issues/6361#issuecomment-550503455
  /pulsar/kubectl --namespace=kube-system wait --for=condition=Available --timeout=5m apiservices/v1beta1.metrics.k8s.io

  helm repo update
}

#Deletes everything created during bootstrap
function cleanup_gke_resources(){
  validate_gke_required_tools;

  gcloud container clusters delete -q $CLUSTER_NAME --zone $ZONE --project $PROJECT;
  echo "Deleted $CLUSTER_NAME cluster successfully";

  echo "\033[;33m Warning: Disks, load balancers, DNS records, and other cloud resources created during the helm deployment are not deleted, please delete them manually from the gcp console \033[0m";
}

gke_help() {
  cat <<EOF
Usage: gke_bootstrap_script.sh <command>
where command is one of:
    up          Create a GKE cluster
    down        Delete a GKE cluster

Environment variables:
    PROJECT             Name of the GCP project. It is not set by default.

    CLUSTER_NAME        Name of the GKE cluster. Defaults to ${CLUSTER_NAME}.
    CONFDIR             Configuration directory to store kubernetes config. Defaults to ${CONFDIR}
    INT_NETWORK         The Compute Engine Network that the cluster will connect to. Defaults to the '${INT_NETWORK}' network.
    LOCAL_SSD_COUNT     The number of local ssd counts. Defaults to ${LOCAL_SSD_COUNT}.
    MACHINE_TYPE        The type of machine to use for nodes. Defaults to ${MACHINE_TYPE}.
    NUM_NODES           The number of nodes to be created in each of the cluster's zones. Defaults to ${NUM_NODES}.
    PREEMPTIBLE         Create nodes using preemptible VM instances in the new cluster. Defaults to ${PREEMPTIBLE}.
    REGION              Compute region for the cluster. Defaults to ${REGION}.
    USE_LOCAL_SSD       Flag to create a cluster with local SSDs. Defaults to ${USE_LOCAL_SSD}.
    ZONE                Compute zone for the cluster. Defaults to ${ZONE}.
    ZONE_EXTENSION      Compute zone extension for the cluster. Defaults to ${ZONE_EXTENSION}.

    EXTRA_CREATE_ARGS   Extra arguments passed to create command.
EOF
}

if [ -z "$1" ]; then
  gke_help
  exit 1
fi

case $1 in
  up)
    bootstrap;
    ;;
  down)
    cleanup_gke_resources;
    ;;
  *)
    echo "Unknown command $1";
    exit 1;
  ;;
esac
