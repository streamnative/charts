# Official FunctionMesh Helm Chart

This is the officially supported Helm Chart for installing FunctionMesh on Kubernetes.

## Requirements

Before installing the FunctionMesh operator, ensure to perform the following operations.

- Kubernetes server 1.12 or higher.
- Create and connect to a [Kubernetes cluster](https://kubernetes.io/).
- Create a [Pulsar cluster](https://pulsar.apache.org/docs/en/kubernetes-helm/) in the Kubernetes cluster.
- Deploy [Pulsar Functions](https://pulsar.apache.org/docs/en/functions-overview/).
- (Optional) Enable [Role-based Access Control (RBAC)](https://kubernetes.io/docs/reference/access-authn-authz/rbac/).
- Install [`helm`](https://helm.sh/docs/intro/install/) v3 (3.0.2 or higher).

## Install FunctionMesh operator

1. Register the CRDs with the Kubernetes cluster.

    ```
    kubectl apply -f ./crds
    ```

2. Create a Kubernetes namespace.

    ```
    kubectl create namespace <k8s-namespace>
    ```

3. Install the FunctionMesh operator.

    ```
    helm install function-mesh streamnative/function-mesh-operator --namespace <k8s-namespace>
    ```

4. Verify that the FunctionMesh operator is installed successfully.

    ```shell
    kubectl get pods -l app.kubernetes.io/component=controller-manager
    ```

    Expected outputs:

    ```
    NAME                                READY   STATUS      RESTARTS   AGE
    function-mesh-controller-manager-696f6467c9-mbstr               1/1     Running     0          77s
    ```

## Uninstall FunctionMesh operator

Use the following command to uninstall FunctionMesh operator.

```bash
helm uninstall function-mesh
```