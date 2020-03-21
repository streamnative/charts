set -e

BINDIR=`dirname "$0"`
CHARTS_HOME=`cd ${BINDIR}/..;pwd`
OUTPUT_BIN=${CHARTS_HOME}/output/bin
HELM=${OUTPUT_BIN}/helm
KUBECTL=${OUTPUT_BIN}/kubectl

${CHARTS_HOME}/hack/kind-cluster-build.sh --name pulsar-ci -c 1 -v 10
${HELM} install local-storage-provisioner pulsar/charts/local-storage-provisioner
${KUBECTL} create namespace pulsar
${HELM} install --values ${BINDIR}/values-local-pv.yaml pulsar-ci pulsar/charts/pulsar