## Jenkins Running On TomCat Enabled Server

TomCat Based, SSH Enabled Jenkins Ubuntu Server

Jenkins Home Directory on TomCat will be at: /var/lib/jenknins

### Pre Requirements

Ubuntu LTS server with SSH & Samba Enabled, jenkins user accont with root priviliges

1. Setup network on server to use static IP address

2. Configure yis user root privileges with NO PASSWORD option:
```
sudo visudo

jenkins ALL=(ALL:ALL) NOPASSWD: ALL
```
3. Setup & configure permanent access to /media/common on the server

### Running TomCat & Jenkins Installation Script On The Server
```
1. su yi

2. git clone --branch=develop --depth=1 https://github.com/igor71/tomcat-jenkins

3. cd tomcat-jenkins

4. sudo bash Install-Jenkins-On-TomCat.sh
```
