# Official ImagePuller Chart

This is the officially supported Helm Chart for installing an Image Puller which pulls docker images required for deploying Apache Pulsar or StreamNative Platform.

## Requirements

Before installing the Image Puller chart, ensure to perform the following operations.

- Install [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl) 1.14 or higher, compatible with your cluster (+/- 1 minor release from your cluster).
- Install [`helm`](https://helm.sh/docs/intro/install/) v3 (3.0.2 or higher).
- Prepare a Kubernetes cluster, version 1.14 or higher.

## Install Image Puller chart

1. Create a Kubernetes namespace.

    ```
    kubectl create namespace <k8s-namespace>
    ```

2. Install the Image Puller chart.

    ```
    helm install image-puller streamnative/image-puller --namespace <k8s-namespace>
    ```

## Uninstall Image Puller chart

Use the following command to uninstall `local-storage-provisioner` operator.

```bash
helm uninstall image-puller
```