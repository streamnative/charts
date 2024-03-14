#!/usr/bin/env bash
BINDIR=`dirname "$0"`
CHARTS_HOME=`cd ${BINDIR}/..;pwd`
OUTPUT_BIN=${CHARTS_HOME}/output/bin
KIND_BIN=$OUTPUT_BIN/kind
HELM=${OUTPUT_BIN}/helm
KUBECTL=${OUTPUT_BIN}/kubectl
NAMESPACE=pulsar
CLUSTER=pulsar-ci
CLUSTER_ID=$(uuidgen | tr '[:upper:]' '[:lower:]')
K8S_VERSION=${K8S_VERSION:-"v1.19.16"}

function ci::create_cluster() {
    echo "Creating a kind cluster ..."
    ${CHARTS_HOME}/hack/kind-cluster-build.sh --name pulsar-ci-${CLUSTER_ID} -c 1 -v 10 --k8sVersion ${K8S_VERSION}
    echo "Successfully created a kind cluster."
}

function ci::delete_cluster() {
    echo "Deleting a kind cluster ..."
    kind delete cluster --name=pulsar-ci-${CLUSTER_ID}
    echo "Successfully delete a kind cluster."
}

function ci::install_cert_manager() {
    echo "Installing the cert-manager ..."
    ${KUBECTL} create namespace cert-manager
    ${CHARTS_HOME}/scripts/cert-manager/install-cert-manager.sh
    WC=$(${KUBECTL} get pods -n cert-manager --field-selector=status.phase=Running | wc -l)
    while [[ ${WC} -lt 3 ]]; do
      echo ${WC};
      sleep 15
      ${KUBECTL} get pods -n cert-manager
      WC=$(${KUBECTL} get pods -n cert-manager --field-selector=status.phase=Running | wc -l)
    done
    echo "Successfully installed the cert manager."
}

function ci::install_pulsar_chart() {
    chart_home=${CHARTS_HOME}
    if [[ -z "${UPGRADE}" ]]; then
        value_file=$1
        extra_opts=$2
    else
        value_file=$1
        chart_home=$2
        extra_opts=$3
    fi

    echo "Installing the pulsar chart"
    ${KUBECTL} create namespace ${NAMESPACE}
    echo ${CHARTS_HOME}/scripts/pulsar/prepare_helm_release.sh -k ${CLUSTER} -n ${NAMESPACE} ${extra_opts}
    ${CHARTS_HOME}/scripts/pulsar/prepare_helm_release.sh -k ${CLUSTER} -n ${NAMESPACE} ${extra_opts}
    ${CHARTS_HOME}/scripts/pulsar/upload_tls.sh -k ${CLUSTER} -d ${CHARTS_HOME}/.ci/tls
    sleep 10

    echo ${HELM} install -n ${NAMESPACE} --values ${value_file} ${CLUSTER} ${chart_home}/charts/pulsar
    ${HELM} template -n ${NAMESPACE} --values ${value_file} ${CLUSTER} ${chart_home}/charts/pulsar
    ${HELM} upgrade --install -n ${NAMESPACE} --set initialize=true --values ${value_file} ${CLUSTER} ${chart_home}/charts/pulsar

    ci::wait_pulsar_ready
    # ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bash -c 'until [ "$(curl -L http://pulsar-ci-proxy:8080/status.html)" == "OK" ]; do sleep 3; done'
}

