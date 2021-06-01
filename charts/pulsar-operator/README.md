# Pulsar Opeartor Helm Chart

## Installation Guide

```
kubectl apply -f ./crds
kubectl create namespace sn-system
helm install --namespace sn-system pulsar-operators ./
kubectl get po -n sn-system

Expected output:

NAME                                                              READY   STATUS    RESTARTS   AGE
pulsar-operators-bookkeeper-controller-manager-854765f948-lzzbw   1/1     Running   0          22s
pulsar-operators-pulsar-controller-manager-74ff6f64b5-rwl7t       1/1     Running   0          22s
pulsar-operators-zookeeper-controller-manager-5fdbc656d8-rr6pj    1/1     Running   0          22s
```

