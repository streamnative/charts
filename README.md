<!--

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.

-->

# Pulsar Helm Chart

This directory contains the Helm Chart required to do a complete Pulsar deployment on Kubernetes.

## Prerequistese

> Note: We recommend that you are using the specified version below. if you are using the other version and have some problems with it, welcome to create an issue or contribute to the Helm Charts.

* Kubernetes cluster 1.15+
* Helm 3.0+

## Install Helm

Before you start, you need to install helm.
Following [helm documentation](https://docs.helm.sh/using_helm/#installing-helm) to install it.

## Install Pulsar Chart

1. Clone this repo.
    ```shell
    git clone https://github.com/streamnative/charts.git
    ```

2. Go to Pulsar helm chart directory
    ```shell
    cd ${PULSAR_HOME}/pulsar/charts
    ```
    
3. Install helm chart.
    ```shell
    helm install --values pulsar/values.yaml pulsar-cluster ./pulsar
    ```
    > Tip: you can use the flag `--wait` to wait for the charts install complete.

Once the helm chart is completed on installation, you can access the cluster via:

- Web service url: `http://$(minikube ip):30001/`
- Pulsar service url: `pulsar://$(minikube ip):30002/`

### Configure the way how to expose service

* **Ingress**: The ingress cntroller must be installed in the Kubernetes cluster.
* **ClusterIP**: Exposes the service no a cluster-internal IP. Choosing this value makes the service only reachable from within the cluster.
* **NodePort**: Exposes the service on each Node’s IP at a static port (the NodePort). You’ll be able to contact the NodePort service, from outside the cluster, by requesting `NodeIP:NodePort`.
* **LoadBalancer**: Exposes the service exterrnally using a cloud provider's load balancer.

> Note: By default, most of all services use the `ClusterIP`, the `Proxy` service uses `LoadBalancer` to expose and provides service, so you can communacate with Pulsar by the proxy.

> Note: If you want to configure the ingress to expose the service, we recommend you to use the GKE cluster. You can enable the ingress deployment with change the `ingress.cnotrller.enable` to `true` in the `values.yaml`. When enabling the ingress, you might need to [enable external DNS](docs/external_dns.md).

### Configure using local PV in GKE

For how to deploy pulsar to GKE using local PV, please refer to [deploy Pulsar to GKE using loccal PV](docs/gke_local_pv.md).

### Configure the secrets to enable TLS

For how to eenable TLS, please refer to [Enable TLS](docs/tls-cert-manager.md).

### Configure the image for the service

All images the Charts used are managed under the `images` in `values.yaml`.

```
## Which pulsar image to use
images:
  pulsar:
    # repository: streamnative/pulsar
    # tag: 2.4.0-d1d5aba08
    repository: apachepulsar/pulsar-all
    tag: 2.4.2
    pullPolicy: IfNotPresent
  prometheus:
    repository: prom/prometheus
    tag: v1.6.3
    pullPolicy: IfNotPresent
  alert_manager:
    repository: prom/alertmanager
    tag: v0.20.0
    pullPolicy: IfNotPresent
  grafana:
    repository: streamnative/apache-pulsar-grafana-dashboard-k8s
    tag: 0.0.4
    pullPolicy: IfNotPresent
  pulsar_manager:
    repository: apachepulsar/pulsar-manager
    tag: v0.1.0
    pullPolicy: IfNotPresent
    hasCommand: false
  node_exporter:
    repository: prom/node-exporter
    tag: v0.16.0
    pullPolicy: "IfNotPresent"
  nginx_ingress_controller:
    repository: quay.io/kubernetes-ingress-controller/nginx-ingress-controller
    tag: 0.26.2
    pullPolicy: "IfNotPresent"

```

When you need to use other images for the service, you can replace the `repository` and `tag` with the image you need.
