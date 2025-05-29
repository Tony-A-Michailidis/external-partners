local oidc = require("resty.openidc")

local auth_header_name = "Authorization"

local geonetwork_opts = {
  redirect_uri_path = "/geonetwork/redirect_uri",
  discovery = "https://vigilant-goggles-7p5wwqrxw9vfx554-443.app.github.dev/auth/realms/IDP/.well-known/openid-configuration",
  client_id = "geonetwork",
  client_secret = "1U5C4SS48XHDQaozGjJcZS35YnzEor9M",
  scope = "openid email profile",
  ssl_verify = "no",
  jwk_expires_in = 24 * 60 * 60
}

local test_opts = {
  redirect_uri_path = "/csw/redirect_uri",
  discovery = "https://vigilant-goggles-7p5wwqrxw9vfx554-443.app.github.dev/auth/realms/IDP/.well-known/openid-configuration",
  client_id = "geonetwork",
  client_secret = "1U5C4SS48XHDQaozGjJcZS35YnzEor9M",
  scope = "openid email profile",
  ssl_verify = "no",
  jwk_expires_in = 24 * 60 * 60
}

-- Check for existing Bearer token
local auth_header = ngx.req.get_headers()[auth_header_name]
if auth_header then
    -- call bearer_jwt_verify for OAuth 2.0 JWT validation
    local res, err = oidc.bearer_jwt_verify(opts)

    if not err then
      -- Set the Shibboleth header according to config-security-shibboleth-overrides.properties
      ngx.req.set_header("REMOTE_USER", res.sub)
      ngx.log(ngx.WARN, res.sub)
      ngx.req.set_header("Shib-Person-surname", res.family_name)
      ngx.log(ngx.WARN, res.family_name)
      ngx.req.set_header("Shib-InetOrgPerson-givenName", res.given_name)
      ngx.log(ngx.WARN, res.given_name)
      ngx.req.set_header("Shib-EP-Email", res.email)
      ngx.log(ngx.WARN, res.email)
      ngx.req.set_header("Shib-EP-organisation", res.organization)
      ngx.log(ngx.WARN, res.organization)
      ngx.req.set_header("Shib-EP-Entitlement", res.resource_access.geonetwork.roles)
      ngx.log(ngx.WARN, res.organization)
        -- ngx.req.set_header("X-User", res.sub)
        -- ngx.req.set_header("X-Username", res.preferred_username)
        -- ngx.req.set_header("X-Email", res.email)
        -- Set the OIDC_access_token header, for robot user
        -- ngx.req.set_header("OIDC_access_token", auth_header.gsub("Bearer ", ""))
        return
    end
end

--ngx.req.set_header("REMOTE_USER", "guest")
--ngx.req.set_header("Shib-Person-surname", "guest")
--ngx.req.set_header("Shib-InetOrgPerson-givenName", "guest")
--ngx.req.set_header("Shib-EP-Email", "guest-do-not-reply@guest.guest")
--ngx.req.set_header("Shib-EP-organisation", "guest")
--ngx.req.set_header("Shib-EP-Entitlement", "Guest")
--ngx.status = 301

-- we need the above and a new page and that user to login as a guest or as a real user. 
-- you will need a new page. on the page, have two links, one is login as Guest, the other 
-- is login as Tony Keycloak User.
-- the new page, could be something like. if goes to Guest login, set up in the header, for 
-- ex, "REMOTE_USER" = guest. then in lua, check header, if REMOTE_USER=guest, then set all 
-- Guest user info. If no this flag, do oidc login againt Keycloak 

-- Fallback to OIDC authentication if no valid JWT token
local res, err = oidc.authenticate(geonetwork_opts)

if err then
  ngx.status = 500
  ngx.say("Authentication failed: " .. err)
  ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

-- Set the Shibboleth header according to config-security-shibboleth-overrides.properties
ngx.req.set_header("REMOTE_USER", res.id_token.sub)
ngx.log(ngx.WARN, res.id_token.sub) 
ngx.req.set_header("Shib-Person-surname", res.id_token.family_name)
ngx.log(ngx.WARN, res.id_token.family_name) 
ngx.req.set_header("Shib-InetOrgPerson-givenName", res.id_token.given_name)
ngx.log(ngx.WARN, res.id_token.given_name) 
ngx.req.set_header("Shib-EP-Email", res.id_token.email)
ngx.log(ngx.WARN, res.id_token.email) 
ngx.req.set_header("Shib-EP-organisation", res.id_token.organization)
ngx.log(ngx.WARN, res.id_token.organization) 
ngx.req.set_header("Shib-EP-Entitlement", res.id_token.resource_access.geonetwork.roles)
ngx.log(ngx.WARN, res.id_token.resource_access.geonetwork.roles) 

-- ngx.req.set_header("OIDC_access_token", res.access_token)
-- ngx.req.set_header("Authorization", "Bearer " .. res.access_token)
-- ngx.req.set_header("X-User", res.id_token.sub)
-- ngx.req.set_header("X-Username", res.id_token.preferred_username)
-- ngx.req.set_header("X-Email", res.id_token.email)
-- Set the OIDC_id_token_payload header, for Browser user
-- ngx.req.set_header("OIDC_id_token_payload", cjson.encode(res.id_token))