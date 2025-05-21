Portal: 

https://codespacesGenerated-8082.app.github.dev/ 

Create the network before running the docker-compose for the first time in a new codespaces: 

docker network create web 

Best to bring it down first and then build again: 
docker-compose down
docker-compose up -d --force-recreate

Give it a couple of minutes to bring up the containers before you visit the page. Look for the URL at the "ports" tab and for port 8082

Note that "docker-compose down -v" will also remove the volumes, so you'll lose the data you have saved in the persistent volumes of geoserver, careful! 
