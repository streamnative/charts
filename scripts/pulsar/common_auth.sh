#!/usr/bin/env bash
#
# Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved.
#

if [ -z "$CHART_HOME" ]; then
    echo "error: CHART_HOME should be initialized"
    exit 1
fi

OUTPUT=${CHART_HOME}/output
OUTPUT_BIN=${OUTPUT}/bin
PULSARCTL_VERSION=v2.10.2.2
PULSARCTL_BIN=${HOME}/.pulsarctl/pulsarctl
export PATH=${HOME}/.pulsarctl/plugins:${PATH}

discoverArch() {
  ARCH=$(uname -m)
  case $ARCH in
    x86) ARCH="386";;
    x86_64) ARCH="amd64";;
    i686) ARCH="386";;
    i386) ARCH="386";;
  esac
}

discoverArch
OS=$(echo `uname`|tr '[:upper:]' '[:lower:]')

test -d "$OUTPUT_BIN" || mkdir -p "$OUTPUT_BIN"

function pulsar::verify_pulsarctl() {
    if test -x "$PULSARCTL_BIN"; then
        return
    fi
    return 1
}

function pulsar::ensure_pulsarctl() {
    if pulsar::verify_pulsarctl; then
        return 0
    fi
    echo "Get pulsarctl install.sh script ..."
    install_script=$(mktemp)
    trap "test -f $install_script && rm $install_script" RETURN
    curl --retry 10 -L -o $install_script https://raw.githubusercontent.com/streamnative/pulsarctl/master/install.sh
    chmod +x $install_script
    $install_script --user --version ${PULSARCTL_VERSION}
}


