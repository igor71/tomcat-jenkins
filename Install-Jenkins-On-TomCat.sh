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
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
  echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
  apt-get update && \
  apt-get install -y --no-install-recommends oracle-java8-installer oracle-java8-set-default && \
  apt-get clean all && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer && \
  apt-get install -f && \
  rm -rf /tmp/* /var/tmp/*

############################################
# Define commonly used JAVA_HOME variable  #
############################################

  echo 'JAVA_HOME="/usr/lib/jvm/java-8-oracle/jre"' | sudo tee -a /etc/environment 
  echo 'export PATH=$JAVA_HOME/bin:$PATH' | tee -a ~/.bashrc 
  echo 'export CATALINA_HOME=/opt/tomcat' | tee -a ~/.bashrc


###############################
# Install & Configure TomCat  #
###############################


   groupadd tomcat 
   useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat 
   cd /opt 
   curl -OSL http://apache.spd.co.il/tomcat/tomcat-8/v8.5.32/bin/apache-tomcat-8.5.32.tar.gz 
   tar -xzf apache-tomcat-8.5.32.tar.gz 
   mv apache-tomcat-8.5.32 tomcat 
   rm apache-tomcat-8.5.32.tar.gz 
   chown -hR tomcat:tomcat tomcat 
   chmod +x /opt/tomcat/bin 

####################################
# Setting Up Jenkis Home Directory #
####################################

   mkdir -p /var/lib/jenkins
   chmod 775 var/lib/jenkins
   chown -R tomcat:tomcat /var/lib/jenkins
   
#####################################
#  Configure Jenkins On TomCat      #
#####################################

   cp /home/jenkins/files/tomcat.service /etc/systemd/system/ 
   cp /home/jenkins/files/tomcat-users.xml /opt/tomcat/conf/
   cp /home/jenkins/files/context.xml /opt/tomcat/conf/   
   cp /home/jenkins/files/server.xml /opt/tomcat/conf/ 
   cp /home/jenkins/files/manager/META-INF/context.xml /opt/tomcat/webapps/manager/META-INF/ 
   cp /home/jenkins/files/host-manager/META-INF/context.xml /opt/tomcat/webapps/host-manager/META-INF/

  chmod 644 /etc/systemd/system/tomcat.service 
  chmod 600 /opt/tomcat/conf/tomcat-users.xml 
  chown tomcat:tomcat /opt/tomcat/conf/tomcat-users.xml
  chmod 600 /opt/tomcat/conf/context.xml 
  chown tomcat:tomcat /opt/tomcat/conf/context.xml 
  chmod 600 /opt/tomcat/conf/server.xml 
  chown tomcat:tomcat /opt/tomcat/conf/server.xml 
  chmod 640 /opt/tomcat/webapps/manager/META-INF/context.xml 
  chown tomcat:tomcat /opt/tomcat/webapps/manager/META-INF/context.xml 
  chmod 640 /opt/tomcat/webapps/host-manager/META-INF/context.xml 
  chown tomcat:tomcat /opt/tomcat/webapps/host-manager/META-INF/context.xml 

	 
#################################
# Prepare Jenkins Installation. #
#################################

  cd /tmp && \
  curl -OSL http://mirrors.jenkins.io/war-stable/latest/jenkins.war
  chmod u+x jenkins.war
  systemctl daemon-reload
  systemctl start tomcat
  systemctl enable tomcat
EOF
