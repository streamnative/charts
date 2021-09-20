Before running `helm install`, you need to decide how you run Pulsar.
Options can be specified using Helm's `--set option.name=value` command line option.

# Select configuration options

In each section, collect the options that are combined to use with the `helm install` command.

## Kubernetes namespace

By default, the Pulsar Helm chart is installed to a namespace called `pulsar`.

```shell
namespace: pulsar
```

To install the Pulsar Helm chart into a different Kubernetes namespace, you can include this option in the `helm install` command.

```bash
--set namespace=<different-k8s-namespace>
```

By default, the Pulsar Helm chart does not create the namespace.

```shell
namespaceCreate: false
```

To use the Pulsar Helm chart to create the Kubernetes namespace automatically, you can include this option in the `helm install` command.

```bash
--set namespaceCreate=true
```

## Persistence

By default, the Pulsar Helm chart creates Volume Claims with the expectation that a dynamic provisioner creates the underlying Persistent Volumes.

```shell
volumes:
  persistence: true
  # configure the components to use local persistent volume
  # the local provisioner should be installed prior to enable local persistent volume
  local_storage: false
```

To use local persistent volumes as the persistent storage for Helm release, you can install the [local-storage-provisioner](#install-local-storage-provisioner) and include the following option in the `helm install` command. 

```bash
--set volumes.local_storage=true
```

> **Note**
> 
> Before installing the production instance of Pulsar, ensure to plan the storage settings to avoid extra storage migration work. Because after initial installation, you must edit Kubernetes objects manually if you want to change storage settings.

The Pulsar Helm chart is designed for production use. To use the Pulsar Helm chart in a development environment (such as Minikube), you can disable persistence by including this option in the `helm install` command.

```bash
--set volumes.persistence=false
```

## Affinity 

By default, `anti-affinity` is enabled to ensure pods of same component can run on different nodes.

```shell
affinity:
  anti_affinity: true
```

To use the Pulsar Helm chart in a development environment (such as Minikube), you can disable `anti-affinity` by including this option in the  `helm install` command.

```bash
--set affinity.anti_affinity=false
```

## Components

The Pulsar Helm chart is designed for production usage. It deploys a production-ready Pulsar cluster, including Pulsar core components and StreamNative control center components.

You can customize the components to be deployed by turning on/off individual components.

```shell
## Components
##
## Control what components of Apache Pulsar to deploy for the cluster
components:
  # zookeeper
  zookeeper: true
  # bookkeeper
  bookkeeper: true
  # bookkeeper - autorecovery
  autorecovery: true
  # broker
  broker: true
  # functions
  functions: true
  # proxy
  proxy: true
  # toolset
  toolset: true
  # pulsar manager
  pulsar_manager: true

## Monitoring Components
##
## Control what components of the monitoring stack to deploy for the cluster
monitoring:
  # monitoring - prometheus
  prometheus: true
  # monitoring - grafana
  grafana: true
  # monitoring - node_exporter
  node_exporter: true
  # alerting - alert-manager
  alert_manager: true
```

## Docker images

This Pulsar Helm chart is designed to enable controlled upgrades. So it can configure independent image versions for components. You can customize the images by setting individual component.

```shell
## Images
##
## Control what images to use for each component
images:
  pulsar:
    # repository: streamnative/pulsar
    # tag: 2.4.0-d1d5aba08
    repository: apachepulsar/pulsar-all
    tag: 2.5.0
    pullPolicy: IfNotPresent
  functions:
    repository: apachepulsar/pulsar-all
    tag: 2.5.0
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

## TLS

This Pulsar Helm chart is using `cert-manager` to automatically provision TLS (Transport Layer Security) certificates for both brokers and proxies.

You can set `tls.enabled` to `true` to enable TLS encryption for both brokers and proxies. You can set `tls.proxy.enabled` and `tls.broker.enabled` to control whether enable TLS encryption for individual component.

```shell
tls:
  enabled: false
  proxy:
    enabled: false
  broker:
    enabled: false
```

If you enable TLS, you have to install [cert-manager](#install-cert-manager) before installing the Pulsar Helm chart. Then you can set `certs.internal_issuer.enabled` to `true` to generate `selfsigning` TLS certificates for both brokers and proxies.

```shell
certs:
  internal_issuer:
    enabled: false
    component: internal-cert-issuer
    type: selfsigning
```

You can also customize the settings for the generated TLS certificates by configuring the fields as below.

```shell
tls:
  enabled: false
  # common settings for generating certs
  common:
    # 90d
    duration: 2160h
    # 15d
    renewBefore: 360h
    organization:
      - pulsar
    keySize: 4096
    keyAlgorithm: rsa
    keyEncoding: pkcs8
  # settings for generating certs for proxy
  proxy:
    enabled: false
    cert_name: tls-proxy
    dnsNames:
    - "*"
    uriSANs:
    - "*"
    ipAddresses:
    - "*"
  # settings for generating certs for broker
  broker:
    enabled: false
    cert_name: tls-broker
    dnsNames:
    - "*"
    uriSANs:
    - "*"
    ipAddresses:
    - "*"
```

## Authentication

By default, authentication is disabled. To enable authentication, you can set `auth.authentication.enabled` to `true`.
Currently, the Pulsar Helm chart only supports JWT authentication provider. You can set `auth.authentication.provider` to `jwt` to use JWT authentication provider.

```shell
# Enable or disable broker authentication and authorization.
auth:
  authentication:
    enabled: false
    provider: "jwt"
    jwt:
      # Enable JWT authentication
      # If the token is generated by a secret key, set the usingSecretKey as true.
      # If the token is generated by a private key, set the usingSecretKey as false.
      usingSecretKey: false
  superUsers:
    # broker to broker communication
    broker: "broker-admin"
    # proxy to broker communication
    proxy: "proxy-admin"
    # pulsar-admin client to broker/proxy communication
    client: "admin"
```

To enable authentication, you can run [prepare helm release](#prepare-the-helm-release) to generate token secret keys and tokens for three super users specified in the `auth.superUsers` field. The generated token keys and super user tokens are uploaded and stored as Kubernetes secrets prefixed with `<pulsar-release-name>-token-`. You can use the following command to find those secrets.

```bash
kubectl get secrets -n <k8s-namespace>
```

## Authorization

By default, authorization is disabled. Authorization can be enabled only when Authentication is enabled.

```shell
auth:
  authorization:
    enabled: false
```

To enable authorization, you can include this option in the `helm install` command.

```bash
--set auth.authorization.enabled=true
```

## CPU and RAM resource requirements

By default, the resource requests and the number of replicas for the Pulsar components in the Pulsar Helm chart are adequate for a small production deployment. If you deploy a non-production instance, you can reduce the defaults to fit into a smaller cluster.

Once you have all of your configuration options collected, you can install dependent charts before installing the Pulsar Helm chart.

# Install dependent charts

## Install local storage provisioner

To use local persistent volumes as the persistent storage, you need to install a storage provisioner for local persistent volumes.

```shell
helm repo add streamnative https://charts.streamnative.io
helm repo update
helm install pulsar-storage-provisioner streamnative/local-storage-provisioner
```

## Install cert-manager

The Pulsar Helm chart uses [cert-manager](https://github.com/jetstack/cert-manager) to provision and manage TLS certificates automatically. To enable TLS encryption for brokers or proxies, you need to install the cert-manager first.

For details about how to install the cert-manager, follow the [official instructions](https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm).

Alternatively, we provide a bash script [install-cert-manager.sh](https://github.com/streamnative/charts/blob/master/scripts/cert-manager/install-cert-manager.sh) to install a cert-manager release to the namespace `cert-manager`.

# Prepare the Helm release

Once you have install all the dependent charts and collected all of your configuration options, you can run [prepare_helm_release.sh](https://github.com/streamnative/charts/blob/master/scripts/pulsar/prepare_helm_release.sh) to prepare the Helm release.

```bash
git clone charts https://github.com/streamnative/charts
cd charts
./scripts/pulsar/prepare_helm_release.sh -n <k8s-namespace> -k <helm-release-name>
```

The `prepare_helm_release` creates the following resources:

- A Kubernetes namespace for installing the Pulsar release
- A secret for storing the username and password of control center administrator. The username and password can be passed to `prepare_helm_release.sh` through flags `--control-center-admin` and `--control-center-password`. The username and password is used for logging into the Grafana dashboard and Pulsar Manager.
- JWT secret keys and tokens for three super users: `broker-admin`, `proxy-admin`, and `admin`. By default, it generates an asymmeric pubic/private key pair. You can choose to generate a symmeric secret key by specifying `--symmetric`.
    - `proxy-admin` role is used for proxies to communicate to brokers.
    - `broker-admin` role is used for inter-broker communications.
    - `admin` role is used by the admin tools.

# Deploy Pulsar cluster using Helm

Once you have finished the following three things, you can install a Helm release.

- Collect all of your configuration options
- Install dependent charts
- Prepare the Helm release:w

In this example, we name our Helm release `pulsar`.

```bash
helm repo add streamnative https://charts.streamnative.io
helm repo update
helm upgrade --install pulsar streamnative/pulsar \
    --timeout 600 \
    --set [your configuration options]
```

You can also use `--version <installation version>` option if you would like to install a specific version of Pulsar Helm chart.

# Monitor the deployment

A list of installed resources are output once the Pulsar cluster is deployed. This may take 5-10 minutes.

The status of the deployment can be checked by running the `helm status pulsar` command, which can also be done while the deployment is taking place if you run the command in another terminal.

# Access the Pulsar cluster

The default values will create a `ClusterIP` for the proxy which you can use to interact with the cluster. To find the IP addresses of those components, run the following command:

```bash
kubectl get service -n <k8s-namespace>
```
