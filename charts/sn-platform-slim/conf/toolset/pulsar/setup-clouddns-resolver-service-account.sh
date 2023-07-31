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
/pulsar/kubectl create secret generic ${HELM_RELEASE}-${RESOLVER_NAME}-svc-acct \
   --from-file=${RESOLVER_NAME}-key.json -n ${NAMESPACE}

echo "Remove the generated key."
rm ${RESOLVER_NAME}-key.json