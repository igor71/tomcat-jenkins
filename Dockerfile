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
#     Very Basic Installations                  #
#################################################

RUN apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    htop \
    vim \
    nano \
    tzdata \
    pv \
    iputils-ping \
    net-tools \
    sudo \
    lsof \ 
    vsftpd && \
    apt-get install -f && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf /var/lib/apt/lists/*


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
 
COPY files/tomcat.service /etc/systemd/system/ 
COPY files/tomcat-users.xml /opt/tomcat/conf/  
COPY files/server.xml /opt/tomcat/conf/
COPY files/context.xml /opt/tomcat/conf/ 
COPY files/manager/META-INF/context.xml /opt/tomcat/webapps/manager/META-INF/ 
COPY files/host-manager/META-INF/context.xml /opt/tomcat/webapps/host-manager/META-INF/
COPY files/branch_list.groovy /root/.jenkins/

RUN \
  chmod 644 /etc/systemd/system/tomcat.service && \
  chmod 600 /opt/tomcat/conf/tomcat-users.xml && \
  chown tomcat:tomcat /opt/tomcat/conf/tomcat-users.xml && \
  chmod 600 /opt/tomcat/conf/context.xml
  chown tomcat:tomcat /opt/tomcat/conf/context.xml
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
  
  
#################################
#    Configure vsftpd server.   #
#################################  

RUN cp /etc/vsftpd.conf /etc/vsftpd.conf.orig && \
    rm /etc/vsftpd.conf && \
    mkdir -p /var/ftp && \
    chown nobody:nogroup /var/ftp && \
    mkdir -p /var/run/vsftpd/empty
     
COPY files/init /
RUN chmod u+x /init
 
VOLUME ["/var/ftp"]

 
###############################
#  Expose FTP & TomCat Ports  #
###############################

EXPOSE 20-21
EXPOSE 65500-65515
EXPOSE 8080


#########################################
# Add Welcome Message With Instructions #
#########################################

RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/issue && cat /etc/motd' \
	>> /etc/bash.bashrc \
	; echo "\
||||||||||||||||||||||||||||||||||||||||||||||||||\n\
|                                                |\n\
| Ubuntu Based Docker Container                  |\n\
| Running JENKINS & VFSTPD Services With         |\n\
| Jenkins User Account Enabled                   |\n\
|                                                |\n\
||||||||||||||||||||||||||||||||||||||||||||||||||\n\
\n "\
	> /etc/motd
	

##########################################
#      Configuration Sets For VSFTPD     #
##########################################

ENTRYPOINT ["/init"]

##########################################
# Enable TomCat Service On Docker Start #
##########################################

CMD ["/opt/tomcat/bin/catalina.sh", "run"]
