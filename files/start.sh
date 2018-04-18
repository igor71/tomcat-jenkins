#!/bin/bash

# Check the status of ssd service and start it if not running

case "$(pidof sshd | wc -w)" in

0)  echo "Restarting sshd:"
    /etc/init.d/ssh start
    ;;
1)  echo "sshd already running"
    ;;
esac

# Starting TomCat Service

cd /opt/tomcat/bin
  ./startup.sh
