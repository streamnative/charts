defaultRole=streamnative
boundAudiences="00000002-0000-0000-c000-000000000000"
userClaim="appid"
groupsClaim="appid"
policies="super-user"
jwksUrl="https://sts.windows.net/06a8a086-ae6e-45b5-a22e-ad90de23013e/discovery/keys"
vault auth enable jwt
vault write auth/jwt/config \
    jwks_url=$jwksUrl \
    default_role=$defaultRole
vault write auth/jwt/role/$defaultRole \
    role_type="jwt" \
    name=$defaultRole \
    bound_audiences=$boundAudiences \
    user_claim=$userClaim \
    groups_claim=$groupsClaim \
    clock_skew_leeway=60 \
    expiration_leeway=150 \
    not_before_leeway=150 \
    policies=$policies \
    ttl=1h