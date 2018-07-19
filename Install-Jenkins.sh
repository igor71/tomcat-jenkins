#! /bin/bash

#################################################
#  Update repositories -- we will need them all #
#  the time, diring server run                  #
#################################################

sudo apt-get update

#################################
# Install Java And Dependences  #
#################################

sudo apt-get install -y --no-install-recommends \
  sshpass \
  git \
  pv \
  python-software-properties \
  software-properties-common 
  
  
 sudo su <<'EOF'
  add-apt-repository ppa:openjdk-r/ppa -y 
  apt-get update 
  apt-get install -y --no-install-recommends openjdk-8-jre-headless 
  apt-get clean all 
  rm -rf /var/lib/apt/lists/*  
  apt-get install -f 
  rm -rf /tmp/* /var/tmp/*

  # Remove repository
  add-apt-repository --remove ppa:openjdk-r/ppa


############################################
# Define commonly used JAVA_HOME variable  #
############################################

  echo 'JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"' | tee -a /etc/environment 
  echo 'export PATH=$JAVA_HOME/bin:$PATH' | tee -a ~/.bashrc 
  
  
############################################
#                Install Jenkins           #
############################################

wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | apt-key add -
echo deb https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list
apt-get update
apt-get install -y jenkins
systemctl status jenkins
EOF