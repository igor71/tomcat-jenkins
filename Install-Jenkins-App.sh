#! /bin/bash

#################################################
#  Update repositories -- we will need them all #
#  the time, during server run                  #
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
  
  
###################################
# Installing & Configuring vsftpd #
####################################
   curl -OSL http://ftp.cn.debian.org/debian/pool/main/o/openssl/libssl1.1_1.1.0f-3+deb9u2_amd64.deb
   dpkg --install libssl1.1_1.1.0f-3+deb9u2_amd64.deb
   curl -OSL http://us.archive.ubuntu.com/ubuntu/pool/main/v/vsftpd/vsftpd_3.0.3-11_amd64.deb
   dpkg --install vsftpd_3.0.3-11_amd64.deb
   rm vsftpd_3.0.3-11_amd64.deb libssl1.1_1.1.0f-3+deb9u2_amd64.deb
   cp /etc/vsftpd.conf /etc/vsftpd.conf.orig
   mkdir -p /var/ftp/pub
   chown nobody:nogroup /var/ftp/pub && \
   apt-get install -f && \
   apt-get clean && \
   rm -rf /var/lib/apt/lists/* && \
   rm -rf /tmp/* /var/tmp/*
   
   echo "" | sudo tee -a /etc/fstab
   echo "#FTP Server For Jenkins" | sudo tee -a /etc/fstab
   echo "" | sudo tee -a /etc/fstab
   echo "//yifileserver/common/DOCKER_IMAGES/Tensorflow/ /var/ftp/pub cifs user=server,pass=123server123,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm 0 0" | sudo tee -a /etc/fstab
   mount -a
   echo ""
   
   sudo sed -i "s/anonymous_enable=NO/anonymous_enable=YES/" /etc/vsftpd.conf
   sudo sed -i "s/local_enable=YES/local_enable=NO/" /etc/vsftpd.conf
   sudo sed -i "s/listen=NO/listen=YES/" /etc/vsftpd.conf
   sudo sed -i "s/listen_ipv6=YES/listen_ipv6=NO/" /etc/vsftpd.conf
  
   sed -i '/anonymous_enable=YES/a # Stop prompting for a password on the command line '\\n'no_anon_password=YES' /etc/vsftpd.conf
   sed -i '/no_anon_password=YES/a # Point anonymous user to the ftp root directory '\\n'anon_root=/var/ftp/ '\\n'# Show the user and group as ftp:ftp, regardless of the owner' /etc/vsftpd.conf
   sed -i '/# Show the user and group as ftp:ftp, regardless of the owner/a hide_ids=YES '\\n'# Limit the range of ports that can be used for passive FTP' /etc/vsftpd.conf
   sed -i '/# Limit the range of ports that can be used for passive FTP/a pasv_min_port=40000 '\\n'pasv_max_port=50000' /etc/vsftpd.conf
   
   echo " ### Removing any trailing space and CR characters from /etc/vsftpd.conf file ###"
   sed -i 's,\r,,;s, *$,,' /etc/vsftpd.conf
   
   systemctl restart vsftpd
   systemctl status vsftpd
   
  
############################################
#                Install Jenkins           #
############################################

wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | apt-key add -
echo deb https://pkg.jenkins.io/debian-stable binary/ | tee /etc/apt/sources.list.d/jenkins.list
apt-get update
apt-get install -y jenkins
systemctl status jenkins
EOF
