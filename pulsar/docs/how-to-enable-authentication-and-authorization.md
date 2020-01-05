# Authentication and Authorization

We support two ways to authenticate and authorize the requests from a client.
One is the JWT and another is the TLS. We use Kubernetes Secrets to save the
authentication files. You can follow the steps below to create Kubernetes Secrets
and enable authentication and authorization.

## Enable JWT Authentication

1. **Generate a Token**

    You can use `bin/pulsar` to generate a secret key or a pair of public key and private key 
    and use it to generate a token. You can download the Pulsar binary at 
    [here](https://pulsar.apache.org/en/download/).
    
    >**Note**: The subject you bind to the token is the superuser in the Pulsar. The `superUserRoles`
    can configure in [values.yam.](../helm-charts/pulsar/values.yaml) `admin.user`.

    - Using a secret key to generate a token.
    
        Generate a secret key:
        
        ```bash
        bin/pulsar tokens create-secret-key -a HS256 --output SECRETKEY
        ```
        
        Generate a token:
        
        ```bash
        bin/pulsar tokens create -a HS256 --secret-key file:///path/to/SECRETKEY --subject admin > TOKEN
        ```
  
    - Using a pair of public key and private key to generate a token.
        
        Generate a pair of public key and private key:
    
        ```bash
        bin/pulsar tokens create-key-pair -a RS256 --output-private-key PRIVATEKEY --output-public-key PUBLICKEY 
        ```
        
        Generate a token:
        
        ```bash
        bin/pulsar tokens create -a RS256 --private-key file:///path/to/PRIVATEKEY --subject admin > TOKEN
        ```
        
    Or you can use `pulsarctl` to generate a secret key or a pair of a public key and private key
    and use it to generate a token. You can refer to the [Pulsarctl](https://github.com/streamnative/pulsarctl)
    to see how to download it.
    
    - Using a secret key to generate a token.
    
        Generate a secret key:
        
        ```bash
        pulsarctl token create-secret-key -a HS256 -o SECRETKEY
        ```
        
        Generate a token:
        
        ```bash
        pulsarctl token create -a HS256 --secret-key-file SECRETKEY --subject admin > TOKEN
        ```
        
    - Using a pair of public key and private key to generate a token.
    
        Generate a pair of public key and private key:
        
        ```bash
        pulsarctl token create-key-pair -a RS256 --output-private-key PRIVATEKEY --output-public-key PUBLICKEY
        ```
        
        Generate a token:
        
        ```bash
        pulsarctl token create -a RS256 --private-key-file PRIVATEKEY --subject admin > TOKEN
        ```
    
2. **Create a Kubernetes Secrets**

    > Note: The Kubernetes Secrets name has a suffix with `broker-secrets`, the `pulsar` is the chart name.
    You need to replace the `pulsar` to your chart name.
    
    If you are using secret key to generate a token:

    ```bash
    kubectl create secret generic pulsar-broker-secrets --from-file=SECRETKEY --from-file=TOKEN
    ```
    
    If you are using a pair of public key and private key to generate a token:
    
    ```bash
    kubectl create secret generic pulsar-broker-secrets --from-file=PUBLICKEY --from-file=TOKEN
    ```

3. **Enable Authentication**

    You need to config the below values in the broker `auth` in the [values.yaml](../helm-charts/pulsar/values.yaml).

    If you want to enable authentication in the broker, you need to change the `enable` to `true`.

    If you are using secret key to generate a token, you need to change the `usingSecretKey` to `ture`.
    
    If you are using a key pair of public key and private key, you need to change the `usingSecretKey` to `false`.
    
## Enable Authorization

If you want to enable authorization in the broker, you need to change the `auth.authorization.enable` in the 
[values.yaml](../helm-charts/pulsar/values.yaml) and the authentication should be enabled at the
same time.
