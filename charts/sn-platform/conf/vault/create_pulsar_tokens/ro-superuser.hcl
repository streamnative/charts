# Manage auth methods broadly across Vault
path "auth/token/*" {
  capabilities = ["read"]
}

path "auth/userpass/*" {
  capabilities = ["read"]
}

# List, create, update, and delete key/value secrets
path "secret/data/pulsar/*" {
  capabilities = ["read"]
}

path "secret/metadata/pulsar/*" {
  capabilities = ["read"]
}
