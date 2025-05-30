Create the network before running the docker-compose for the first time in a new codespaces: 

docker network create web 

Best to bring it down first and then build again: 
docker-compose down
docker-compose up -d --build

Give it a couple of minutes to bring up all the services the containers before you visit the page:

https://vigilant-goggles-7p5wwqrxw9vfx554-443.app.github.dev/ 

Note that "docker-compose down -v" will also remove the volumes, so you'll lose the data you have saved in the persistent volumes of geoserver, keycloak etc. careful! 

You can change the server URL in the .env file and adjust the names of the certs in the nginx.conf file if different. 

-----------
for the nginx log you can add ngx.log(ngx.WARN, res.family_name)  to get the family name in the log, plus all the following: 

Assuming your `error_log` is set to `warn` or lower, this will write the user’s “sub” claim into your logs:

```lua
ngx.log(ngx.WARN, res.sub)
```

Under the hood, `oidc.bearer_jwt_verify(opts)` returns a Lua table (`res`) that is literally the decoded JSON payload of the JWT. In other words, every claim in the token becomes a key in `res` ([GitHub][1], [GitHub][2]).

---

### Other fields you can log

Anything that’s in the JWT payload is fair game. Common OpenID Connect claims include:

* **Standard claims**

  * `res.iss` – issuer
  * `res.sub` – subject (user ID)
  * `res.aud` – audience
  * `res.exp` – expiration time (UNIX epoch)
  * `res.iat` – issued-at time
  * `res.nbf` – not-before time (if present)
  * `res.jti` – JWT ID

* **Profile claims**

  * `res.name`
  * `res.given_name`
  * `res.family_name`
  * `res.middle_name`
  * `res.nickname`
  * `res.preferred_username`

* **Contact & locale**

  * `res.email`
  * `res.email_verified`
  * `res.phone_number`
  * `res.phone_number_verified`
  * `res.locale`
  * `res.picture`

* **Session & security**

  * `res.auth_time`
  * `res.acr` (authentication context class reference)
  * `res.amr` (authentication methods reference)
  * `res.azp` (authorized party)

* **Scopes & roles**

  * `res.scope` – space-separated scopes
  * `res.realm_access.roles` – Keycloak realm roles
  * `res.resource_access.<client>.roles` – Keycloak client roles

* **Any custom claims**
  – e.g. `res.organization`, `res.department`, or whatever your IdP injects

To see *everything* at once you can even do:

```lua
local cjson = require("cjson.safe")
ngx.log(ngx.WARN, "JWT claims: ", cjson.encode(res))
```

…and inspect the full JSON payload in your logs.

[1]: https://github.com/zmartzone/lua-resty-openidc?utm_source=chatgpt.com "zmartzone/lua-resty-openidc: OpenID Connect Relying ... - GitHub"
[2]: https://raw.githubusercontent.com/zmartzone/lua-resty-openidc/master/lib/resty/openidc.lua?utm_source=chatgpt.com "https://raw.githubusercontent.com/zmartzone/lua-re..."

----------------
This is a sample payload decoded and displayed with: 
      local cjson = require("cjson.safe")
      ngx.log(ngx.WARN, "full JWT payload: ", cjson.encode(res))

"family_name":"Michailidis",
"iat":1748613400,
"given_name":"Tony",
"email":"tony.michailidis@...",
"typ":"Bearer",
"realm_access":{"roles":["AAD-AKS-EDH-Admin","AAD-EDH-Admin","default-roles-edh","AAD-EDH-Reader","AAD-AKS-EDH-Developer"]},
"exp":1748613700,
"aud":["realm-management","grafana","broker","catalogue","account","mapserver"],
"jti":"dfb69f48-757d-4d35-add0-43422b3bb845",
"auth_time":1748605370,
"groups":["\/Argo CD\/ArgoCD Admins","\/Argo CD\/ArgoCD Developers","\/DFO"],
"locale":"en-CA",
"scope":"openid email profile",
"allowed-origins":["https:\/\/localhost","http:\/\/docker.internal:8080","http:\/\/k3s.internal","http:\/\/localhost:8080","https:\/\/k3s.internal","https:\/\/dev.edh.unclass.intra.azure.cloud.....","https:\/\/dev.edh-cde.unclass.....","https:\/\/docker.internal:8443","http:\/\/localhost","http:\/\/localhost:4200"],
"preferred_username":"tony.michailidis@....",
"email_verified":true,
"name":"Tony Michailidis",
"sub":"7b78860c-6e4d-4288-8751-7b3a40ecb4cc",
"azp":"portal",
"nonce":"5602ae82-d450-469a-8dbd-41716ab9ce1a",
"iss":"https:\/\/dev.edh-cde.unclass....\/auth\/realms\/edh",
"session_state":"1cf63b7f-4461-4c8b-be21-9f146ea1c6ed",
"resource_access":{"mapserver":{"roles":["ROLE_AUTHENTICATED"]},
"realm-management":{"roles":["view-realm","view-identity-providers","manage-identity-providers","impersonation","realm-admin","create-client","manage-users","query-realms","view-authorization","query-clients","query-users","manage-events","manage-realm","view-events","view-users","view-clients","manage-authorization","manage-clients","query-groups"]},
"grafana":{"roles":["grafana-editor","grafana-viewer","grafana-admin"]},
"broker":{"roles":["read-token"]},
"catalogue":{"roles":["inventory:Editor","Administrator","Guest","RegisteredUser"]},
"account":{"roles":["manage-account","manage-account-links","view-profile"]}},
"sid":{"1cf63b7f-4461-4c8b-be21-9f146ea1c6ed"}, 
client: 172.18.0.1, server: vigilant-goggles-7p5wwqrxw9vfx554-443.app.github.dev, request: "POST /geo-api/search/records/_search HTTP/2.0", host: "localhost:443"