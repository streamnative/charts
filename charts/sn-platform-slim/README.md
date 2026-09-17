# What is StreamNative Platform Slim

> **Note**
>
> Installing StreamNative Platform indicates that you agree to and are in compliance with the [StreamNative Cloud Subscription Agreement](https://streamnative.io/cloud-terms-and-conditions). To learn more or request access to a trial license, please [contact StreamNative](https://streamnative.io/contact).

StreamNative Platform Slim is based on the [StreamNative Platform](https://github.com/streamnative/charts/blob/master/charts/sn-platform/README.md) chart but enhances the security control by removing most third-party componenets:
- Presto
- Vault
- cp-kafka image
- metrics server

Security sensitive users can consider the StreamNative Platform Slim chart, ande most usage documentations are same with  [StreamNative Platform documentation](https://docs.streamnative.io/docs/platform-overview).

## ServiceAccount token mounting

Chart-created ServiceAccounts inherit Kubernetes token mounting behavior by default. Set `global.serviceAccount.automountServiceAccountToken: false` to disable automatic token mounting for all of them. A component's `serviceAccount.automountServiceAccountToken` value overrides the global setting; for example, `prometheus.serviceAccount.automountServiceAccountToken: true` keeps mounting enabled for Prometheus. The `zookeeper.customTools.serviceAccount` setting covers both backup and restore.

Before disabling token mounting, provide a projected ServiceAccount token and cluster CA to workloads that call the Kubernetes API, including Prometheus, external DNS, and function worker. Setting the ServiceAccount field alone does not create a replacement token volume in Pods.
