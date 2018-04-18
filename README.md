# tomcat-jenkins
TomCat Based, SSH Enabled Jenkins Docker Image

Jenkins Home Directory on TomCat will be at : /root/.jenkins

Run the docker inmage with following command:

docker run -d --name=jenkins -p 37000:22 -p 8080:8080 -v /media:/media -v /var/run/docker.sock:/var/run/docker.sock yi/docker-jenkins:x.x

Where:
-d - >> run docker image detached, othervise use -it

--name= >> assign name to running container

-p 37000:22 >> redirect ssh 22 host port to 37000 ssh container port

-p 8080:8080 >> redirect default tomcat http port

-v /media:/media >> make media folder inside host available in docker container

-v /var/run/docker.sock:/var/run/docker.sock >> mount the Docker socket as a volume allowing Jenkins utilize host Docker installation for spinning up containers in builds and building images

yi/docker-jenkins:x.x >> docker image name & tag

Note, ssh service will be in stop state when you'll run docker container.
In order to start ssh service in running container, perform following steps:

docker exec -it jenkins /bin/bash

./start.sh

Check if ssh service running inside docker container:

 netstat -aln | grep ":22"
 
 /etc/init.d/ssh status


