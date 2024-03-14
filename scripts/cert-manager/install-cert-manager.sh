#
# Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved.
#

#!/usr/bin/env bash

NAMESPACE=cert-manager
NAME=cert-manager
VERSION=v1.0.4

# Install cert-manager CustomResourceDefinition resources
echo "Installing cert-manager CRD resources ..."
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/${VERSION}/cert-manager.crds.yaml

# Create the namespace
kubectl get ns ${NAMESPACE}
if [ $? == 0 ]; then
    echo "Namespace '${NAMESPACE}' already exists."
else
    echo "Creating namespace '${NAMESPACE}' ..."
    kubectl create namespace ${NAMESPACE}
    echo "Successfully created namespace '${NAMESPACE}'."
fi

# Add the Jetstack Helm repository.
echo "Adding Jetstack Helm repository."
helm repo add jetstack https://charts.jetstack.io
echo "Successfully added Jetstack Helm repository."

# Update local helm chart repository cache.
echo "Updating local helm chart repository cache ..."
helm repo update

echo "Installing cert-manager ${VERSION} to namespace ${NAMESPACE} as '${NAME}' ..."
helm install \
  --namespace ${NAMESPACE} \
  --version ${VERSION} \
  ${NAME} \
  jetstack/cert-manager
echo "Successfully installed cert-manager ${VERSION}."
