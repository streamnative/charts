<!-- 

Copyright (c) 2019 - 2024 StreamNative, Inc.. All Rights Reserved.

-->

> **Note**
>
> Starting March 31st, 2024, using StreamNative Helm Charts in a production environment mandates a paid subscription with StreamNative. By installing StreamNative Helm Charts, you acknowledge and comply with the [StreamNative Cloud Subscription Agreement](https://streamnative.io/cloud-terms-and-conditions). For a trial license to explore the StreamNative Platform, including its resources, Pulsar operators, and Pulsar images, please [reach out to StreamNative](https://streamnative.io/contact).
> 

# StreamNative Helm Charts

This repository contains the Helm Charts supported by [StreamNative](https://streamnative.io).

## General descriptions

| Chart | Description | Usage |
| --- | --- | --- |
| [`sn-platform`](https://github.com/streamnative/charts/tree/master/charts/sn-platform) | The Helm Chart used for deploying a self-managed version of StreamNative Cloud under a [Private Cloud Licence](https://streamnative.io/deployment/private-cloud-license). | For more details on how to use it, please refer to its [documentation](https://docs.streamnative.io/platform/platform-quickstart).
| [`sn-platform-slim`](https://github.com/streamnative/charts/tree/master/charts/sn-platform-slim) | StreamNative Platform Slim is based on the StreamNative Platform chart but enhances the security control by removing most third-party componenets. | For more details on how to use it, please refer to its [documentation](https://docs.streamnative.io/platform/platform-quickstart).

## Start with StreamNative Private Cloud

StreamNative Private Cloud is an enterprise product which brings specific controllers for Kubernetes by providing specific Custom Resource Definitions (CRDs) that extend the basic Kubernetes orchestration capabilities to support the setup and management of StreamNative components.
    
### Capabilities

With StreamNative Private Cloud, you can simplify operations and maintenance, including:
- Provisioning and managing multiple Pulsar clusters
- Scaling Pulsar clusters through rolling upgrades
- Managing the Pulsar cluster configurations through declarative APIs
- Simplify the cluster operation with Auto-Scaling
- Cost efficiency with the Lakehouse tiered storage

### Apply for trial

Before installing StreamNative Private Cloud, you need to import a valid license. You can contact StreamNative to apply for a [free trial](https://streamnative.io/deployment/start-free-trial). 

### Quick Start

Follow our [Quick Start](https://docs.streamnative.io/private/private-cloud-quickstart) guide to quickly provision and manage Pulsar clusters with the StreamNative Private Cloud.

## About StreamNative

Founded in 2019 by the original creators of Apache Pulsar, [StreamNative](https://streamnative.io) is one of the leading contributors to the open-source Apache Pulsar project. We have helped engineering teams worldwide make the move to Pulsar with [StreamNative Cloud](https://streamnative.io/product), a fully managed service to help teams accelerate time-to-production.
