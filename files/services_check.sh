#!/bin/bash

# Check the status of sshd service and start it if not running

case "$(pidof sshd | wc -w)" in

0)  echo "RESTARTING SSHD SERVICE:"
    /etc/init.d/ssh start
    ;;
*)  echo "SSHD SERVICE RUNNING"
    ;;
esac

# Check the status of vsftpd service and start it if not running

case "$(pidof vsftpd | wc -w)" in

0)  echo "RESTARTING VSFTPD SERVICE:"
          /usr/sbin/vsftpd "$@"
    ;;
1)  echo "VSFTPD SERVICE RUNNING"
    ;;
esac

# Check the status of tomcat service and start it if not running

TOMCAT_PID=$(ps -ef | awk '/[t]omcat/{print $2}')

if [ -z "$TOMCAT_PID" ]
then
    echo "TOMCAT NOT RUNNING"
          sudo /opt/tomcat/bin/startup.sh
else
    echo "TOMCAT RUNNING"
fi
