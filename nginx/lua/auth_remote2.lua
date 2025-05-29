
local oidc = require("resty.openidc")

local auth_header_name = "Authorization"

-- this is a trusted IDP Setup and the bearer_jwt_verify  below will trust this, so in the future it could be the azure Entra or gckey etc...
local opts = {
  discovery = "https://dev.edh-cde.unclass.dfo-mpo.gc.ca/auth/realms/edh/.well-known/openid-configuration",
  jwk_expires_in = 24 * 60 * 60,
  ssl_verify = "no" -- Set to "yes" in production
}

local relogin_opts = {
  redirect_uri_path = "/geonetwork/redirect_uri",
  discovery = "https://vigilant-goggles-7p5wwqrxw9vfx554-443.app.github.dev/auth/realms/IDP/.well-known/openid-configuration",
  client_id = "geonetwork",
  client_secret = "1U5C4SS48XHDQaozGjJcZS35YnzEor9M",
  scope = "openid email profile",
  ssl_verify = "no",
  jwk_expires_in = 24 * 60 * 60                 -- cache your JWKS for a day
}

-- Check for existing Bearer token
local auth_header = ngx.req.get_headers()[auth_header_name]
if auth_header then
    -- call bearer_jwt_verify for OAuth 2.0 JWT validation
    -- this 
    local res, err = oidc.bearer_jwt_verify(opts)

    if not err then
      -- Set the Shibboleth header according to config-security-shibboleth-overrides.properties
      ngx.req.set_header("REMOTE_USER", res.sub)
      ngx.log(ngx.NOTICE, res.sub) 
      ngx.req.set_header("Shib-Person-surname", res.family_name)
      ngx.log(ngx.NOTICE, res.family_name) 
      ngx.req.set_header("Shib-InetOrgPerson-givenName", res.given_name)
      ngx.log(ngx.NOTICE, res.given_name) 
      ngx.req.set_header("Shib-EP-Email", res.)
      ngx.log(ngx.NOTICE, res.email) 
      ngx.log(ngx.NOTICE, auth_header) 
      return
    else 
      --Fallback: redirect the browser/user to the interactive simulated partner Keycloak login 
      local res, err = oidc.authenticate(relogin_opts)
      if err then
        ngx.log(ngx.ERR, "EDH OIDC error: ", err)
        return ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
      end  
      -- On return from Keycloak, set the same headers and let NGINX proxy on to GeoNetwork
      ngx.req.set_header("REMOTE_USER",     res.id_token.sub)
      ngx.req.set_header("Shib-Person-surname",   res.id_token.family_name)
      ngx.req.set_header("Shib-InetOrgPerson-givenName", res.id_token.given_name)
      ngx.req.set_header("Shib-EP-Email",           res.id_token.email)
    end   
end


