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
regexp="^sn-platform-([0-9]{1,3})\.([0-9]{0,3})\.([0-9]{0,3})$"
mkdir -p $sn_platform_tag
cd $sn_platform_tag
if [[ $sn_platform_tag =~ $regexp ]]; then
    curl https://raw.githubusercontent.com/streamnative/charts/${sn_platform_tag}/charts/sn-platform/values.yaml -o values.yaml
    image_list=""
    for i in ${components[@]}; do
        repository=$(cat values.yaml | yq .images.$i.repository)
        tag=$(cat values.yaml | yq .images.$i.tag)
        echo "Downloading docker image: $repository:$tag"
        image_list=$image_list" $repository:$tag"
        docker pull $repository:$tag
    done

    uniq_image_list=($(echo ${image_list[*]} | sed 's/ /\n/g'|sort| uniq))
    for j in ${uniq_image_list[@]}; do
        image=$(echo ${j} | sed 's/:/-/g');
        docker save -o ${image}.tar ${j}
    done
    # test
    # docker save -o $sn_platform_tag.tar jimmidyson/configmap-reload:v0.3.0
else
    echo "Please use the correct version number format => sn-platform-x.x.x"
    echo "Currently only sn-platform images are supported for upload"
fi