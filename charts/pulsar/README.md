
# Apache Pulsar Helm Chart

> Note: Most of the changes of this chart have been contributed back to https://github.com/apache/pulsar-helm-chart

This is the officially supported Helm Chart for installing Apache Pulsar on Kubernetes. 

## Features

This Helm Chart includes all the components of Apache Pulsar for a complete experience.

- [x] Pulsar core components:
    - [x] ZooKeeper
    - [x] Bookies
    - [x] Brokers
    - [x] Functions
    - [x] Proxies
- [x] Management & monitoring components:
    - [x] Pulsar Manager
    - [x] Prometheus
    - [x] Grafana

It includes support for:

- [x] Security
    - [x] Automatically provisioned TLS certs, using [Jetstack](https://www.jetstack.io/)'s [cert-manager](https://cert-manager.io/docs/)
        - [x] self-signed
        - [x] [Let's Encrypt](https://letsencrypt.org/)
    - [x] TLS Encryption
        - [x] Proxy
        - [x] Broker
        - [x] Toolset
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

## Environment setup

Before proceeding to deploying Pulsar, you need to prepare your environment.

### Tools

- Install `helm` on your computer. For details, see [here](https://helm.sh/docs/intro/install/).
- Install `kubectl` on your computer. For details, see [here](https://kubernetes.io/docs/tasks/tools/#kubectl).

## Add Apache Pulsar Chart to local Helm repository

To add this chart to your local Helm repository, execute this command.

```bash
helm repo add streamnative https://charts.streamnative.io
```

## Prepare Kubernetes clusters

To use this chart, you need a Kubernetes cluster whose version is 1.14 or higher, due to the usage of certain Kubernetes features.

We provide some instructions to guide you through the preparation for the [Google Kubernetes Engine (GKE)](../../docs/pulsar/install/gke.md).

## Deploy Pulsar to Kubernetes

1. Clone this repository and switch to the target directory.

    ```bash
    git clone https://github.com/streamnative/charts.git
    cd charts
    ```

2. Run `prepare_helm_release.sh` to create required Kubernetes resources for installing this Helm chart.

    - A Kubernetes namespace for installing the Pulsar release (if `-c` is specified)
    - Create the JWT secret keys and tokens for three superusers: `broker-admin`, `proxy-admin`, and `admin`.
      By default, it generates the asymmetric pubic/private key pair. You can choose to generate symmetric secret key by specifying `--symmetric` in the following command.
        - `proxy-admin` role is used for proxies to communicate to brokers.
        - `broker-admin` role is used for inter-broker communications.
        - `admin` role is used by the admin tools.

    ```bash
    ./scripts/pulsar/prepare_helm_release.sh -n <k8s-namespace> -k <pulsar-release-name> -c
    ```

3. Add Loki Helm Charts repository and update charts.

    ```bash
    helm repo add loki https://grafana.github.io/loki/charts
    helm dependency update charts/pulsar
    ```

4. Use the Pulsar Helm charts to install Apache Pulsar. 

    > **Note**  
    > Please specify `--set initialize=true` when installing a release at the first time. `initialize=true` will start initialize jobs to initialize the cluster metadata for both BookKeeper and Pulsar clusters.

    ```bash
    helm install --set initialize=true <pulsar-release-name> streamnative/pulsar
    ```

5. Access the Pulsar cluster.

    The default values will create a `ClusterIP` for the proxy that you can use to interact with the cluster. To find the IP address of proxy use:

    ```bash
    kubectl get service -n <k8s-namespace>
    ```

## Customize the deployment 

We provide a [detailed guideline](../../docs/pulsar/install/deployment.md) for you to customize the Helm Chart for a production-ready deployment.

You can also checkout out the example values file for different deployments.

- [Deploy ZooKeeper only](examples/pulsar/values-cs.yaml)
- [Deploy a Pulsar cluster with an external configuration store](../../examples/pulsar/values-cs.yaml)
- [Deploy a Pulsar cluster with local persistent volume](../../examples/pulsar/values-local-pv.yaml)
- [Deploy a Pulsar cluster to Minikube](../../examples/pulsar/values-minikube.yaml)
- [Deploy a Pulsar cluster with no persistence](../../examples/pulsar/values-no-persistence.yaml)
- [Deploy a Pulsar cluster with TLS encryption](../../examples/pulsar/values-tls.yaml)
- [Deploy a Pulsar cluster with JWT authentication using symmetric key](../../examples/pulsar/values-jwt-symmetric.yaml)
- [Deploy a Pulsar cluster with JWT authentication using asymmetric key](../../examples/pulsar/values-jwt-asymmetric.yaml)
- [Deploy a Pulsar cluster with KoP, Istio, and TLS encryption](../../examples/pulsar/values-kop-tls-istio.yaml)

## Upgrading

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

## Uninstall Pulsar Chart

To uninstall the Pulsar Chart, execute the following command.

```bash
helm uninstall <pulsar-release-name>
```

For the purposes of continuity, these charts have some Kubernetes objects that are not removed when performing `helm uninstall`.
These items we require you to *conciously* remove them, as they affect re-deployment should you choose to.

* PVCs for stateful data, which you must *consciously* remove
    - ZooKeeper: This is your metadata.
    - BookKeeper: This is your data.
    - Prometheus: This is your metrics data, which can be safely removed.
* Secrets, if generated by our [prepare release script](https://github.com/streamnative/charts/blob/master/scripts/pulsar/prepare_helm_release.sh). They contain secret keys, tokens, etc. You can use [cleanup release script](https://github.com/streamnative/charts/blob/master/scripts/pulsar/cleanup_helm_release.sh) to remove these secrets and tokens as needed.

## Migration

If you want to migrate from [apache/pulsar-helm-chart](https://github.com/apache/pulsar-helm-chart) to the streamantive/charts,
you can use the [values-migrate.yaml](../../examples/pulsar/values-migrate.yaml) to upgrade your cluster for migrating to the streamnative/charts.

```bash
helm upgrade --set namespace=<cluster-namespace> --set initialize=false --values example/pulsar/values-migrate.yaml <pulsar-release-name> streamnative/pulsar --version <streamnative/pulsar-chart-version>
```
