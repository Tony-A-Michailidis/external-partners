# build using: docker build -t geonetwork:4.4.6-custom . 

# ── Stage 1: build WAR ──────────────────────────────────────────────
FROM maven:3.8.6-openjdk-11-slim AS builder
WORKDIR /app
COPY . .
RUN mvn clean install -DskipTests

# ── Stage 2: runtime with GeoNetwork’s entrypoint ───────────────────
FROM geonetwork:4.4.6
# FROM jetty:12-jdk24  
COPY --from=builder /app/web/target/geonetwork.war \
     /opt/geonetwork/webapp/geonetwork.war
# (the official image’s entrypoint will handle your GEONETWORK_DB_* env vars)
EXPOSE 8080

# to get to the database, if you really want to keep your Jetty-only image, then you must supply the DB settings via JAVA_OPTS. 
# So in the docker-compose add the following and in this dockerfile for stage 2 do the: FROM jetty:9-jdk11 
# services:
#   geonetwork:
#     build: .
#     environment:
#       - JAVA_OPTS=-Xms512M\ -Xmx2G\ -Djetty.host=0.0.0.0\
#         -Dgeonetwork.db.type=postgres\
#         -Dgeonetwork.db.host=database\
#         -Dgeonetwork.db.port=5432\
#         -Dgeonetwork.db.name=geonetwork\
#         -Dgeonetwork.db.username=geonetwork\
#         -Dgeonetwork.db.password=geonetwork
#     ports:
#       - "8080:8080"
#     depends_on:
#       - database
#  That way GeoNetwork’s Spring config will pick up the -Dgeonetwork.db.* system properties and connect to your external Postgres.