# Pulsar Operator Helm Chart

The `charts/pulsar-operator` is the the officially supported Helm Chart for installing Pulsar operators. The `charts/pulsar-operator` provides Customer Resource Definitions (CRDs) and Controllers to manage and run Pulsar clusters in a more resilient way.

## Requirements

To use the `pulsar-operator` chart to deploy BookKeeper Controller, ZooKeeper Controller, and Pulsar Manager Controller, the followings are required.

- Install [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl) 1.16 or higher, compatible with your cluster (+/- 1 minor release from your cluster).
- Install [`helm`](https://helm.sh/docs/intro/install/) v3 (3.0.2 or higher).
- Prepare a Kubernetes cluster, version 1.16 or higher.

## Install `pulsar-operator` chart

1. Register the CRDs with the Kubernetes cluster.

    ```
    kubectl apply -f ./crds
    ```

2. Create a Kubernetes namespace.

    ```
    kubectl create namespace <k8s-namespace>
    ```

3. Install the `pulsar-operator` chart.

    ```
    helm install pulsar-operators --namespace <k8s-namespace>  streamnative/pulsar-operators
    ```

4. Verify that the `pulsar-operator` chart is installed successfully.

    ```
    kubectl get po -n <k8s-namespace>
    ```

    Expected outputs:

    ```
    NAME                                                              READY   STATUS    RESTARTS   AGE
    pulsar-operators-bookkeeper-controller-manager-854765f948-lzzbw   1/1     Running   0          22s
    pulsar-operators-pulsar-controller-manager-74ff6f64b5-rwl7t       1/1     Running   0          22s
    pulsar-operators-zookeeper-controller-manager-5fdbc656d8-rr6pj    1/1     Running   0          22s
    ```

## Uninstall `pulsar-operator` chart

To uninstall the `pulsar-operator` chart, execute this command.

```
helm uninstall pulsar-operator -n <k8s-namespace>
```
