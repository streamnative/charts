# pulsar-resources-operator

Pulsar Resources Operator Helm chart for Pulsar Resources Management on Kubernetes

![Version: v0.0.1](https://img.shields.io/badge/Version-v0.0.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: v0.0.1](https://img.shields.io/badge/AppVersion-v0.0.1-informational?style=flat-square)

## Installing the Chart

To install the chart with the release name `my-release`:

```console
$ helm repo add streamnative https://charts.streamnative.io
$ helm -n <namespace> install my-release streamnative/pulsar-resources-operator
```

## Requirements

Kubernetes: `>= 1.16.0-0 < 1.24.0-0`

Pulsar: `>= 2.9.0.x`

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` | Add affinity for pod |
| fullnameOverride | string | `""` | It will override the name of deployment |
| image.pullPolicy | string | `"IfNotPresent"` | Image pull policy for the container. |
| image.registry | string | `"docker.cloudsmith.io"` | Specififies the registry of images, especially when user want to use a different image hub |
| image.repository | string | `"streamnative/operators/pulsar-resources-operator"` | The full repo name for image. |
| image.tag | string | `""` | Image tag, it can override the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | Specifies image pull secrets for private registry, the format is `- name: gcr` |
| nameOverride | string | `""` | It will override the value of label `app.kubernetes.io/name` on pod |
| namespace | string | `""` | Specifies namespace for the release, it will override the `-n` parameter when it's not empty |
| nodeSelector | object | `{}` | Add NodeSelector for pod schedule |
| podAnnotations | object | `{}` | Add annotations for the deployment pod |
| podSecurityContext | object | `{}` | Add security context for pod |
| replicaCount | int | `1` | The replicas of pod |
| resources | object | `{}` | Add resource limits and requests |
| securityContext | object | `{}` | Add security context for container |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.name | string | `""` |  |
| terminationGracePeriodSeconds | int | `10` | The period seconds that pod will be termiated gracefully |
| tolerations | list | `[]` | Add tolerations |