#!/usr/bin/env bash
#
# Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved.
#

function git::fetch_tags() {
    echo "Fetching tags ..."
    git fetch --tags
    git describe --tags --abbrev=0
}

function git::find_latest_tag() {
    if ! git describe --tags --abbrev=0 2> /dev/null; then
        git rev-list --max-parents=0 --first-parent HEAD
    fi
}

function git::get_revision() {
    local tag=$1
    echo "$(git rev-parse --verify ${tag})"
}
