pipeline {
  agent {label 'jenkins-tomcat'}
    stages {
        stage('Build Jenkins-FTP-SSH Docker Image') {
            steps {
                sh 'docker build -t igor71/jenkins-tomcat-ftp-ssh:${docker_tag} .'
            }
        }
	stage('Test Jenkins-FTP-SSH Image For Mapped Ports') { 
            steps {
                sh '''#!/bin/bash -xe
	            echo 'Hello, Jenkins_Docker'
                    image_id="$(docker images -q igor71/jenkins-tomcat-ftp-ssh:${docker_tag})"
                    if [[ "$(docker images -q igor71/jenkins-tomcat-ftp-ssh:${docker_tag} 2> /dev/null)" == "$image_id" ]]; then
                       docker inspect --format='{{range $p, $conf := .Config.ExposedPorts}} {{$p}} {{end}}' $image_id
                    else
                       echo "Ports are not listenning inside docker container, check the Dockerfile!!!"
                       exit -1
                    fi 
                   ''' 
		    }
		}
	 stage('Save & Load Docker Image') { 
            steps {
                sh '''#!/bin/bash -xe
		        echo 'Saving Docker image into tar archive'
                        docker save igor71/jenkins-tomcat-ftp-ssh:${docker_tag} | pv -f | cat > $WORKSPACE/igor71-jenkins-tomcat-ftp-ssh-${docker_tag}.tar
			
                        echo 'Remove Original Docker Image' 
			CURRENT_ID=$(docker images | grep -E '^igor71/jenkins-tomcat-ftp-ssh.*'${docker_tag}'' | awk -e '{print $3}')
			docker rmi -f $CURRENT_ID
			
                        echo 'Loading Docker Image'
                        pv -f $WORKSPACE/igor71-jenkins-tomcat-ftp-ssh-${docker_tag}.tar | docker load
			docker tag $CURRENT_ID igor71/jenkins-tomcat-ftp:${docker_tag}
                        
                        echo 'Removing Temp Archive.'  
                        rm $WORKSPACE/igor71-jenkins-tomcat-ftp-ssh-${docker_tag}.tar
                   ''' 
		    }
		}			   
        stage('Push Jenkins-TomCat Image To DockerHub') {
        /* Finally, push the image considering two important things:
         * First, the image name should contain userID from the existing DockerHub Repo
         * Second, credentialsId is username/password set containing the DockerHubID and the password for it,
         * which must be setup first in Jenkins >> Credentials >> global >> Add Credentials
         * The key is the blank url parameter, which DockerRegistry translates into the appropriate DockerHub reference. */
            steps {
              withDockerRegistry([ credentialsId: "557b24c8-ef4d-4132-8de4-1890c68a3b82", url: "" ]) {
              sh 'docker push igor71/jenkins-tomcat-ftp-ssh:${docker_tag}'
               }
            }
        }
    }
	post {
            always {
               script {
                  if (currentBuild.result == null) {
                     currentBuild.result = 'SUCCESS' 
                  }
               }
               step([$class: 'Mailer',
                     notifyEveryUnstableBuild: true,
                     recipients: "igor.rabkin@xiaoyi.com",
                     sendToIndividuals: true])
            }
         } 
}
