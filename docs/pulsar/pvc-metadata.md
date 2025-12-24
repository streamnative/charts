# PVC Metadata Configuration

You can add custom annotations and labels to PersistentVolumeClaim (PVC) resources. Currently, only BookKeeper PVCs support this feature.

## BookKeeper PVC Metadata

BookKeeper uses two types of PVCs: `journal` and `ledgers`. You can configure metadata for each separately.

Example:

```yaml
bookkeeper:
  volumes:
    journal:
      metadata:
        annotations:
          example.com/annotation-key: "annotation-value"
        labels:
          example.com/label-key: "label-value"
    ledgers:
      metadata:
        annotations:
          example.com/annotation-key: "annotation-value"
        labels:
          example.com/label-key: "label-value"
```


The configured annotations and labels will be added to the PVC resources created by the BookKeeperCluster CR.

Example:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: journal-0
  annotations:
    example.com/annotation-key: "annotation-value"
  labels:
    example.com/label-key: "label-value"
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```
