Create the network before running the docker-compose for the first time in a new codespaces: 

docker network create web 

Best to bring it down first and then build again: 
docker-compose down
docker-compose up -d --build

Give it a couple of minutes to bring up all the services the containers before you visit the page:

https://vigilant-goggles-7p5wwqrxw9vfx554-443.app.github.dev/ 

Note that "docker-compose down -v" will also remove the volumes, so you'll lose the data you have saved in the persistent volumes of geoserver, keycloak etc. careful! 

You can chance the server URL in the .env file and adjust the names of the certs in the nginx.conf file if different. 