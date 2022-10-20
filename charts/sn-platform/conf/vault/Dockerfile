FROM vault:1.10.4

RUN wget https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

RUN apk add zsh
RUN cp /bin/zsh /usr/local/bin/
COPY create_pulsar_tokens /vault/pulsar/
COPY init_vault_streamnative_console /vault/pulsar/
RUN chown -R vault:vault /vault/pulsar