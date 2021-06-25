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

# Official Helm Charts for Apache Pulsar and StreamNative Platform

These are the officially supported Helm Charts for install Apache Pulsar or StreamNative Platform on Kubernetes.

## Apache Pulsar

### General information

To deploy Apache Pulsar to Kubernetes, you need to install the following charts.

- `pulsar`
- `local-storage-provisioner`

The Pulsar Chart includes all the components of Apache Pulsar for a complete experience.

- [x] Pulsar core components:
    - [x] ZooKeeper
    - [x] Bookies
    - [x] Brokers
    - [x] Function workers
    - [x] Proxies
    - [x] Kafka-on-Pulsar
    - [x] Presto
- [x] Control Center:
    - [x] Pulsar Manager
    - [x] Node Exporter
    - [x] Prometheus
    - [x] Grafana
    - [x] Grafana Loki
    - [x] Alert Manager

It includes support for:

- [x] Security
    - [x] Automatically provisioned TLS certs, using [Jetstack](https://www.jetstack.io/)'s [cert-manager](https://cert-manager.io/docs/)
        - [x] self-signed
        - [x] [Let's Encrypt](https://letsencrypt.org/)
    - [x] TLS Encryption
        - [x] Proxy
        - [x] Broker
        - [x] Toolset
        - [x] Kafka-on-Pulsar
        - [x] Bookie
        - [x] ZooKeeper
    - [x] Authentication
        - [x] JWT
        - [ ] Mutal TLS
        - [ ] Kerberos
    - [x] Authorization
- [x] Storage
    - [x] Non-persistence storage
    - [x] Persistence Volume
    - [x] Local Persistent Volumes
    - [ ] Tiered Storage
- [x] Functions
    - [x] Kubernetes Runtime
    - [x] Process Runtime
    - [x] Thread Runtime
- [x] Operations
    - [x] Independent Image Versions for all components, enabling controlled upgrades
- [x] External Connectivies
    - [x] External DNS
    - [x] Control Center Ingress

### Requirements

To use the Pulsar Chart to deploy Apache Pulsar to Kubernetes, the followings are required.

- Install [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl) 1.14 or higher, compatible with your cluster (+/- 1 minor release from your cluster).
- Install [`helm`](https://helm.sh/docs/intro/install/) v3 (3.0.2 or higher).
- Prepare a Kubernetes cluster, version 1.14 or higher.

### Prepare Kubernetes clusters

You need a Kubernetes cluster (version 1.14 or higher), due to the usage of certain Kubernetes features.

We provide some instructions to guide you through the preparation for the following cloud providers.

- Google Kubernetes Engine (TBD)
- Amazon EKS (TBD)

### Deploy Pulsar cluster to Kubernetes cluster

1. Install the this repository to the local Helm repository.

    ```bash
    helm repo add streamnative https://charts.streamnative.io
    ```

    > **NOTE**
    > 
    > Please specify `--set initialize=true` when installing a release at the first time. `initialize=true` will start initialize jobs to initialize the cluster metadata for both BookKeeper and Pulsar clusters.

    ```bash
    helm install --set initialize=true <release-name> streamnative/pulsar
    ```

2. Clone this repository and switch to the target directory.

    ```bash
    git clone https://github.com/streamnative/charts.git
    cd charts
    ```

3. Execute the `prepare_helm_release.sh` command to create required Kubernetes resources for installing this Helm chart.

    - A Kubernetes namespace for installing the Pulsar release (if `-c` is specified)
    - Create the JWT secret keys and tokens for three superusers: `broker-admin`, `proxy-admin`, and `admin`.
      By default, it generates asymmetric pubic/private key pair. You can choose to generate symmetric secret key
      by specifying `--symmetric` in the following command.
        - `proxy-admin` role is used for proxies to communicate to brokers.
        - `broker-admin` role is used for inter-broker communications.
        - `admin` role is used by the admin tools.

    ```bash
    ./scripts/pulsar/prepare_helm_release.sh -n <k8s-namespace> -k <pulsar-release-name> -c
    ```

4. Add the Loki Helm Chart repository and update the charts.

    ```bash
    helm repo add loki https://grafana.github.io/loki/charts
    helm dependency update pulsar
    ```

5. Use the Pulsar Chart to deploy the Pulsar cluster.

    > **NOTE**
    > 
    > Please specify `--set initialize=true` when installing a release at the first time. `initialize=true` will start initialize jobs to initialize the cluster metadata for both BookKeeper and Pulsar clusters.

    This command installs a Pulsar cluster to Kubernetes.

    ```bash 
    helm install --set initialize=true <pulsar-release-name> streamnative/pulsar
    ```

6. Access the Pulsar cluster.

    The default values will create a `ClusterIP` for the Pulsar proxy that you can use to interact with the cluster. To find the IP address of the Pulsar proxy, execute this command.

    ```bash
    kubectl get service -n <k8s-namespace>
    ```

#### Customize deployment 

You can check out the example files for different deployments.

- [Deploy ZooKeeper only](examples/pulsar/values-cs.yaml)
- [Deploy a Pulsar cluster with an external configuration store](examples/pulsar/values-cs.yaml)
- [Deploy a Pulsar cluster with local persistent volume](examples/pulsar/values-local-pv.yaml)
- [Deploy a Pulsar cluster to Minikube](examples/pulsar/values-minikube.yaml)
- [Deploy a Pulsar cluster with no persistence](examples/pulsar/values-no-persistence.yaml)
- [Deploy a Pulsar cluster with TLS encryption](examples/pulsar/values-tls.yaml)
- [Deploy a Pulsar cluster with JWT authentication using symmetric key](examples/pulsar/values-jwt-symmetric.yaml)
- [Deploy a Pulsar cluster with JWT authentication using asymmetric key](examples/pulsar/values-jwt-asymmetric.yaml)

### Upgrade Pulsar

Once your Pulsar Chart is installed, configuration changes and chart updates should be done using the `helm upgrade` command.

If you are updating images used by the Pulsar Chart, you can specify `imagePuller.hook.enabled` to enable a Helm hook to pull images before
deploying a newer Helm release. The `imagePuller` ensures all the images are pulled to all Kubernetes hosts before deploying the Helm release.

```bash
helm repo add streamnative https://charts.streamnative.io/
helm repo update
helm get values <pulsar-release-name> > pulsar.yaml
helm upgrade -f pulsar.yaml \
    [--set imagePuller.hook.enabled=true] \
    <pulsar-release-name> streamnative/pulsar
```

### Uninstall Pulsar Chart

To uninstall the Pulsar Chart, execute the following command.

```bash
helm uninstall <pulsar-release-name>
```

For the purposes of continuity, these charts have some Kubernetes objects that are not removed when performing `helm uninstall`.
These items we require you to *conciously* remove them, as they affect re-deployment should you choose to.

* PVCs for stateful data, which you must *consciously* remove
    - ZooKeeper: this is your metadata.
    - BookKeeper: this is your data.
    - Prometheus: this is your metrics data, which can be safely removed.
* Secrets, if generated by our [prepare release script](https://github.com/streamnative/charts/blob/master/scripts/pulsar/prepare_helm_release.sh). They contain secret keys, tokens, etc. You can use [cleanup release script](https://github.com/streamnative/charts/blob/master/scripts/pulsar/cleanup_helm_release.sh) to remove these secrets and tokens as needed.

### Migration

To migrate from [apache/pulsar-helm-chart](https://github.com/apache/pulsar-helm-chart) to the streamantive/charts,
you can use the [values-migrate.yaml](./examples/pulsar/values-migrate.yaml) to upgrade your cluster for migrating to the streamnative/charts.

```bash
helm upgrade --set namespace=<cluster-namespace> --set initialize=false --values example/pulsar/values-migrate.yaml <pulsar-release-name> streamnative/pulsar --version <streamnative/pulsar-chart-version>
```

## StreamNative Platform

### General information

To deploy Apache Pulsar to Kubernetes, you need to install the following charts.

- `sn-pulsar`
- `pulsar-operator`
- `function-mesh-operator`

The `sn-pulsar` Chart includes all the components of Apache Pulsar for a complete experience.

- [x] Pulsar core components:
    - [x] ZooKeeper
    - [x] Bookies
    - [x] Brokers
    - [x] Function workers
    - [x] Proxies
    - [x] Kafka-on-Pulsar
    - [x] Presto
- [x] StreamNative Control Center:
    - [x] StreamNative Console
    - [x] Node Exporter
    - [x] Prometheus
    - [x] Grafana
    - [ ] Grafana Loki
    - [x] Alert Manager

It includes support for:

- [x] Security
    - [x] Automatically provisioned TLS certs, using [Jetstack](https://www.jetstack.io/)'s [cert-manager](https://cert-manager.io/docs/)
        - [x] self-signed
        - [x] [Let's Encrypt](https://letsencrypt.org/)
    - [x] TLS Encryption
        - [x] Proxy
        - [x] Broker
        - [x] Toolset
        - [x] Kafka-on-Pulsar
        - [x] Bookie
        - [x] ZooKeeper
    - [x] Authentication
        - [x] JWT
        - [ ] Mutal TLS
        - [ ] Kerberos
    - [x] Authorization
- [x] Storage
    - [x] Non-persistence storage
    - [x] Persistence Volume
    - [x] Local Persistent Volumes
    - [ ] Tiered Storage
- [x] Functions
    - [x] Kubernetes Runtime
- [x] Operations
    - [x] Independent Image Versions for all components, enabling controlled upgrades
- [x] External Connectivies
    - [x] External DNS
    - [x] Control Center Ingress

### Requirements

For details about requirements on deploying StreamNative Platform, see [requirements](#requirements).

### Prepare Kubernetes clusters

For details about how to prepare Kubernetes clusters on GKE or EKS, see [prepare for Kuberbetes clusters](#prepare-kubernetes-clusters).

### Install StreamNative Platform

To install StreamNative Platform, follow these steps.

1. Install the StreamNative repositories.

    ```
    helm repo add streamnative https://charts.streamnative.io
    helm repo add banzaicloud-stable https://kubernetes-charts.banzaicloud.com
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    ```

2. Create a Kubernetes namespace and add the environment variable for the Kubernetes namespace.

    ```
    kubectl create namespace KUBERNETES_NAMESPACE
    export NAMESPACE=KUBERNETES_NAMESPACE
    ```

3. Install the Vault operator.
   
    The Vault operator creates and maintains highly-available Vault clusters on Kubernetes, allowing users to easily deploy and manage Vault clusters for their applications.

    ```
    helm upgrade --install vault-operator banzaicloud-stable/vault-operator -n $NAMESPACE
    ```

4. Install the cert-manager.

    The cert-manager is a native [Kubernetes](https://kubernetes.io/) certificate management controller. It helps issue certificates from [HashiCorp Vault](https://www.vaultproject.io/). The cert-manager ensures that certificates are valid and up-to-date, and attempts to renew certificates at a configured time before expiry.

    The cert-manager requires a number of CRD resources to be installed into your cluster as part of installation. To automatically install and manage the CRDs as part of your Helm release, you must add the `--set installCRDs=true` flag to your Helm installation command.

    ```
    helm upgrade --install cert-manager jetstack/cert-manager -n $NAMESPACE --set installCRDs=true
    ```

5. Install the Pulsar operator.

    ```
    helm upgrade --install pulsar-operator streamnative/pulsar-operator -n $NAMESPACE
    ```

6. Install the FunctionMesh operator.

   [Function Mesh](https://docs.streamnative.io/platform/v1.0.0/concepts/functionmesh-concepts) is a serverless and purpose-built framework for orchestrating multiple [Pulsar Functions](https://docs.streamnative.io/platform/v1.0.0/concepts/pulsar-function-concepts) and [Pulsar IO connectors](https://docs.streamnative.io/platform/v1.0.0/concepts/pulsar-io-concepts) for stream processing applications.

    ```
    helm upgrade --install function-mesh streamnative/function-mesh-operator -n $NAMESPACE 
    ```

7. Set the environment variable `PULSAR_CHART`.

    ```
    export PULSAR_CHART=streamnative/sn-pulsar
    ```

### Upgrade StreamNative Platform

To upgrade StreamNative Platform, follow these steps.

1. Get the latest version of the Vault operator, cert-manager operator, Pulsar operator, and FunctionMesh operators.

    ```
    helm repo update
    ```

2. Use the `helm upgrade` command to upgrade these operators one by one.

   - Vault operator

       ```
       helm upgrade --install vault-operator banzaicloud-stable/vault-operator -n KUBERNETES_NAMESPACE
       ```

   - cert-manager operator

       ```
       helm upgrade --install cert-manager jetstack/cert-manager -n KUBERNETES_NAMESPACE --set installCRDs=true
       ```

   - Pulsar operator

       ```
       helm upgrade --install pulsar-operator streamnative/pulsar-operator -n KUBERNETES_NAMESPACE
       ```

   - FunctionMesh operator

       ```
       helm upgrade --install function-mesh streamnative/function-mesh-operator -n KUBERNETES_NAMESPACE
       ```

For details about how to upgrade StreamNative Platform, see [here](https://docs.streamnative.io/platform/latest/operator-guides/upgrade/sn-upgrade).

### Uninstall StreamNative Platform

To uninstall StreamNative Platform, execute these commands.

```
export NAMESPACE=KUBERNETES_NAMESPACE
helm uninstall vault-operator -n $NAMESPACE
helm uninstall cert-manager -n $NAMESPACE
helm uninstall pulsar-operator -n $NAMESPACE
helm uninstall function-mesh -n $NAMESPACE
```

### Migration

For details about migrating from [apache/pulsar-helm-chart](https://github.com/apache/pulsar-helm-chart) to the streamantive/charts, see [migration](#migration).

------
## Troubleshooting

We have done our best to make these charts as seamless as possible. Occasionally troubles do surface outside of our control. We have collected tips and tricks for troubleshooting common issues. Please examine these first before raising an [issue](https://github.com/streamnative/charts/issues/new/choose), and feel free to add to them by raising a [Pull Request](https://github.com/streamnative/charts/compare).
