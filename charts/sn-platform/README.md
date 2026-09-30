# What is StreamNative Platform

> **Note**
>
> Installing StreamNative Platform indicates that you agree to and are in compliance with the [StreamNative Cloud Subscription Agreement](https://streamnative.io/cloud-terms-and-conditions). To learn more or request access to a trial license, please [contact StreamNative](https://streamnative.io/contact).

StreamNative Platform is a cloud-native messaging and event-streaming platform that enables you to build a real-time application and data infrastructure for both real-time and historical events. Founded by the original developers of [Apache Pulsar](https://pulsar.apache.org/) and [Apache BookKeeper](https://bookkeeper.apache.org/), [StreamNative](https://streamnative.io/) offers a complete, self-managed platform for continuously streaming data across your organization to power rich customer experiences and data-driven operations. You can deploy StreamNative Platform on-premise or in-cloud.

Powered by Apache Pulsar, StreamNative Platform makes it easy to build mission-critical messaging and streaming applications and real-time data pipelines by integrating data from multiple sources into a single, central messaging and event streaming platform for your company. StreamNative Platform lets you focus on how to maximize business value from real-time data rather than worrying about the underlying mechanisms such as how data is messaged between various systems and how data is stored reliably for processing.

Specifically, StreamNative Platform simplifies:

- Publishing-and-consuming messages using popular messaging protocols (including Apache Pulsar and Apache Kafka)
- Connecting various data sources to Pulsar
- Building real-time applications with Pulsar
- Integrating your data processing infrastructure with Pulsar
- Securing, monitoring, and managing your Pulsar deployments

Most importantly, StreamNative Platform enables you to:

- Deploy and manage Pulsar in your private cloud environment.
- Deploy and manage your platform as a cloud-native system on Kubernetes.
- Monitor the health and performance of Pulsar clusters using dedicated tools such as Pulsar detector and StreamNative Console.

For details, see [StreamNative Platform documentation](https://docs.streamnative.io/docs/platform-overview). 

## ServiceAccount token mounting

Chart-created ServiceAccounts inherit Kubernetes token mounting behavior by default. Set `global.serviceAccount.automountServiceAccountToken: false` to disable automatic token mounting for all of them. A component's `serviceAccount.automountServiceAccountToken` value overrides the global setting; for example, `vault.serviceAccount.automountServiceAccountToken: true` keeps mounting enabled for Vault. The custom metric server's setting also covers its init and Prometheus ServiceAccounts, and `zookeeper.customTools.serviceAccount` covers backup and restore.

Before disabling token mounting, provide a projected ServiceAccount token and cluster CA to workloads that call the Kubernetes API, including Vault, Prometheus, external DNS, and function worker. Setting the ServiceAccount field alone does not create a replacement token volume in Pods.

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

The chart renders `proxy.securityContext` as `PulsarProxy.spec.pod.securityContext`. With [sn-operator #1479](https://github.com/streamnative/sn-operator/pull/1479), the generated `check-broker` init container receives the same container security context as the proxy, including `readOnlyRootFilesystem: true` and the rootless defaults derived from `runAsNonRoot: true`. The chart enables read-only root filesystems for proxy by default; set `proxy.securityContext.readOnlyRootFilesystem: false` if the proxy image needs write access to its root filesystem.

The sn-operator controller's own ServiceAccount and Deployment are configured through the separate sn-operator chart. To disable automatic token mounting there, set its `serviceAccount.automountServiceAccountToken: false` and configure its `volumes` and `volumeMounts` to project the API token, cluster CA, and namespace at `/var/run/secrets/kubernetes.io/serviceaccount`. This platform chart only controls the ServiceAccounts it creates for platform components.

The broker example above works only after the PulsarBroker CRD includes `projected`. With an older CRD, keep `broker.serviceAccount.automountServiceAccountToken: true`, omit the broker's projected `extraVolumes` and `extraVolumeMounts`, and use a narrow Kyverno exception for that ServiceAccount. The chart's `functions` workload is a directly rendered StatefulSet, so its volume hook does not pass through the PulsarBroker CRD. If a different component's projected volume fails, inspect its rendered Pod and events before disabling its token mount.

### Other chart-owned policy findings

Detector exposes optional `livenessProbe` and `readinessProbe` values. For example, a TCP probe can check its named `server` port; verify that the port is open once Detector is ready:

```yaml
pulsar_detector:
  livenessProbe:
    tcpSocket:
      port: server
    initialDelaySeconds: 30
    periodSeconds: 30
  readinessProbe:
    tcpSocket:
      port: server
    periodSeconds: 10
```

If Detector reads its admin token from a Secret volume, set `secret.defaultMode: 288` (0440) on that `extraVolumes` entry and give its Pod a matching `securityContext.fsGroup`. The `secretVolumeDefaultMode` setting applies to operator-generated volumes, so it does not change Detector's chart-defined volumes. A policy that forbids Secret volumes entirely still needs a different credential source or an exception.

Toolset's StatefulSet init containers and the JWT Secret initialization Job already use `toolset.resources`. Set both CPU and memory limits there to satisfy policies requiring limits, and set `toolset.initJobTTLSecondsAfterFinished` for the Job's TTL. Console's StatefulSet containers, wait init container, and initialization Job now use `streamnative_console.resources`; set its CPU and memory limits to cover them. The JWT initialization ServiceAccount may retain automatic token mounting when its Kubernetes API access is required.
