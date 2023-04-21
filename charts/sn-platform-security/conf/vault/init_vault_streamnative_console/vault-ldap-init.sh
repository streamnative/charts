URL="ldap://elegant_varahamihira:389"
USER_DN="ou=people,dc=planetexpress,dc=com"
GROUP_DN="ou=people,dc=planetexpress,dc=com"
GROUP_ATTR="cn"
UPN_DOMAIN=""
BIND_DN="cn=admin,dc=planetexpress,dc=com"
BIND_PASS="GoodNewsEveryone"
vault auth enable ldap
vault write auth/ldap/config url=$URL userdn=$USER_DN groupdn=$GROUP_DN groupattr=$GROUP_ATTR upndomain=$UPN_DOMAIN insecure_tls=true userattr=uid starttls=false binddn=$BIND_DN bindpass=$BIND_PASS
vault write auth/ldap/groups/streamnative policies=user
vault auth enable approle
userMountAccessor=$(vault auth list | grep auth_ldap | awk '{print $3}')
serviceAccountMountAccessor=$(vault auth list | grep auth_approle | awk '{print $3}')
sed -i "s#MOUNT_ACCESSOR#$userMountAccessor#g" /vault-ldap/user-template.json /vault-ldap/user.hcl /vault-ldap/super-user-template.json
sed -i "s#MOUNT_ACCESSOR#$serviceAccountMountAccessor#g" /vault-ldap/service-account-template.json /vault-ldap/service-account.hcl
sed -i "s#MOUNT_ACCESSOR#$serviceAccountMountAccessor#g" /vault-ldap/super-service-account-template.json

vault policy write user /vault-ldap/user.hcl
vault write identity/entity name="user" policies="user"
vault write identity/oidc/key/user name=user rotation_period=24h verification_ttl=24h
vault write identity/oidc/role/user key=user ttl=12h template=@/vault-ldap/user-template.json
userClientId=$(vault read identity/oidc/role/user | grep client_id |  awk '{print $2}')
vault write identity/oidc/key/user name=user rotation_period=24h verification_ttl=24h allowed_client_ids=$userClientId

vault policy write super-user /vault-ldap/user.hcl
vault write identity/entity name="super-user" policies="super-user"
vault write identity/oidc/key/super-user name=super-user rotation_period=24h verification_ttl=24h
vault write identity/oidc/role/super-user key=super-user ttl=12h template=@/vault-ldap/super-user-template.json
superUserClientId=$(vault read identity/oidc/role/super-user | grep client_id |  awk '{print $2}')
vault write identity/oidc/key/super-user name=super-user rotation_period=24h verification_ttl=24h allowed_client_ids=$superUserClientId

vault policy write service-account /vault-ldap/service-account.hcl
vault write identity/entity name="service-account" policies="service-account"
canonicalId=$(vault read identity/entity/name/service-account | grep -v _id | grep id | awk '{print $2}')
vault write identity/entity-alias name="service-account"  mount_accessor=$serviceAccountMountAccessor canonical_id=$canonicalId metadata=name='service-account'
vault write identity/oidc/key/service-account name=service-account rotation_period=24h verification_ttl=24h
vault write identity/oidc/role/service-account key=service-account ttl=12h template=@/vault-ldap/service-account-template.json
serviceAccountClientId=$(vault read identity/oidc/role/service-account | grep client_id |  awk '{print $2}')
vault write identity/oidc/key/service-account name=service-account rotation_period=24h verification_ttl=24h allowed_client_ids=$serviceAccountClientId

vault policy write super-service-account /vault-ldap/service-account.hcl
vault write identity/entity name="super-service-account" policies="super-service-account"
canonicalId=$(vault read identity/entity/name/super-service-account | grep -v _id | grep id | awk '{print $2}')
vault write identity/entity-alias name="super-service-account"  mount_accessor=$serviceAccountMountAccessor canonical_id=$canonicalId metadata=name='super-service-account'
vault write identity/oidc/key/super-service-account name=super-service-account rotation_period=24h verification_ttl=24h
vault write identity/oidc/role/super-service-account key=super-service-account ttl=12h template=@/vault-ldap/super-service-account-template.json
superServiceAccountClientId=$(vault read identity/oidc/role/super-service-account | grep client_id |  awk '{print $2}')
vault write identity/oidc/key/super-service-account name=super-service-account rotation_period=24h verification_ttl=24h allowed_client_ids=$superServiceAccountClientId
vault write auth/approle/role/apachepulsar policies=super-service-account
