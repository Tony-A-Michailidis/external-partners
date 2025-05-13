FROM openjdk:25-jdk-slim

WORKDIR /usr/local/geonetwork

COPY core-geonetwork/web/target/geonetwork.war .

EXPOSE 8080

CMD ["java", "-Djetty.port=8080", "-jar", "geonetwork.war"]