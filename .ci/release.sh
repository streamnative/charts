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
CHARTS_PKGS=${CHARTS_HOME}/.chart-packages
CHARTS_INDEX=${CHARTS_HOME}/.chart-index
CHARTS_REPO=${CHARTS_REPO:-"https://charts.streamnative.io"}
OWNER=${OWNER:-streamnative}
REPO=${REPO:-charts}
GITHUB_TOKEN=${GITHUB_TOKEN:-"UNSET"}
PUBLISH_CHARTS=${PUBLISH_CHARTS:-"false"}
GITUSER=${GITUSER:-"UNSET"}
GITEMAIL=${GITEMAIL:-"UNSET"}

# hack/common.sh need this variable to be set
PULSAR_CHART_HOME=${CHARTS_HOME}

source ${CHARTS_HOME}/hack/common.sh
source ${CHARTS_HOME}/.ci/git.sh

# allow overwriting cr binary
CR=${CR:-"${CR_BIN}"}

function release::ensure_dir() {
    local dir=$1
    if [[ -d ${dir} ]]; then
        rm -rf ${dir}
    fi
    mkdir -p ${dir}
}

function release::find_changed_charts() {
    local charts_dir=$1
    echo $(git diff --find-renames --name-only "$latest_tag_rev" -- ${charts_dir} | cut -d '/' -f 2 | uniq)
}

function release::package_chart() {
    local chart=$1
    echo "Packaging chart '$chart'..."
    helm package ${CHARTS_HOME}/charts/$chart --destination ${CHARTS_PKGS}
}

function release::upload_packages() {
    ${CR} upload --owner ${OWNER} --git-repo ${REPO} -t ${GITHUB_TOKEN} --package-path ${CHARTS_PKGS}
}

function release::update_chart_index() {
    ${CR} index -o ${OWNER} -r ${REPO} -t "${GITHUB_TOKEN}" -c ${CHARTS_REPO}
}

function release::publish_charts() {
    git config user.email "${GITEMAIL}"
    git config user.name "${GITUSER}"

    git checkout gh-pages
    cp --force ${CHARTS_INDEX}/index.yaml index.yaml
    git add index.yaml
    git commit --message="Publish new charts to ${CHARTS_REPO}" --signoff
    git push origin gh-pages 
}

# install cr
hack::ensure_cr

# fetch tags
git::fetch_tags

latest_tag=$(git::find_latest_tag)
echo $latest_tag

latest_tag_rev=$(git::get_revision "$latest_tag")
echo "$latest_tag_rev $latest_tag (latest tag)"

head_rev=$(git::get_revision HEAD)
echo "$head_rev HEAD"

if [[ "$latest_tag_rev" == "$head_rev" ]]; then
    echo "Do nothing. Exiting ..."
    exit
fi

release::ensure_dir ${CHARTS_PKGS}
release::ensure_dir ${CHARTS_INDEX}

for chart in $(release::find_changed_charts charts); do
    release::package_chart ${chart}
done

release::upload_packages
release::update_chart_index

if [[ "x${PUBLISH_CHARTS}" == "xtrue" ]]; then
    release::publish_charts
fi
