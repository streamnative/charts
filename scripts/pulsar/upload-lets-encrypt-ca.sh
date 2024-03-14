#
# Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved.
#

#!/usr/bin/env bash

BINDIR=`dirname "$0"`
HELM_HOME=`cd $BINDIR/../..;pwd`

cd $HELM_HOME/hack/pulsar/conf

CA_NAME=lets-encrypt-x3-cross-signed
PEM="${CA_NAME}.pem"

NAMESPACE=$1

kubectl create secret generic ${CA_NAME}  \
   --from-file=${PEM} -n ${NAMESPACE}
