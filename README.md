docker-compose.yml Summary:

db (PostgreSQL): Used by both Keycloak and GeoNetwork. The user is set to keycloak with the password password and the database name is keycloak.

keycloak:

Internal HTTP port is 8085.
KC_HTTP_RELATIVE_PATH is set to /auth. This is important for how Keycloak generates URLs.
KC_HOSTNAME is set to https://vigilant-goggles-7p5wwqrxw9vfx554-443.app.github.dev/auth. This reflects the external HTTPS URL with the /auth path.
Port 8085 is exposed. Codespaces will map this to a unique external port.

geonetwork:

Internal HTTP port is 8080.
Connects to the db service as user geonetwork with password geonetwork.
Connects to Elasticsearch on http://elasticsearch:9200.
OpenID Connect (OIDC) is enabled. The configuration points to https://vigilant-goggles-7p5wwqrxw9vfx554-443.app.github.dev/auth/realms/IDP/....
Port 8080 is exposed. Codespaces will map this to a unique external port.

nginx:

Listens on host ports 80 and 443. Codespaces will map these to unique external ports.
Mounts ./nginx.conf and ./certs.
Proxies requests to:
/geonetwork/ to http://geonetwork:8080/geonetwork/.
/auth/ to http://keycloak:8085/auth/.
/elasticsearch/ to http://elasticsearch:9200/.
/geonetwork/dashboards/ to http://kibana:5601/geonetwork/dashboards/.

elasticsearch: Exposed on port 9200.

kibana: Connects to Elasticsearch.

nginx.conf Summary:

Listens on port 80 and redirects to HTTPS on port 443.
Listens on port 443 for HTTPS.

Important: The server_name for HTTPS is set to vigilant-goggles-7p5wwqrxw9vfx554-443.app.github.dev. This assumes your Codespace URL for HTTPS will consistently be on port 443.
Proxy configurations for /geonetwork/, /auth/, /elasticsearch/, and /geonetwork/dashboards/ point to the internal Docker service names and ports.

Key Points and Reminders:

Codespaces External URLs: Codespaces will generate unique external URLs for the ports you've exposed (80, 443 for Nginx, 8080 for GeoNetwork, 8085 for Keycloak, 9200 for Elasticsearch).

Accessing GeoNetwork: You will access GeoNetwork through the HTTPS URL provided by Codespaces for port 443, followed by the /geonetwork/ path:

https://your-codespace-url-443.app.github.dev/geonetwork/
Accessing Keycloak: You will access Keycloak through the HTTPS URL provided by Codespaces for port 443, followed by the /auth/ path:

https://your-codespace-url-443.app.github.dev/auth/
Making Port 443 Public: Codespaces should automatically make the ports you expose (including 443) publicly accessible. You usually don't need to do any extra steps for this within the Codespaces environment.

Keycloak Health Check: The health check for Keycloak is currently pointing to port 8085. Ensure this aligns with the internal port Keycloak is using.

GeoNetwork OIDC Configuration: Your GeoNetwork OIDC configuration in the environment variables seems to be correctly pointing to the /auth path on the Codespaces URL for port 443.

SSL Certificates: Make sure you have valid SSL certificates (even self-signed for testing) in the ./certs directory that match the server_name in your Nginx configuration for port 443.

In summary, this setup looks reasonable for running GeoNetwork with Keycloak in a GitHub Codespace environment. The key is to use the Codespaces-generated HTTPS URL on port 443 and append /geonetwork/ or /auth/ to access the respective applications.

Remember to start your Codespace and then access the services using the provided URLs. If you encounter any issues, examine the logs of each container for error messages.

To test keycloak acting as the imaginary client's IDP: 

https://dev.edh-cde.unclass.dfo-mpo.gc.ca/auth/realms/edh/protocol/openid-connect/auth?response_type=code&client_id=catalogue&redirect_uri=https://dev.edh-cde.unclass.dfo-mpo.gc.ca/catalogue/signin

or use the external partner csw client ui example:

https://dev.edh-cde.unclass.dfo-mpo.gc.ca/auth/realms/edh/protocol/openid-connect/auth?response_type=code&client_id=catalogue&redirect_uri=https://mellifluous-kulfi-8147ce.netlify.app

go to link for the demo: https://mellifluous-kulfi-8147ce.netlify.app/

-----------------------

To build geonetwork from source and the image too: 


---

# 🧱 Building GeoNetwork from Source + Running via Docker (Clean Setup)

git clone https://github.com/geonetwork/core-geonetwork.git
cd core-geonetwork
git fetch --tags
git checkout 4.4.6
git submodule update --init --recursive

This checks out the exact 4.4.6 tag and pulls in any submodules. There is no web-ui/package.json in 4.2.x + ,  the UI lives in the web module and is built by Maven

export MAVEN_OPTS="-Xmx2G"           # Java 11+: drop any MaxPermSize flags
mvn clean install -P es -DskipTests  # ES profile, skip tests
look for core-geonetwork/web/target/geonetwork.war 

Use the Dockerfile in the root /workspaces/  

Go to the core-geonetwork folder and 

docker build -t geonetwork:4.4.6-custom .

docker login -u tonym1966
dckr _pat _dPq8zLvP MP6ZRv MfzO2u qRFA _VY

Then go to the docker-compose.yml file and change the image reference for geonetwork to geonetwork:4.4.6-custom. 

Also if you run out of space and now that the image geonetwork:4.4.6-custom is built and exists in the local docker, you can delete the core-geonetwork folder (as long as you didn’t add anything you want to keep in it and you can recreate using the above steps):
 
