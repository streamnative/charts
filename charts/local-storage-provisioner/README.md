# Official local storage provisioner Helm Chart

This is the officially supported Helm Chart for installing the local storage provisioner.

To use local persistent volumes as the persistent storage, you need to install a storage provisioner for [local persistent volumes](https://kubernetes.io/blog/2019/04/04/kubernetes-1.14-local-persistent-volumes-ga/).

## Requirements

Before installing the `local-storage-provisioner` operator, ensure to perform the following operations.

- Install [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl) 1.14 or higher, compatible with your cluster (+/- 1 minor release from your cluster).
- Install [`helm`](https://helm.sh/docs/intro/install/) v3 (3.0.2 or higher).
- Prepare a Kubernetes cluster, version 1.14 or higher.

## Install `local-storage-provisioner` operator

1. Create a Kubernetes namespace.

    ```
    kubectl create namespace <k8s-namespace>
    ```

2. Install the `local-storage-provisioner` operator.

    ```
    helm install local-storage-provisioner streamnative/local-storage-provisioner --namespace <k8s-namespace>
    ```

## Uninstall `local-storage-provisioner` operator 

Use the following command to uninstall `local-storage-provisioner` operator.

```bash
helm uninstall local-storage-provisioner
```
