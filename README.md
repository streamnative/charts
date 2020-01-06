<!--

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.

-->

# Pulsar Helm Chart

This directory contains the Helm Chart required to do a complete Pulsar deployment on Kubernetes.

## Install Helm

Before you start, you need to install helm.
Following [helm documentation](https://docs.helm.sh/using_helm/#installing-helm) to install it.

## Install Pulsar Chart

Assume you already cloned pulsar repo in `PULSAR_HOME` directory.

1. Go to Pulsar helm chart directory
    ```shell
    cd ${PULSAR_HOME}/pulsar/charts
    ```
1. Install helm chart.
    ```shell
    helm install --values pulsar/values.yaml ./pulsar
    ```

Once the helm chart is completed on installation, you can access the cluster via:

- Web service url: `http://$(minikube ip):30001/`
- Pulsar service url: `pulsar://$(minikube ip):30002/`

### How to enable TLS and DNS

- [Enable TLS](docs/tls-cert-manager.md)
- [Enable External DNS](docs/external_dns.md)

