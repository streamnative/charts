## Deploy sn-platform chart

Create `pulsar` namespace:

```bash
$ kubectl create namespace pulsar
```

Run `prepare_helm_release.sh` to create secrets required for installing StreamNative Platform.

```bash
$ ./scripts/pulsar/prepare_helm_release.sh -n pulsar -k sn-platform-pulsar -c --control-center-admin admin --control-center-password admin
```

Use the Pulsar Helm charts to install StreamNative Platform.

```bash
$ helm install sn-platform-pulsar --values pulsar/values.yaml ./pulsar
```


## Add loki chart

Add [Loki's chart repository](https://github.com/grafana/loki/tree/master/production/helm/loki) to Helm:

```bash
$ helm repo add loki https://grafana.github.io/loki/charts
```

You can update the chart repository by running:

```bash
$ helm repo update
```

## Deploy Loki to your cluster

Deploy Loki Stack (Loki, Promtail, Grafana, Prometheus)

```bash
$ helm upgrade --install sn-platform-pulsar-loki --namespace pulsar loki/loki-stack
```

## Get grafana service in your cluster

```bash
$ kubectl get service -n pulsar | grep "sn-platform-pulsar-grafana"
```

Output:

```text
NAME                                        TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)                         AGE
sn-platform-pulsar-grafana                  LoadBalancer   1.2.3.4       10.11.12.13      3000:32118/TCP                  86s
```

And you can use `10.11.12.13:3000` access grafana Website, the `user` and `password` as follows:

```text
user: admin
password: admin
```
