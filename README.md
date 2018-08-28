# tomcat-jenkins-ftp
TomCat Based, FTP Enabled Jenkins Docker Image

Jenkins Home Directory on TomCat will be at : `/var/lib/jenkins`

Run the docker image with following command:
```
docker run -d --name=jenkins-ftp -p 8080:8080 -p 21:21 -p 65500-65515:65500-65515 -v /media/common/DOCKER_IMAGES/Tensorflow:/var/ftp:ro -v /media:/media -v /var/run/docker.sock:/var/run/docker.sock yi/jenkins-ftp:x.x
```
Where:
`-d` - >> run docker image detached, othervise use `-it` option

`--name=` >> assign name to running container

`-p 21:21` >> redirect ftp 21 host port to 21 ftp container port

`-p 65500-65515:65500-65515` redirect ftp-passive ports

`-p 8080:8080` >> redirect default tomcat http port

`-v /media:/media` >> make media folder inside host available in docker container

`-v /var/run/docker.sock:/var/run/docker.sock` >> mount the Docker socket as a volume allowing Jenkins utilize host Docker installation for spinning up containers in builds and building images

`-v /media/common/DOCKER_IMAGES/Tensorflow:/var/ftp:ro`  >> Mount FTP share folder

`yi/jenkins-ftp:x.x` >> docker image name & tag

### It is posible to create & run docker using yml file:

* Make sure docker-compose is installed:
`sudo pip install docker-compose`
* Clone the repository:
`git clone --branch=jenkins-vsftpd --depth=1 https://github.com/igor71/tomcat-jenkins`
* cd to tomcat-jenkin directory
`cd tomcat-jenkin`
* Run following command: 
`sudo docker-compose up -d`
* (`-d` option will run docker container detached)

### In order to check docker working as expected, perform following steps:

`docker exec -it jenkins-ftp /bin/bash`

`./services_check.sh`

Check if ftp service running inside docker container:
```
 export TERM=xterm
 
 netstat -aln | grep ":21"
 
 ```
