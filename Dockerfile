FROM jetty:9.4.51-jdk11

# Starting with Jetty 10+, the javax.servlet.* classes have moved to the new jakarta.servlet.* namespace — so Jetty 11+ breaks backward compatibility for older WARs like GeoNetwork’s.

# Clean out default webapps
RUN rm -rf /var/lib/jetty/webapps/*

# Copy GeoNetwork WAR file
#COPY core-geonetwork/web/target/geonetwork.war /var/lib/jetty/webapps/root.war
COPY core-geonetwork/web/target/geonetwork.war /var/lib/jetty/webapps/geonetwork.war

# Jetty auto-starts and deploys anything in /var/lib/jetty/webapps
# so we don't need to define CMD or ENTRYPOINT

EXPOSE 8080