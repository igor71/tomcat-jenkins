## Jenkins Running On TomCat Enabled Server

TomCat Based, SSH Enabled Jenkins Ubuntu Server

Jenkins Home Directory on TomCat will be at: /var/lib/jenknins

### Pre Requirements

Ubuntu LTS server with SSH & Samba Enabled

1. Setup network on server to use static IP address

2. Configure Jenkins user root privileges with NO PASSWORD option:
```
sudo visudo

jenkins ALL=(ALL:ALL) NOPASSWD: ALL
```
3. Setup and configure permanent access to /media/common


