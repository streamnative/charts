
For a fully functional Pulsar cluster, you will need a few resources before deploying the `streamnative/pulsar` chart. The following is how these charts are deployed and tested within StreamNative.

## Create a GKE cluster

To get started easier, a script is provided to automate the cluster creation. Alternatively, a cluster can be created manually as well.

### Scripted cluster creation

A [bootstrap script](https://github.com/streamnative/charts/tree/master/scripts/pulsar/gke_bootstrap_script.sh) has been created to automate much of the setup process for users on GCP/GKE.

The script will:

1. Create a new GKE cluster.
2. Allow the cluster to modify DNS records.
3. Setup `kubectl`, and connect it to the cluster.

Google Cloud SDK is a dependency of this script, so make sure it's set up correctly in order for the script to work.

The script reads various parameters from environment variables and an argument `up` or `down` for bootstrap and clean-up respectively.

The table below describes all variables.

| **Variable** | **Description** | **Default value** |
| ------------ | --------------- | ----------------- |
| PROJECT      | The ID of your GCP project | No defaults, required to be set. |
| CLUSTER_NAME | Name of the GKE cluster | `pulsar-dev` |
| CONFDIR | Configuration directory to store kubernetes config | Defaults to ${HOME}/.config/streamnative |
| INT_NETWORK | The IP space to use within this cluster | `default` |
| LOCAL_SSD_COUNT | The number of local SSD counts | Defaults to 4 |
| MACHINE_TYPE | The type of machine to use for nodes | `n1-standard-4` |
| NUM_NODES | The number of nodes to be created in each of the cluster's zones | 4 |
| PREEMPTIBLE | Create nodes using preemptible VM instances in the new cluster. | false |
| REGION | Compute region for the cluster | `us-east1` |
| USE_LOCAL_SSD | Flag to create a cluster with local SSDs | Defaults to false |
| ZONE | Compute zone for the cluster | `us-east1-b` |
| ZONE_EXTENSION | The extension (`a`, `b`, `c`) of the zone name of the cluster | `b` |
| EXTRA_CREATE_ARGS | Extra arguments passed to create command | |

Run the script, by passing in your desired parameters. It can work with the default parameters except for `PROJECT` which is required:

```bash
PROJECT=<gcloud project id> scripts/pulsar/gke_bootstrap_script.sh up
```

The script can also be used to clean up the created GKE resources:

```bash
PROJECT=<gcloud project id> scripts/pulsar/gke_bootstrap_script.sh down
```

## Manual cluster creation

### Create a Kubernetes cluster

To provision a Kubernetes cluster manually, follow the [GKE instructions](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-cluster).

## Next Steps

Continue with the installation of the chart once you have the cluster up and running.
