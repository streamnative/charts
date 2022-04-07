#!/bin/bash
components=(
    zookeeper
    zookeeper.customTools.backup
    zookeeper.customTools.restore
    bookie
    presto
    autorecovery
    broker
    proxy
    pulsar_detector
    functions
    function_worker
    toolset
    toolset.kafka
    prometheus
    alert_manager
    grafana
    streamnative_console
    node_exporter
    nginx_ingress_controller
    vault
    vault_init
    custom_metric_server_prometheus
    custom_metric_server
    pulsar_metadata
    configmapReload
    external_dns)
sn_platform_tag=$1
curl https://raw.githubusercontent.com/streamnative/charts/${sn_platform_tag}/charts/sn-platform/values.yaml -o values.yaml
image_list=""
for i in ${components[@]}; do
    repository=$(cat values.yaml | yq .images.$i.repository)
    tag=$(cat values.yaml | yq .images.$i.tag)
    echo "Downloading docker image: $repository:$tag"
    image_list=image_list" $repository:$tag"
    docker pull $repository:$tag
done

# docker save -o $sn_platform_tag.tar $image_list
# test
docker save -o $sn_platform_tag.tar jimmidyson/configmap-reload:v0.3.0
