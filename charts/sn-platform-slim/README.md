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

## Operator-generated workload security

The settings below require sn-operator and CRDs containing [projected volume support](https://github.com/streamnative/sn-operator/pull/1472), [Secret volume modes](https://github.com/streamnative/sn-operator/pull/1476), and [init container security context propagation](https://github.com/streamnative/sn-operator/pull/1475) (all present in `v0.22.0-rc.19`). Upgrade the operator and its CRDs before applying a chart release that uses these settings. An older PulsarBroker CRD rejects `spec.pod.volumes[].projected` during server-side apply.

For a broker that needs Kubernetes API access, such as one running Function Worker, disable automatic ServiceAccount token mounting only when the projected replacement is configured:

```yaml
broker:
  serviceAccount:
    automountServiceAccountToken: false
  extraVolumes:
    - name: kube-api-access
      projected:
        defaultMode: 420 # 0644; the Kubernetes client must read the token and CA
        sources:
          - serviceAccountToken:
              expirationSeconds: 3607
              path: token
          - configMap:
              name: kube-root-ca.crt
              items:
                - key: ca.crt
                  path: ca.crt
          - downwardAPI:
              items:
                - path: namespace
                  fieldRef:
                    apiVersion: v1
                    fieldPath: metadata.namespace
  extraVolumeMounts:
    - name: kube-api-access
      mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      readOnly: true
  securityContext:
    runAsNonRoot: true
    runAsUser: 10000
    runAsGroup: 10000
    fsGroup: 10000
    readOnlyRootFilesystem: true
  secretVolumeDefaultMode: 288 # 0440
```

Set `secretVolumeDefaultMode: 288` on `broker`, `proxy`, `bookkeeper`, `zookeeper`, or `autorecovery` as needed. It controls operator-generated Secret volumes, including auth token and TLS certificate mounts. Keep `fsGroup` set to a group the non-root container belongs to, or the files may be unreadable. The setting is optional, so existing installations keep Kubernetes' default mode. For a Secret volume supplied through `extraVolumes`, set `secret.defaultMode` on that volume directly.

Set each component's `securityContext.readOnlyRootFilesystem: true` and `resources.limits` where required by policy. With the updated operator, its `init-copy-config` init container inherits the workload's security context and resources, including for bookie, ZooKeeper, and autorecovery. The operator also derives `allowPrivilegeEscalation: false` and `capabilities.drop: [ALL]` when `runAsNonRoot: true` is set. Inspect the resulting StatefulSets and Pods to verify your policy's exact requirements. Customer-supplied init containers and Secret-backed environment variables need their own configuration or a policy decision; `secretVolumeDefaultMode` does not change them.

The sn-operator controller's own ServiceAccount and Deployment are configured through the separate sn-operator chart. To disable automatic token mounting there, set its `serviceAccount.automountServiceAccountToken: false` and configure its `volumes` and `volumeMounts` to project the API token, cluster CA, and namespace at `/var/run/secrets/kubernetes.io/serviceaccount`. This platform chart only controls the ServiceAccounts it creates for platform components.
