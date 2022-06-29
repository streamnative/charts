# Pulsar Operator Helm Chart

The `charts/pulsar-operator` is the the officially supported Helm Chart for installing Pulsar operators. The `charts/pulsar-operator` provides Customer Resource Definitions (CRDs) and Controllers to manage and run Pulsar clusters in a more resilient way.

## Requirements

To use the `pulsar-operator` chart to deploy BookKeeper Controller, ZooKeeper Controller, and Pulsar Manager Controller, the followings are required.

- Install [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl) 1.16 or higher, compatible with your cluster (+/- 1 minor release from your cluster).
- Install [`helm`](https://helm.sh/docs/intro/install/) v3 (3.0.2 or higher).
- Prepare a Kubernetes cluster, version 1.16 or higher.

## Install `pulsar-operator` chart

1. Create a Kubernetes namespace.

    ```
    kubectl create namespace <k8s-namespace>
    ```

2. Install the `pulsar-operator` chart.

    ```
    helm install pulsar-operators --namespace <k8s-namespace>  streamnative/pulsar-operator
    ```

3. Verify that the `pulsar-operator` chart is installed successfully.

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

## Note
As helm won't upgrade CRD when doing helm upgrade https://helm.sh/docs/chart_best_practices/custom_resource_definitions/#some-caveats-and-explanations ,we'll need to manually upgrade CRD version before upgrading pulsar-operator chart version. 
<br>when upgrading the CRD from `apiextensions.k8s.io/v1beta1` to `apiextensions.k8s.io/v1` we might get exception like:
```
The CustomResourceDefinition "pulsarbrokers.pulsar.streamnative.io" is invalid: spec.preserveUnknownFields: Invalid value: true: must be false in order to use defaults in the schema
```
<br>This caused by a controller-gen bug: https://github.com/kubernetes-sigs/controller-tools/issues/476, which makes `preserveUnknownFields: false` missing from the generated CRD even if adding `preserveUnknownFields=false` option. So we can manually patch the CRD wheing getting such exception like below:
```
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  annotations:
    controller-gen.kubebuilder.io/version: v0.6.0
  creationTimestamp: null
  name: pulsarbrokers.pulsar.streamnative.io
spec:
  group: pulsar.streamnative.io
  preserveUnknownFields: false
```

## Versioning Convention

`version`: The version of the chart. It will be changed only when there are some changes to the chart or the `appVersion` bumps a new version.

`appVersion`: The version of the application image that the chart contains. It will be changed only when the operator image bumps a new version.

`kubeVersion`: The range of compatible Kubernetes versions. 
