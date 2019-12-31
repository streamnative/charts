# Google Cloud DNS

In order to enable using [Google Cloud DNS](https://cloud.google.com/dns/docs/), you need to configure your GKE cluster to enable Cloud DNS API first and then create a Cloud DNS zone for the managed DNS records.

- [Enable Cloud DNS on your GKE cluster](#enable-cloud-dns-on-your-gke-cluster)
- [Create a Cloud DNS zone](#create-a-cloud-dns-zone)

## Enable Cloud DNS on your GKE cluster

There are two ways to enable Cloud DNS on your GKE clusters.

- [Create a new cluster with Cloud DNS enabled](#create-a-new-cluster-with-cloud-dns-enabled)
- [Enable Cloud DNS on an existing GKE cluster](#enable-cloud-dns-on-an-existing-gke-cluster)

### Create a new cluster with Cloud DNS enabled

If you don't have any GKE cluster, you can create a brand new GKE cluster with Cloud DNS enabled by adding 
`https://www.googleapis.com/auth/ndev.clouddns.readwrite`
in the scopes.

Example command to create a cluster with Cloud DNS enabled is shown as below.

```
$ gcloud container clusters create $(new cluster name) \
    --num-nodes $(num nodes in the pool) \
    --scopes "default,https://www.googleapis.com/auth/ndev.clouddns.readwrite"
```

### Enable Cloud DNS on an existing GKE cluster

If you already have a running GKE cluster, you can create a new node-pool with Cloud DNS enabled and drain the old node-pool. In this example, we create a new node-pool `pulsar-staging` with Cloud DNS enabled and drain and delete thhe old node-pool `default-pool`.

1. Create a new pool to enable Cloud DNS API.

```
gcloud container node-pools create $(new pool name) \n
    --cluster $(gke cluster name) \n
    --machine-type $(machine typee) \n
    --num-nodes $(num nodes in the pool) \n
    --scopes default,https://www.googleapis.com/auth/ndev.clouddns.readwrite
```

Example command to create a pool `pulsar` in cluster `pulsar-staging`.

```
gcloud container node-pools create pulsar \n
    --cluster pulsar-staging \n
    --machine-type n1-standard-32 \n
    --num-nodes 3 \n
    --scopes default,https://www.googleapis.com/auth/ndev.clouddns.readwrite
```

2. Drain the existing pool.

You need to drain the nodes one-by-one in the existing pool.

```
kubectl drain [node]
```

Example command:

```
kubectl drain gke-pulsar-staging-default-pool-ca5a0aa4-0lkn
```

3. Delete the existing pool.

```
gcloud container node-pools delete [POOL_NAME] \
  --cluster [CLUSTER_NAME]
```

Example command:

```
gcloud container node-pools delete default-pool --cluster pulsar-staging
```

## Create a Cloud DNS zone

The second step to enable ExternalDNS is to create a DNS zone in Cloud DNS to manage the DNS records. This example assumes you already have a Cloud DNS zone `gcp-streamnative-dev` for domain `gcp.streamnative.dev.`, and you are provisioning a `test-gcp-streamnative-dev` DNS zone for domain `test.gcp.streamnative.dev.`.

1. Create a DNS zone `test-gcp-streamnative-dev` for managing DNS name `test.gcp.streamnative.dev.`.

```
gcloud dns managed-zones create "test-gcp-streamnative-dev" --dns-name "test.gcp.streamnative.dev." --description "Automatically managed zone by kubernetes.io/external-dns"
```

Make a note of the nameservers that were assigned to your new zone.

```
gcloud dns record-sets list --zone "test-gcp-streamnative-dev" --name "test.gcp.streamnative.dev." --type NS
```
Output:
```
NAME                        TYPE  TTL    DATA
test.gcp.streamnative.dev.  NS    21600  ns-cloud-a1.googledomains.com.,ns-cloud-a2.googledomains.com.,ns-cloud-a3.googledomains.com.,ns-cloud-a4.googledomains.com.
```

In this case it's ns-cloud-{a1-a4}.googledomains.com. but your's could slightly differ, e.g. {e1-e4}, {b1-b4} etc.

2. Update your domain's name servers 

### Parent zone managed by Cloud DNS

If you have a parent zone already managed by Cloud DNS, you need to tell the parent zone where to find the DNS records for this zone by adding the corresponding NS records there.

Assuming the parent zone is "gcp-streamnative-dev" and the domain is "gcp.streamnative.dev" and that it's also
hosted at Google we would do the following.

```
gcloud dns record-sets transaction start --zone "gcp-streamnative-dev"
gcloud dns record-sets transaction add ns-cloud-a{1..4}.googledomains.com. --name "test.gcp.streamnative.dev." --ttl 300 --type NS --zone "gcp-streamnative-dev"
gcloud dns record-sets transaction execute --zone "gcp-streamnative-dev"
```

### No parent zone or parent zone is not managed by Cloud DNS

If you don't have a parent zone already managed by Cloud DnS, you need to add the name servers assigned to the created DNS zone to your domain registrar. Follow [the instruction](https://cloud.google.com/dns/docs/update-name-servers) to do so.

## Configure the helm chart to enable external DNS

After you have a GKE cluster with Cloud DNS enabled and have created a DNS zone in Google Cloud DNS, you can configure helm chart to [enable ExternalDNS](external_dns.md#configure-external-dns) and deploy the helm chart.

```
helm upgrade $(helm-chart-name) /path/to/chart/
```
