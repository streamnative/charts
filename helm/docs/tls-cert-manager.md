# Enable TLS

To enable TLS, you must provision a TLS certificate and store it as a `kubernetes.io/tls` secret for each component (e.g. broker, proxy and etc) in Kubernetes prior to installing the helm chart.

There are two ways to provision TLS certificates as described in section [Provision TLS certificates](#provision-tls-certificates). In either approach, the TLS certificate is required to be stored in the following format.

- tls.crt: points to the PEM encoded public key certificate.
- tls.key: points to private key associated with given certificate.
- ca.crt: points to the PEM encoded CA certificate.

In order to enable TLS for each component, you need to first set `tls.enabled` to `true`.

## Enable TLS on broker

### Automated certificate provisioning

If you using cert-manager to generate TLS certificate, you can simply setting `tls.broker.enabled` to be `true`. A tls secret named `$(helm-release-name)-tls-broker` will be generated automatically by cert-manager and used by the broker.

### Self-signed certificate

[TBD]

## Enable TLS on proxy

### Automated certificate provisioning

> The helm chart is actually using the broker certificate for configuring
> proxy right now due to https://github.com/apache/pulsar/pull/5971.
> Once the issue is fixed, the helm chart will be updated to use proxy
> certificate.

If you using cert-manager to generate TLS certificate, you can simply setting `tls.proxy.enabled` to be `true`. A tls secret named `$(helm-release-name)-tls-proxy` will be generated automatically by cert-manager and used by the proxy.

### Self-signed certificate

[TBD]

## Provision TLS certificates

There are two ways to provision TLS certificates.

- [Self-signed Certificates](#self-signed-certificates)
- [Automatically provision and manage certificates](#automatically-provision-and-manage-certificates)

## Self-signed certificates

[TBD]

## Automatically provision and manage certificates

In order to use [cert-manager](https://github.com/jetstack/cert-manager) to automate provisioning and managing TLS certifactes, you need to install cert-manager first.

You can follow the [official instructions](https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm) to install cert manager.

> Alternatively, you can use [scripts/install-cert-manager.sh](../scripts/install-cert-manager.sh) to install a cert-manager helm release to namespace `cert-manager`. 

### Enable certificate issuer

After cert-manager is installed, you can configure the helm chart to enable certificate issuer by setting `certs.manager.enabled` to `true`.

### Configure certificate issuer

You can configure the certificate issuer by setting `certs.issuers.type` to the issuer you choose. Currently the helm chart only supports `selfsigning` issuer. You can edit `tls-cert-issuer.yaml` to add the cert issuer you would like to use.