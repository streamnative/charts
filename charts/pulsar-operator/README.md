# StreamNative Pulsar Operators

The Pulsar Operators bring the specific controllers for Kubernetes by providing specific Custom Resource Definition (CRD) which is developed and maintained by StreamNative Inc.
Installing the Pulsar Operators means you agree to and are in compliance with the [StreamNative Community License](https://streamnative.io/community-licence).

## Requirements

To use the `pulsar-operator` chart to deploy BookKeeper Controller, ZooKeeper Controller, and Pulsar Controller, the followings are required.

- Install [`kubectl`](https://kubernetes.io/docs/tasks/tools/#kubectl) 1.16 or higher, compatible with your cluster (+/- 1 minor release from your cluster).
- Install [`helm`](https://helm.sh/docs/intro/install/) v3 (3.0.2 or higher).
- Prepare a Kubernetes cluster, version 1.16 to 1.25. 

## Install `pulsar-operator` chart

1. Create a Kubernetes namespace.

    ```
    kubectl create namespace pulsar
    ```

2. Add the `streamnative` repo.
  
    ```
    helm repo add streamnative https://charts.streamnative.io
    helm repo update
    ```

3. Install the `pulsar-operator` chart.

    ```
    helm install pulsar-operators streamnative/pulsar-operator --namespace pulsar
    ```

4. Verify that the `pulsar-operator` chart is installed successfully.

    ```
    kubectl get po -n pulsar
    ```

    Expected outputs:

    ```
    NAME                                                             READY   STATUS              RESTARTS   AGE
    pulsar-operator-bookkeeper-controller-manager-7488dd7c7f-bs5jn   1/1     Running             0          15h
    pulsar-operator-pulsar-controller-manager-6f7fcd7799-9tkxt       1/1     Running             0          15h
    pulsar-operator-zookeeper-controller-manager-56db9d5649-76dqm    1/1     Running             0          15h
    ```

5. Provision a Pulsar cluster.

    ```
    kubectl apply -f https://raw.githubusercontent.com/streamnative/charts/master/examples/pulsar-operators/quick-start.yaml
    ```

    Expected outputs:

    ```
    NAME                                                             READY   STATUS              RESTARTS   AGE
    pulsar-operator-bookkeeper-controller-manager-7488dd7c7f-bs5jn   1/1     Running             0          15h
    pulsar-operator-pulsar-controller-manager-6f7fcd7799-9tkxt       1/1     Running             0          15h
    pulsar-operator-zookeeper-controller-manager-56db9d5649-76dqm    1/1     Running             0          15h
    ```

6. Verify that the Pulsar cluster Pods are running. 

    ```
    kubectl get po -n pulsar
    ```

    Expected outputs:

    ```
    NAME                                                             READY   STATUS    RESTARTS   AGE
    bookies-bk-0                                                     1/1     Running   0          2m3s
    bookies-bk-1                                                     1/1     Running   0          2m3s
    bookies-bk-2                                                     1/1     Running   0          2m3s
    bookies-bk-auto-recovery-0                                       1/1     Running   0          62s
    brokers-broker-0                                                 1/1     Running   0          2m4s
    brokers-broker-1                                                 1/1     Running   0          2m4s
    pulsar-operator-bookkeeper-controller-manager-7488dd7c7f-bs5jn   1/1     Running   0          15h
    pulsar-operator-pulsar-controller-manager-6f7fcd7799-9tkxt       1/1     Running   0          15h
    pulsar-operator-zookeeper-controller-manager-56db9d5649-76dqm    1/1     Running   0          15h
    zookeepers-zk-0                                                  1/1     Running   0          3m17s
    zookeepers-zk-1                                                  1/1     Running   0          3m17s
    zookeepers-zk-2                                                  1/1     Running   0          3m17s
    ```

7. Clean up environment

    ```
    kubectl delete -f https://raw.githubusercontent.com/streamnative/charts/master/examples/pulsar-operators/quick-start.yaml
    helm uninstall pulsar-operators -n pulsar
    kubectl delete ns pulsar
    ```

## More Resources

### StreamNative Pulsar Operators examples

* [Install Pulsar Operator with OLM](https://raw.githubusercontent.com/streamnative/charts/master/examples/pulsar-operators/olm-subscription.yaml)
* [Set a pre-defined Kubernetes Storage Class](https://raw.githubusercontent.com/streamnative/charts/master/examples/pulsar-operators/storage.yaml)
* [Provision Pulsar Proxy](https://raw.githubusercontent.com/streamnative/charts/master/examples/pulsar-operators/proxy.yaml)
* [Enable the KoP](https://raw.githubusercontent.com/streamnative/charts/master/examples/pulsar-operators/kop.yaml)

### StreamNative Pulsar Operator Tutorial
* [StreamNative Pulsar Operator Tutorial Part 1](https://yuweisung.medium.com/streamnative-pulsar-operator-tutorial-part-1-7fbbbb07397e)
* [StreamNative Pulsar Operator Tutorial Part 2](https://yuweisung.medium.com/streamnative-pulsar-operator-tutorial-part-2-8dd030ac1b7c)
* [StreamNative Pulsar Operator Tutorial Part 3](https://yuweisung.medium.com/streamnative-pulsar-operator-tutorial-part-3-2bb2cf67d0a0)

## Note
1. As helm won't upgrade CRD when doing `helm upgrade`, please manually apply the pulsar-operator [CRDs](https://github.com/streamnative/charts/tree/master/charts/pulsar-operator/crds) before upgrading pulsar-operator chart version. 

2. When upgrading the CRD from `apiextensions.k8s.io/v1beta1` to `apiextensions.k8s.io/v1` we might get exceptions like: 

    ```
    The CustomResourceDefinition "pulsarbrokers.pulsar.streamnative.io" is invalid: spec.preserveUnknownFields: Invalid value: true: must be false in order to use defaults in the schema
    ```
    This is caused by a [controller-gen bug](https://github.com/kubernetes-sigs/controller-tools/issues/476), which makes `preserveUnknownFields: false` missing from the generated CRD even if adding `preserveUnknownFields=false` option. So we can manually patch the CRD wheing getting such exception like below and reapply again:
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