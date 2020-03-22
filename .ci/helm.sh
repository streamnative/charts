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

BINDIR=`dirname "$0"`
CHARTS_HOME=`cd ${BINDIR}/..;pwd`
OUTPUT_BIN=${CHARTS_HOME}/output/bin
HELM=${OUTPUT_BIN}/helm
KUBECTL=${OUTPUT_BIN}/kubectl
NAMESPACE=pulsar
CLUSTER=pulsar-ci

function ci::create_cluster() {
    echo "Creating a kind cluster ..."
    ${CHARTS_HOME}/hack/kind-cluster-build.sh --name pulsar-ci -c 1 -v 10
    echo "Successfully created a kind cluster."
}

function ci::install_storage_provisioner() {
    echo "Installing the local storage provisioner ..."
    ${HELM} install local-storage-provisioner ${CHARTS_HOME}/charts/local-storage-provisioner
    WC=$(${KUBECTL} get pods --field-selector=status.phase=Running | grep local-storage-provisioner | wc -l)
    while [[ ${WC} -lt 1 ]]; do
      echo ${WC};
      sleep 15
      ${KUBECTL} get pods --field-selector=status.phase=Running
      WC=$(${KUBECTL} get pods --field-selector=status.phase=Running | grep local-storage-provisioner | wc -l)
    done
    echo "Successfully installed the local storage provisioner."
}

function ci::install_cert_manager() {
    echo "Installing the cert-manager ..."
    ${KUBECTL} create namespace cert-manager
    ${CHARTS_HOME}/scripts/cert-manager/install-cert-manager.sh
    WC=$(${KUBECTL} get pods -n cert-manager --field-selector=status.phase=Running | wc -l)
    while [[ ${WC} -lt 3 ]]; do
      echo ${WC};
      sleep 15
      ${KUBECTL} get pods -n cert-manager --field-selector=status.phase=Running
      WC=$(${KUBECTL} get pods -n cert-manager --field-selector=status.phase=Running | wc -l)
    done
    echo "Successfully installed the cert manager."
}

function ci::install_pulsar_chart() {
    local value_file=$1
    local extra_opts=$2

    echo "Installing the pulsar chart"
    ${KUBECTL} create namespace ${NAMESPACE}
    echo ${CHARTS_HOME}/scripts/pulsar/prepare_helm_release.sh -k ${CLUSTER} -n ${NAMESPACE} ${extra_opts}
    ${CHARTS_HOME}/scripts/pulsar/prepare_helm_release.sh -k ${CLUSTER} -n ${NAMESPACE} ${extra_opts}
    sleep 10

    echo ${HELM} install --values ${value_file} ${CLUSTER} ${CHARTS_HOME}/charts/pulsar
    ${HELM} template --values ${value_file} ${CLUSTER} ${CHARTS_HOME}/charts/pulsar
    ${HELM} install --values ${value_file} ${CLUSTER} ${CHARTS_HOME}/charts/pulsar

    WC=$(${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-proxy | wc -l)
    while [[ ${WC} -lt 1 ]]; do
      echo ${WC};
      sleep 15
      ${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running
      WC=$(${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-proxy | wc -l)
    done

    WC=$(${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-broker | wc -l)
    while [[ ${WC} -lt 1 ]]; do
      echo ${WC};
      sleep 15
      kubectl get pods -n ${NAMESPACE} --field-selector=status.phase=Running
      WC=$(${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-broker | wc -l)
    done
}

function ci::test_pulsar_producer() {
    sleep 120
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- /pulsar/bin/pulsar-admin tenants create pulsar-ci
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- /pulsar/bin/pulsar-admin namespaces create pulsar-ci/test
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- /pulsar/bin/pulsar-client produce -m "test-message" pulsar-ci/test/test-topic
}