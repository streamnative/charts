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

# Official Helm Charts

This repository includes the officially supported Helm Charts.

## General descriptions

| Chart | Description | Usage |
| --- | --- | --- |
| [`charts/pulsar`](https://github.com/streamnative/charts/tree/master/charts/pulsar) | The officially supported Helm Chart used for deploying Apache Pulsar to Kubernetes clusters. | For details about how to use it, see [here](charts/pulsar/README.md). |  
| [`charts/sn-platform`](https://github.com/streamnative/charts/tree/master/charts/sn-platform) | The officially supported Helm Chart used for deploying StreamNative Platform to Kubernetes clusters. | For how to use it, see [here](charts/sn-platform/README.md).
| [`charts/pulsar-operator`](https://github.com/streamnative/charts/tree/master/charts/pulsar-operator)  | The officially supported Helm Chart for installing the Pulsar operator to provide Customer Resource Definitions (CRDs) and Controllers to manage and run Pulsar clusters in a more resilient way. | For details about how to use it, see [here](charts/pulsar-operator/README.md). |
| [`charts/function-mesh-operator`](https://github.com/streamnative/charts/tree/master/charts/function-mesh-operator) | The officially supported Helm Chart for installing FunctionMesh to manage Pulsar Functions and Pulsar IO connectors on Kubernetes. | For details about how to use it, see [here](charts/function-mesh-operator/README.md). | 
| [`charts/local-storage-provisioner`](https://github.com/streamnative/charts/tree/master/charts/local-storage-provisioner) | The officially supported Helm Chart for installing the local storage provisioner use local persistent volumes as the persistent storage. | For details about how to use it, see [here](charts/local-storage-provisioner/README.md). |
| [`charts/image-puller`](https://github.com/streamnative/charts/tree/master/charts/image-puller) | The officially supported Helm Chart for installing an Image Puller which pulls docker images required for deploying Apache Pulsar or StreamNative Platform. | For details about how to use it, see [here](charts/image-puller/README.md). |



## Troubleshooting

We've done our best to make these charts as seamless as possible,
occasionally troubles do surface outside of our control. We've collected
tips and tricks for troubleshooting common issues. Please examine these first before raising an [issue](https://github.com/streamnative/charts/issues/new/choose), and feel free to add to them by raising a [Pull Request](https://github.com/streamnative/charts/compare)!


