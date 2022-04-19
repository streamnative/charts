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
    bank_vaults
    custom_metric_server_prometheus
    custom_metric_server
    pulsar_metadata
    configmapReload
    external_dns
    functionnmesh
    pulsar_operator
    bookkeeper_operator
    zookeeper_operator
    cert_manager_controller
    cert_manager_cainjector
    cert_manager_webhook
    vault_operator)
sn_platform_tag=$1
regexp="^sn-platform-([0-9]{1,3})\.([0-9]{0,3})\.([0-9]{0,3})$"
mkdir -p $sn_platform_tag
cd $sn_platform_tag
# if [[ $sn_platform_tag =~ $regexp ]]; then
# curl https://raw.githubusercontent.com/streamnative/charts/${sn_platform_tag}/charts/sn-platform/values.yaml -o values.yaml
curl https://raw.githubusercontent.com/streamnative/charts/fixed/support-upload-image-to-aws/charts/sn-platform/values.yaml -o values.yaml
image_list=""
for i in ${components[@]}; do
    repository=$(cat values.yaml | yq .images.$i.repository)
    tag=$(cat values.yaml | yq .images.$i.tag)
    echo "Downloading docker image: $repository:$tag"
    image_list=$image_list" $repository:$tag"
    docker pull $repository:$tag
done
echo ${image_list}

uniq_image_list=($(echo ${image_list[*]} | sed 's/ /\n/g'|sort| uniq))
for j in ${uniq_image_list[@]}; do
    image=$(echo ${j} | sed 's/:/-/g;s/\//-/g');
    docker save -o ${image}.tar ${j}
    echo https://downloads-streamnative-cloud.oss-cn-beijing.aliyuncs.com/sn-products/$sn_platform_tag/${image}.tar
done
    # test
    # docker save -o $sn_platform_tag.tar jimmidyson/configmap-reload:v0.3.0
# else
#     echo "Please use the correct version number format => sn-platform-x.x.x"
#     echo "Currently only sn-platform images are supported for upload"
# fi