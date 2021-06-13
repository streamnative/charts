path "auth/userpass/users/*" {
  capabilities = ["read", "update", "list", "create", "sudo", "delete"]
}

path "auth/approle/role/*" {
  capabilities = ["read", "update", "list", "create", "sudo", "delete"]
}

path "identity/*" {
  capabilities = ["read", "create", "update", "list"]
}

# Manage identity entity alias
path "identity/entity-alias/id/{{identity.entity.aliases.MOUNT_ACCESSOR.id}}" {
  capabilities = ["create", "read", "update", "delete"]
}


path "identity/oidc/token/*" {
  capabilities = ["read", "update"]
}
