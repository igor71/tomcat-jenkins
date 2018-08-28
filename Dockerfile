# Base Linux Ubuntu Image with SSH Daemon

FROM ubuntu:16.04

LABEL MAINTAINER="Igor Rabkin<igor.rabkin@xiaoyi.com>"

#################################################
#  Update repositories -- we will need them all #
#  the time, also when container is run         #
#################################################

ARG DEBIAN_FRONTEND=noninteractive 
RUN apt-get update


#################################################
#          Set Time Zone Asia/Jerusalem         #
################################################# 

ENV TZ=Asia/Jerusalem
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


################################################
#     Basic desktop environment                #
################################################

# Locale, language
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
locale-gen
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8


#################################################
#     Very basic installations                  #
#################################################

RUN apt-get install -y --no-install-recommends \
    curl \
    wget \
    man \
    tree \
    htop \
    vim \
    nano \
    tzdata \
    pv \
    iputils-ping \
    net-tools \
    screen \
    lsof \
    sudo && \
    apt-get install -f && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/*


##############################################################
# Upgrade packages on image & Installing and Configuring SSH #
##############################################################

RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openssh-server &&\
    rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin 
	
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
RUN mkdir /var/run/sshd 


########################################
#    Set jenkins user to the image     #
########################################

RUN useradd -m -d /home/jenkins -s /bin/bash jenkins &&\
    echo "jenkins:jenkins" | chpasswd 
		
# Add the users to sudoers group
RUN echo "jenkins  ALL=(ALL)  NOPASSWD: ALL" >> /etc/sudoers
      
# Set full permission for jenkins folder
RUN chmod -R 777 /home/jenkins

#################
# Install Java  #
#################

RUN \
  apt-get update && \
  apt-get install -y --no-install-recommends \
  sshpass \
  git \
  vsftpd \
  python-software-properties \
  software-properties-common && \
  apt-get --purge remove openjdk* && \
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
 
# Define commonly used JAVA_HOME variable
RUN \
  echo 'JAVA_HOME="/usr/lib/jvm/java-8-oracle/jre"' | sudo tee -a /etc/environment && \
  echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a ~/.bashrc && \
  echo 'export CATALINA_HOME=/opt/tomcat' | sudo tee -a ~/.bashrc


###############################
# Install & Configure TomCat  #
###############################

RUN \
  groupadd tomcat && \
  useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat && \
  cd /opt && \
  curl -OSL http://apache.spd.co.il/tomcat/tomcat-8/v8.5.33/bin/apache-tomcat-8.5.33.tar.gz && \
  tar -xzf apache-tomcat-8.5.33.tar.gz && \
  mv apache-tomcat-8.5.33 tomcat && \
  rm apache-tomcat-8.5.33.tar.gz && \
  chown -hR tomcat:tomcat tomcat && \
  chmod +x /opt/tomcat/bin 
 
COPY files/services_check.sh / 
COPY files/init /
COPY files/tomcat.service /etc/systemd/system/ 
COPY files/tomcat-users.xml /opt/tomcat/conf/  
COPY files/server.xml /opt/tomcat/conf/ 
COPY files/manager/META-INF/context.xml /opt/tomcat/webapps/manager/META-INF/ 
COPY files/host-manager/META-INF/context.xml /opt/tomcat/webapps/host-manager/META-INF/
COPY files/branch_list.groovy /root/.jenkins/

RUN \
  chmod u+x /init && \
  chmod u+x /services_check.sh && \
  chmod 644 /etc/systemd/system/tomcat.service && \
  chmod 600 /opt/tomcat/conf/tomcat-users.xml && \
  chown tomcat:tomcat /opt/tomcat/conf/tomcat-users.xml && \
  chmod 600 /opt/tomcat/conf/server.xml && \
  chown tomcat:tomcat /opt/tomcat/conf/server.xml && \
  chmod 640 /opt/tomcat/webapps/manager/META-INF/context.xml && \
  chown tomcat:tomcat /opt/tomcat/webapps/manager/META-INF/context.xml && \
  chmod 640 /opt/tomcat/webapps/host-manager/META-INF/context.xml && \
  chown tomcat:tomcat /opt/tomcat/webapps/host-manager/META-INF/context.xml 

	 
#################################
# Prepare Jenkins Installation. #
#################################

RUN \
  cd /tmp && \
  curl -OSL http://mirrors.jenkins.io/war-stable/latest/jenkins.war && \
  chmod u+x jenkins.war

######################################
# Expose Standard SSH & TomCat Ports #
######################################

EXPOSE 22
EXPOSE 8080


##################################
# Starting SSH & TomCat Services #
##################################

ENTRYPOINT ["/init"]

