path "auth/userpass/users/{{identity.entity.aliases.auth_userpass_2302556c.name}}" {
  capabilities = ["read", "update"]
}

path "identity/*" {
  capabilities = ["update"]
}

# Manage identity entity alias
path "identity/entity-alias/id/{{identity.entity.aliases.auth_userpass_2302556c.id}}" {
  capabilities = ["create", "read", "update", "delete"]
}


path "identity/oidc/token/*" {
  capabilities = ["read", "update"]
}