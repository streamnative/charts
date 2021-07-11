# Manage auth methods broadly across Vault
path "auth/token/*" {
  capabilities = ["create", "read", "update", "delete"]
}

path "auth/userpass/*" {
  capabilities = ["create", "read", "update", "delete"]
}

# List, create, update, and delete key/value secrets
path "secret/data/pulsar/*" {
  capabilities = ["create", "read", "update", "delete"]
}

path "secret/metadata/pulsar/*" {
  capabilities = ["create", "read", "update", "delete"]
}
