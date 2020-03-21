set -e

BINDIR=`dirname "$0"`
CHARTS_HOME=`cd ${BINDIR}/..;pwd`
OUTPUT_BIN=${CHARTS_HOME}/output/bin
HELM=${OUTPUT_BIN}/helm
KUBECTL=${OUTPUT_BIN}/kubectl
NAMESPACE=pulsar
CLUSTER=pulsar-ci

echo "Creating a kind cluster ..."
${CHARTS_HOME}/hack/kind-cluster-build.sh --name pulsar-ci -c 1 -v 10

echo "Install the local storage provisioner"
${HELM} install local-storage-provisioner pulsar/charts/local-storage-provisioner

WC=$(kubectl get pods --field-selector=status.phase=Running | grep local-storage-provisioner | wc -l)
while [[ ${WC} -lt 1 ]]; do
  echo ${WC};
  sleep 15
  kubectl get pods --field-selector=status.phase=Running
  WC=$(kubectl get pods --field-selector=status.phase=Running | grep local-storage-provisioner | wc -l)
done

echo "Install the pulsar chart"
${KUBECTL} create namespace ${NAMESPACE}
${HELM} install --values ${BINDIR}/values-local-pv.yaml ${CLUSTER} pulsar/charts/pulsar

WC=$(kubectl get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-proxy | wc -l)
while [[ ${WC} -lt 1 ]]; do
  echo ${WC};
  sleep 15
  kubectl get pods --field-selector=status.phase=Running
  WC=$(kubectl get pods -n ${NAMESPACE} --field-selector=status.phase=Running | grep ${CLUSTER}-proxy | wc -l)
done

# test producer
${KUBECTL} exec -n ${NAMESPACE} -it ${CLUSTER}-toolset-0 -- /pulsar/bin/pulsar-client produce test-topic