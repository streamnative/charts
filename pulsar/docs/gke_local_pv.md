# Deploy Pulsar to GKE using local PV

## Create a GKE cluster with local SSDs

> NOTE: in order to use local PV, you need to create a GKE cluster with Kubernetes 1.14+.

```
gcloud container clusters create $(pulsar-cluster-name) \
    --num-nodes $(node-count) \
    --local-ssd-count $(ssd-count) \
    --machine-type $(machine-type) \
    --node-version $(node-version)
```

Example: 

```
gcloud container clusters create pulsar-dev \
    --num-nodes 4 \
    --local-ssd-count 5 \
    --machine-type n1-standard-32 \
    --node-version 1.14.8-gke.12
```

## Clone StreamNative charts repo

```
git clone https://github.com/streamnative/charts.git
```

Go the cloned repository.

```
cd charts
```

## Install the local storage provisioner

```
helm install pulsar-storage-provisioner pulsar/charts/local-storage-provisioner
```

After installed the local storage provisioner, you can run `kubectl get pods` to check if the provisioner is up running.
You should see similar output as following:

```
NAME                                                         READY   STATUS    RESTARTS   AGE
pulsar-storage-provisioner-local-storage-provisioner-cvnz8   1/1     Running   0          3h
pulsar-storage-provisioner-local-storage-provisioner-jpxpl   1/1     Running   0          3h
pulsar-storage-provisioner-local-storage-provisioner-ktrlj   1/1     Running   0          3h
pulsar-storage-provisioner-local-storage-provisioner-ltwkm   1/1     Running   0          3h
```

## Install the pulsar cluster

Create a kubernete namespace `pulsar`.

```
kubectl create ns pulsar
```

Install the pulsar cluster to namespace `pulsar`.

```
helm install --values pulsar/examples/values-local-pv.yaml \
    pulsar-dev-cluster pulsar/charts/pulsar/
```
