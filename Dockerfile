FROM maven:3.9.9-eclipse-temurin-17 as builder

WORKDIR /build
COPY . .
RUN mvn clean install -Pprod -DskipTests

FROM openjdk:25-jdk-slim
COPY --from=builder /build /usr/local/geonetwork

WORKDIR /usr/local/geonetwork
EXPOSE 8080

CMD ["mvn", "-f", "web/pom.xml", "jetty:run"]
