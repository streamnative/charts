# Enable External DNS

In this Pulsar helm chart, we use [ExternalDNS](https://github.com/kubernetes-sigs/external-dns)
to synchronize exposed Kubernetes services and ingresses with DNS providers.

When `external_dns.enabled` is set to true, this helm chart will automatically register two DNS entries via `ExternalDNS` for the cluster.

- Data plane endpoint: `data.$(helm-release-name).$(domain_filter)`.
  It is the DNS name for accessing the exposed pulsar cluster to
  produce and consume messages.
- Control plane endpoint: `admin.$(helm-release-name).$(domain_filter)`.
  It is the DNS name for accessing the whole control plane, including Pulsar manager and Grafana.
  - `admin.$(helm-release-name).$(domain_filter)/grafana`: to access the grafana dashboard.
  - `admin.$(helm-release-name).$(domain_filter)/manager`: to access Pulsar manager.

## Configure External DNS

- [ExternalDNS settings](#externaldns-settings)
  - [Google Cloud DNS settings](#google-cloud-dns-settings)
- [Ingress settings](#ingress-settings)

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
in the control plane through one domain name. You can do so by setting
`ingress.control_plane.enabled` to `true`.

| Parameter | Description | Default Value |
| --------- | ----------- | ------------- |
| ingress.control_plane.enabled | Flag to create a control_plane ingress to expose all the control_plane components through one `Ingress`. | true |
| ingress.control_plane.component | The component name is used for naming the control_plane ingress. | control-plane |
| ingress.control_plane.replicaCount | The number of replicas to run the ingress controller. | 1 |
| ingress.control_plane.nodeSelector | The node selector to select nodes to run ingress controller. | Nil |
| ingress.control_plane.tolarations | The tolarations for the deployment of running ingress controller. | `[]` |
| ingress.control_plane.gracePeriod | The grace termination period of terminating an ingress controller. | 300 |
| ingress.control_plane.annotations | The annotations attached to the ingress controller deployment. | `{}` |
| ingress.control_plane.tls.enabled | Flag to enable TLS in the control_plane ingress. | false |

## Cloud Providers

- [Google Cloud DNS](external_dns_google_cloud_dns.md)