function ci::wait_pulsar_ready() {
    echo "Wait until broker is ready"
    WC=$(${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-broker | wc -l)
    SECONDS=0
    while [[ ${WC} -lt 1 ]] && (( ${SECONDS} < 600 )); do
      echo "@" ${SECONDS}, ${WC};
      sleep 15
      ${KUBECTL} get pods -n ${NAMESPACE}
      WC=$(${KUBECTL} get pods -n ${NAMESPACE} | grep ${CLUSTER}-broker | wc -l)
      if [[ ${WC} -gt 1 ]]; then
        ${KUBECTL} describe pod -n ${NAMESPACE} pulsar-ci-broker-0
        ${KUBECTL} logs -n ${NAMESPACE} pulsar-ci-broker-0
      fi
      WC=$(${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-broker | wc -l)
    done
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- timeout 10m bash -c 'until nslookup pulsar-ci-broker; do sleep 3; done'
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- timeout 10m bash -c 'until [ "$(curl -L http://pulsar-ci-broker:8080/status.html)" == "OK" ]; do sleep 3; done'

    # TODO: Handle when proxy is disabled
    echo "Wait until proxy is ready"
    WC=$(${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-proxy | wc -l)
    SECONDS=0
    while [[ ${WC} -lt 1 ]] && (( ${SECONDS} < 600 )); do
      echo "@" ${SECONDS}, ${WC};
      sleep 15
      ${KUBECTL} get pods -n ${NAMESPACE}
      WC=$(${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-proxy | wc -l)
    done
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- timeout 5m bash -c 'until nslookup pulsar-ci-proxy; do sleep 3; done'

    ${KUBECTL} get service -n ${NAMESPACE}
}

function ci::test_pulsar_producer() {
    sleep 120
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bash -c 'until nslookup pulsar-ci-broker; do sleep 3; done'
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bash -c 'until nslookup pulsar-ci-proxy; do sleep 3; done'
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-bookie-0 -- df -h
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-bookie-0 -- cat conf/bookkeeper.conf
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bin/bookkeeper shell listbookies -rw
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bin/bookkeeper shell listbookies -ro
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bin/pulsar-admin clusters list
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bin/pulsar-admin clusters get pulsar-ci
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bin/pulsar-admin namespaces create public/test
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bin/pulsar-client produce -m "test-message" public/test/test-topic
}

function ci::wait_function_running() {
    num_running=$(${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bash -c 'bin/pulsar-admin functions status --tenant public --namespace test --name test-function | ./jq .numRunning')
    while [[ ${num_running} -lt 1 ]]; do
      echo ${num_running}
      sleep 15
      ${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running
      num_running=$(${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bash -c 'bin/pulsar-admin functions status --tenant public --namespace test --name test-function | ./jq .numRunning')
    done
}

function ci::wait_message_processed() {
    num_processed=$(${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bash -c 'bin/pulsar-admin functions stats --tenant public --namespace test --name test-function | ./jq .processedSuccessfullyTotal')
    while [[ ${num_processed} -lt 1 ]]; do
      echo ${num_processed}
      sleep 15
      ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bin/pulsar-admin functions stats --tenant public --namespace test --name test-function
      num_processed=$(${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bash -c 'bin/pulsar-admin functions stats --tenant public --namespace test --name test-function | ./jq .processedSuccessfullyTotal')
    done
}

function ci::test_pulsar_function() {
    echo "@Test Pulsar Function"
    sleep 120
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bash -c 'until nslookup pulsar-ci-broker; do sleep 3; done'
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bash -c 'until nslookup pulsar-ci-proxy; do sleep 3; done'
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-bookie-0 -- df -h
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bin/bookkeeper shell listbookies -rw
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bin/bookkeeper shell listbookies -ro
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- curl --retry 10 -L -o jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- chmod +x jq
    ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bin/pulsar-admin functions create --tenant public --namespace test --name test-function --inputs "public/test/test_input" --output "public/test/test_output" --parallelism 1 --classname org.apache.pulsar.functions.api.examples.ExclamationFunction --jar /pulsar/examples/api-examples.jar

    # wait until the function is running
    # TODO: re-enable function test
    # ci::wait_function_running
    # ${KUBECTL} exec -n ${NAMESPACE} ${CLUSTER}-toolset-0 -- bin/pulsar-client produce -m "hello pulsar function!" public/test/test_input
    # ci::wait_message_processed
}

function ci::upgrade_pulsar_chart() {
    local value_file=$1
    echo "Upgrading the pulsar chart"
    ${HELM} repo add loki https://grafana.github.io/loki/charts
    ${HELM} dependency update ${CHARTS_HOME}/charts/pulsar
    ${HELM} upgrade -n ${NAMESPACE} --values ${value_file} ${CLUSTER} ${CHARTS_HOME}/charts/pulsar --timeout 1h --debug
    # wait the upgrade process start then to check the status
    sleep 60
    ci::wait_pulsar_ready

    WC=$(${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-bookie | wc -l)
    while [[ ${WC} -lt 1 ]]; do
      echo ${WC};
      sleep 15
      ${KUBECTL} get pods -n ${NAMESPACE}
      WC=$(${KUBECTL} get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-bookie | wc -l)
    done
}