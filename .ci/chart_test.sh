set -ex


BINDIR=`dirname "$0"`
CHARTS_HOME=`cd ${BINDIR}/..;pwd`
VALUES_FILE=$1
TLS=${TLS:-"false"}
SYMMETRIC=${SYMMETRIC:-"false"}
FUNCTION=${FUNCTION:-"false"}
UPGRADE=${UPGRADE:-"false"}

if [[ "x${UPGRADE}" == "xtrue" ]]; then
    APACHE_VALUES_FILE=$VALUES_FILE
    UPGRADE_VALUES_FILE=$2
    APACHE_CHARTS=$3
fi

source ${CHARTS_HOME}/.ci/helm.sh

# create cluster
ci::create_cluster

# delete the cluster
trap 'ci::delete_cluster' 0

# install storage provisioner
ci::install_storage_provisioner

extra_opts=""
if [[ "x${SYMMETRIC}" == "xtrue" ]]; then
    extra_opts="-s"
fi

# install pulsar chart
if [[ "x${UPGRADE}" == "xfalse" ]]; then
    ci::install_pulsar_chart ${CHARTS_HOME}/${VALUES_FILE} ${extra_opts}
else
    ci::install_pulsar_chart ${CHARTS_HOME}/${APACHE_VALUES_FILE} ${APACHE_CHARTS} ${extra_opts}
fi

# test producer
ci::test_pulsar_producer

if [[ "x${FUNCTION}" == "xtrue" ]]; then
    # install cert manager
    ci::test_pulsar_function
fi

if [[ "x${UPGRADE}" == "xtrue" ]]; then
    ci::upgrade_pulsar_chart  ${CHARTS_HOME}/${UPGRADE_VALUES_FILE}
fi
