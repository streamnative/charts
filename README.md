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

# StreamNative Helm Charts

This repository contains the Helm Charts supported by [StreamNative](https://streamnative.io).

## General descriptions

| Chart | Description | Usage |
| --- | --- | --- |
| [`pulsar-operator`](https://github.com/streamnative/charts/tree/master/charts/pulsar-operator)  | The Helm Chart used for installing the StreamNative operator for Apache Pulsar that eases the installation and management of Pulsar clusters in a k8s environment.  | For more details on how to use it, please refer to its [documentation](https://docs.streamnative.io/operator).
| [`sn-platform`](https://github.com/streamnative/charts/tree/master/charts/sn-platform) | The Helm Chart used for deploying a self-managed version of StreamNative Cloud under a [Private Cloud Licence](https://streamnative.io/deployment/private-cloud-license). | For more details on how to use it, please refer to its [documentation](https://docs.streamnative.io/platform/platform-quickstart).
| [`local-storage-provisioner`](https://github.com/streamnative/charts/tree/master/charts/local-storage-provisioner) | The Helm Chart used for installing the local storage provisioner, allowing the use of local persistent volumes as durable storage. | For more details on how to use it, please see [here](charts/local-storage-provisioner/README.md). |
| [`image-puller`](https://github.com/streamnative/charts/tree/master/charts/image-puller) | The Helm Chart used for installing an Image Puller which retrieves the necessary Docker images for deploying Apache Pulsar or the StreamNative Platform. | For more details on how to use it, please see [here](charts/image-puller/README.md). |


## Troubleshooting

We've done our best to make these charts as seamless as possible,
occasionally troubles do surface outside of our control. We've collected
tips and tricks for troubleshooting common issues. Please examine these first before raising an [issue](https://github.com/streamnative/charts/issues/new/choose), and feel free to add to them by raising a [Pull Request](https://github.com/streamnative/charts/compare)!


## Release Process

- Open https://github.com/streamnative/charts/actions/workflows/release.yml
- Click the `Run workflow` button which is in the right side
- Choose the name of chart you want to release, input its base branch version and release version
- Click `Run workflow`

## About StreamNative

Founded in 2019 by the original creators of Apache Pulsar, [StreamNative](https://streamnative.io) is one of the leading contributors to the open-source Apache Pulsar project. We have helped engineering teams worldwide make the move to Pulsar with [StreamNative Cloud](https://streamnative.io/product), a fully managed service to help teams accelerate time-to-production.
