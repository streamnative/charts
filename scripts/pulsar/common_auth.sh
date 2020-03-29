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

if [ -z "$CHART_HOME" ]; then
    echo "error: CHART_HOME should be initialized"
    exit 1
fi

OUTPUT=${CHART_HOME}/output
OUTPUT_BIN=${OUTPUT}/bin
PULSARCTL_VERSION=v0.4.0
PULSARCTL_BIN=$OUTPUT_BIN/pulsarctl

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
    echo "Installing pulsarctl $PULSARCTL_VERSION..."
    tmpfile=$(mktemp)
    trap "test -f $tmpfile && rm $tmpfile" RETURN
    curl --retry 10 -L -o $tmpfile https://github.com/streamnative/pulsarctl/releases/download/${PULSARCTL_VERSION}/pulsarctl-${ARCH}-${OS}
    mv $tmpfile $PULSARCTL_BIN
    chmod +x $PULSARCTL_BIN
}


