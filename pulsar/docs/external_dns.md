# Enable External DNS

In this Pulsar helm chart, we use [ExternalDNS](https://github.com/kubernetes-sigs/external-dns)
to synchronize exposed Kubernetes services and ingresses with DNS providers.

When `external_dns.enabled` is set to true, this helm chart will automatically register two DNS entries via `ExternalDNS` for the cluster.

- Data endpoint: `data.$(helm-release-name).$(domain_filter)`.
  It is the DNS name for accessing the exposed pulsar cluster to
  produce and consume messages.
- Control-center endpoint: `admin.$(helm-release-name).$(domain_filter)`.
  It is the DNS name for accessing the whole control plane, including Pulsar manager and Grafana.
  - `admin.$(helm-release-name).$(domain_filter)/grafana`: to access the grafana dashboard.
  - `admin.$(helm-release-name).$(domain_filter)/manager`: to access Pulsar manager.

## Configure External DNS

- [ExternalDNS settings](#externaldns-settings)
  - [Google Cloud DNS settings](#google-cloud-dns-settings)
- [Ingress settings](#ingress-settings)
  - [Ingress controller settings](#ingress-controller-settings)
  - [Control-center ingress settings](#control-center-ingress-settings)

### ExternalDNS settings

> Pleaase remember to change `external_dns.owner_id` to a unique value that doesn't change for the lifetime of your cluster.

ExternalDNS can be turned on/off by setting `external_dns.enabled` to `true`/`false` in the values yaml file.

| Parameter | Description | Default Value |
| --------- | ----------- | ------------- |
| external_dns.enabled | Turn on/off ExternalDNS by setting this value to true/false. If it is true, this helm chart deploys an ExternalDNS. | true |
| external_dns.component | The component name is used for naming the ExternalDNS component. | external-dns |
| external_dns.policy | The DNS record update policy. | upsert-only |
| external_dns.registry | The [registry mechanism](https://github.com/kubernetes-sigs/external-dns/blob/master/docs/proposal/registry.md) to manage DNS records safely. | txt |
| external_dns.owner_id | The unique identifier that external-dns uses for marking the managed DNS record. | streamnative |
| external_dns.domain_filter | The domain filter used for filtering out the managed DNS records matching it. | test.gcp.streamnative.dev |
| external_dns.provider | The DNS provider. | google |

#### Google Cloud DNS settings

> This section is only used for configuring Google Cloud DNS.

| Parameter | Description | Default Value |
| --------- | ----------- | ------------- |
| external_dns.providers.google.project | Specify a GCP project different from the one this helm chart is running inside. | Nil |

### Ingress settings

When enabling ExternalDNS for managing DNS records for the cluster,
you can also configure enabling `Ingress` to expose all the components
in the control center through one domain name. You can do so by setting
`ingress.control_center.enabled` to `true`.

#### Ingress controller settings

| Parameter | Description | Default Value |
| --------- | ----------- | ------------- |
| ingress.controller.enabled | Enable running a Nginx Ingress controller. | true |
| ingress.controller.rbac | Flag to enable/disable RBAC for running the ingress controller. | true |
| ingress.controller.component | The component name is used for naming the ingress controller ingress. | nginx-ingress-controller |
| ingress.controller.replicaCount | The number of replicas to run the ingress controller. | 1 |
| ingress.controller.nodeSelector | The node selector to select nodes to run ingress controller. | Nil |
| ingress.controller.tolerations | The tolerations for the deployment of running ingress controller. | `[]` |
| ingress.control_center.annotations | The annotations attached to the ingress controller. | `{}` |
| ingress.control_center.tls.enabled | Flag to enable TLS in the control_center ingress. | false |
| ingress.controller.gracePeriod | The grace termination period of terminating an ingress controller. | 300 |
| ingress.controller.ports.http | The http port for the ingress controller. | 80 |
| ingress.controller.ports.https | The https port for the ingress controller. | 443 |

#### Control-center ingress settings

| Parameter | Description | Default Value |
| --------- | ----------- | ------------- |
| ingress.control_center.enabled | Flag to create a control_center ingress to expose all the control_center components through one `Ingress`. | true |
| ingress.control_center.component | The component name is used for naming the control_center ingress. | control-center |
| ingress.control_center.annotations | The annotations attached to the control_center ingress. | `{}` |
| ingress.control_center.tls.enabled | Flag to enable TLS in the control_center ingress. | false |

## Cloud Providers

- [Google Cloud DNS](external_dns_google_cloud_dns.md)