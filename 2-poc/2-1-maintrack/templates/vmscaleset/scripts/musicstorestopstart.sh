#! /bin/bash
### BEGIN INIT INFO
# Provides: MusicStore
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: MusicStore
# Description: This file starts and stops Music Store
#
### END INIT INFO

USER=`grep 1000 /etc/passwd | awk -F":" '{ print $1}'`
DOTNET_HOME=/opt/dotnet
export PATH=$PATH:$DOTNET_HOME
MUSICSTOREAPP=/opt/music/MusicStore.dll

case "$1" in
 start)
   su $USER -c "dotnet $MUSICSTOREAPP &"
   ;;
 stop)
   PID=`ps -ef | grep -i musicstor | grep -v grep | awk '{print $2}'`
   su $USER -c "kill -9 $PID"
   sleep 10
   ;;
 restart)
   stop ;
   sleep 5
   start ;
   ;;
 *)
   echo "Usage: musicstore {start|stop|restart}" >&2
   exit 3
   ;;
esac