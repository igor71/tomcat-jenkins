pipeline {
  agent {label 'jenkins-tomcat'}
    stages {
        stage('Build Basic SSH Image') {
            steps {
              sh 'docker build -f Dockerfile.SSH -t yi/docker-ssh:0.0 .'
            }
        }
		stage('Test Basic SSH Image') {
            agent { docker 'yi/docker-ssh:0.0' } 
            steps {
                echo 'Hello, SSH_Docker'
                sh '''#!/bin/bash -xe
                    netstat -aln | grep ":22" 
                       if [ "$?" != "0" ]; then
                          echo "SSH port not listenning inside docker container, check docker file!!!"
                          exit -1
                       fi
                   ''' 
            }
        }
        stage('Build Jenkins-TomCat Image') {
            steps {
                sh 'docker build -t igor71/jenkins-tomcat:0.1 .'
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
              sh 'docker push igor71/jenkins-tomcat:0.1'
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
