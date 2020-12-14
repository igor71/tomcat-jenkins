# tomcat-jenkins-ftp-ssh-keys
TomCat Based, FTP & SSH Enabled Jenkins Docker Image ---- Using Host ssh-keys inside Docker container

Jenkins Home Directory on TomCat will be at : `/var/lib/jenkins`

Jenkins Job will run under `root` user account

Build the docker as following:
```
cd /tmp
git clone --branch=app-jenkins-ftp-ssh-keys --depth=1 https://github.com/igor71/tomcat-jenkins
cd tomcat-jenkins
docker build -t igor71/jenkins-tomcat-ftp-ssh:0.0
```


Run the docker image with following command:
```
docker run -d --name=jenkins-ftp-ssh -p 8080:8080 -p 21:21 -p 37000:22 -p 65500-65515:65500-65515 -v /software/releases:/var/ftp:ro -v /software:/software -v /var/run/docker.sock:/var/run/docker.sock igor71/jenkins-ftp-ssh:0.0
```
Where:
`-d` - >> run docker image detached, othervise use `-it` option

`--name=` >> assign name to running container

`-p 21:21` >> redirect ftp 21 host port to 21 ftp container port

`-p 37000:22` >> redirect ssh 22 host port to 37000 ssh container port

`-p 65500-65515:65500-65515` redirect ftp-passive ports

`-p 8080:8080` >> redirect default tomcat http port

`-v /software:/software` >> make media folder inside host available in docker container

`-v /var/run/docker.sock:/var/run/docker.sock` >> mount the Docker socket as a volume allowing Jenkins utilize host Docker installation for spinning up containers in builds and building images

`-v /software/releases:/var/ftp:ro`  >> Mount FTP share folder

`yi/jenkins-ftp-ssh:0.0` >> docker image name & tag

### It is posible to create & run docker using yml file:

* Make sure docker-compose is installed:
`sudo pip install docker-compose`
* Clone the repository:
`git clone --branch=jenkins-vsftpd-ssh-keys --depth=1 https://github.com/igor71/tomcat-jenkins`
* cd to tomcat-jenkin directory
`cd tomcat-jenkins`
* Run following command: 
`sudo docker-compose up -d`
* (`-d` option will run docker container detached)
* docker will map /home/$USER/.ssh relevant ssh keys as read only into the docker container.
* Mapping real user UID & GUID into docker container will make possible root user inside docker container ssh keys proper usage
All explanation are here: https://jtreminio.com/blog/running-docker-containers-as-current-host-user/

### In order to check docker working as expected, perform following steps:

`docker exec -it jenkins-ftp-ssh /bin/bash`

`./services_check.sh`

Check if ftp & ssh services are running inside docker container:
```
 export TERM=xterm
 
 /etc/init.d/ssh status
 
 netstat -aln | grep ":21"
 
 netstat -aln | grep ":22"
 
 lsof -i | grep ftp
 
 lsof -i | grep sshd
 
 ```
