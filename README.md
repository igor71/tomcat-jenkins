# tomcat-jenkins-ssh
TomCat Based, SSH Enabled Jenkins Docker Image

Jenkins Home Directory on TomCat will be at : `/root/.jenkins`

Run the docker image with following command:
```
docker run -d --name=jenkins-ssh -p 37000:22 -p 8080:8080 -v /media:/media -v /var/run/docker.sock:/var/run/docker.sock yi/jenkins-ssh:x.x
```
Where:
`-d`- >> run docker image detached, othervise use -it

`--name=` >> assign name to running container

`-p 37000:22` >> redirect ssh 22 host port to 37000 ssh container port

`-p 8080:8080` >> redirect default tomcat http port

`-v /media:/media` >> make media folder inside host available in docker container

`-v /var/run/docker.sock:/var/run/docker.sock` >> mount the Docker socket as a volume allowing Jenkins utilize host Docker installation for spinning up containers in builds and building images

`yi/docker-jenkins:x.x` >> docker image name & tag

### It is posible to create & run docker using yml file:

* Make sure docker-compose is installed:
`sudo pip install docker-compose`
* Clone the repository:
`git clone --branch=master --depth=1 https://github.com/igor71/tomcat-jenkins`
* cd to tomcat-jenkin directory
`cd tomcat-jenkins`
* Run following command: 
`sudo docker-compose up -d`
* (`-d` option will run docker container detached)

### In order to check docker working as expected, perform following steps:
```
docker exec -it jenkins-ssh /bin/bash

./services_check.sh

Check if ssh service running inside docker container:

 netstat -aln | grep ":22"
 
 /etc/init.d/ssh status
 
 lsof -i | grep sshd
 ```



