#
# Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved.
#

#!/usr/bin/env bash

set -e

if [ $# -lt 4 ]; then
    cat <<EOF
Usage: setup-clouddns-resolver-service-account.sh <google-project-id> <resolver-name> <helm-release-name> <namespace>
EOF
    exit 1;
fi

PROJECT_ID=$1
RESOLVER_NAME=$2
HELM_RELEASE=$3
NAMESPACE=$4

echo "Create a service acccount : ${RESOLVER_NAME}."
gcloud iam service-accounts create ${RESOLVER_NAME} --display-name "${RESOLVER_NAME}"

echo "Bind service account '${RESOLVER_NAME}' as role 'dns.admin'."
gcloud projects add-iam-policy-binding $PROJECT_ID \
   --member serviceAccount:${RESOLVER_NAME}@$PROJECT_ID.iam.gserviceaccount.com \
   --role roles/dns.admin

echo "Create a key for service account '${RESOLVER_NAME}' as role 'dns.admin'."
gcloud iam service-accounts keys create ${RESOLVER_NAME}-key.json \
   --iam-account ${RESOLVER_NAME}@$PROJECT_ID.iam.gserviceaccount.com

echo "Save the service account key as a kubernete secret '${HELM_RELEASE}-${RESOLVER_NAME}-svc-acct' in namespace '${NAMESPACE}'."
kubectl create secret generic ${HELM_RELEASE}-${RESOLVER_NAME}-svc-acct \
   --from-file=${RESOLVER_NAME}-key.json -n ${NAMESPACE}

echo "Remove the generated key."
rm ${RESOLVER_NAME}-key.json