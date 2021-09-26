# Tools to Export Chart Images

## Prerequisites

- python3
- install requirements with `pip install -r requirements.txt`

## Usage

- create a config file, e.g., `config.yaml`
- execute the script by `./images_exporter.py -c config.yaml`

### Examples

#### Export Images to a registry

```yaml
images:
  - quay.io/jetstack/cert-manager-controller:v1.3.1
  - quay.io/jetstack/cert-manager-webhook:v1.3.1
  - quay.io/jetstack/cert-manager-cainjector:v1.3.1
  - streamnative/pulsar-operator:v0.7.4
  - streamnative/bookkeeper-operator:v0.7.4
  - streamnative/zookeeper-operator:v0.7.4
  - streamnative/function-mesh:v0.1.7
  - streamnative/sn-platform:2.8.1.0
  - streamnative/sn-platform-console:1.1
targets:
  - registry: gcr.io/xxx/xxx
```