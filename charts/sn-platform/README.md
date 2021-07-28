# Official StreamNative Platform Helm Chart

This is the officially supported Helm Chart for installing StreamNative Platform on Kubernetes.

To deploy StreamNative Platform to Kubernetes, you need to install the following charts:

- `sn-platform`
- `pulsar-operator`
- `function-mesh-operator`

## Feature

The `sn-platform` Chart includes all the components of Apache Pulsar for a complete experience.

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

## Install StreamNative Platform

This section describes how to install StreamNative Platform on native Kubernetes clusters. We also provide a guide on deploying StreamNative Platform on AWS. For details, see [here](https://docs.streamnative.io/platform/v1.1.0/operator-guides/deploy/deploy-snp-aws).

### Requirements

To use the `sn-platform` chart to deploy StreamNative Platform to Kubernetes, the followings are required.

- Install [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl) 1.16 or higher, compatible with your cluster (+/- 1 minor release from your cluster).
- Install [`helm`](https://helm.sh/docs/intro/install/) v3 (3.0.2 or higher).
- Prepare a Kubernetes cluster, version 1.16 or higher.

### Steps

To install StreamNative Platform on native Kubernetes clusters, follow these steps.

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
    export PULSAR_CHART=streamnative/sn-platform
    ```

## Deploy Pulsar clusters

To deploy a Pulsar cluster, follow these steps.

1. Add the environment variables for the Pulsar Chart directory, Pulsar cluster name, and Kubernetes namespace.

    ```
    # If you use offline version, export PULSAR_CHART first.
    export PULSAR_CHART=/path/to/pulsar/chart
    # Define your pulsar cluster name
    export RELEASE_NAME=PULSAR_CLUSTER
    # Define the k8s namespace to install the pulsar cluster
    export NAMESPACE=KUBERNETES_NAMESPACE
    ```

2. Create a Kubernetes namespace for your Pulsar cluster.

    ```
    kubectl create namespace $NAMESPACE
    ```

3. Define a Pulsar cluster configuration file.

    [Here](https://raw.githubusercontent.com/streamnative/examples/master/platform/values_cluster.yaml) is an example of the YAML file used for configuring the Pulsar cluster.

4. Apply the YAML file to create a Pulsar cluster.

    ```
    helm install -f /path/to/pulsar/file.yaml $RELEASE_NAME $PULSAR_CHART --set initialize=true --set namespace=$NAMESPACE
    ```

5. (Optional) Update your Pulsar cluster.

    You can update your Pulsar cluster by updating the YAML file and then execute the `helm upgrade` command.

    ```
    helm upgrade -f /path/to/pulsar/file.yaml $RELEASE_NAME $PULSAR_CHART
    ```

## Upgrade StreamNative Platform

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

       ```bash
       helm upgrade --install pulsar-operator streamnative/pulsar-operator -n KUBERNETES_NAMESPACE
       ```

   - FunctionMesh operator

       ```bash
       helm upgrade --install function-mesh streamnative/function-mesh-operator -n KUBERNETES_NAMESPACE
       ```

    For details about how to upgrade StreamNative Platform, see [here](https://docs.streamnative.io/platform/latest/operator-guides/upgrade/sn-upgrade).

## Uninstall StreamNative Platform

To uninstall StreamNative Platform, execute these commands.

```bash
export NAMESPACE=KUBERNETES_NAMESPACE
helm uninstall vault-operator -n $NAMESPACE
helm uninstall cert-manager -n $NAMESPACE
helm uninstall pulsar-operator -n $NAMESPACE
helm uninstall function-mesh -n $NAMESPACE
```