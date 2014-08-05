#!/bin/bash
# myapp daemon
# chkconfig: 345 20 80
# description: myapp daemon
# processname: myapp

#DAEMON_PATH="/home/wes/Development/projects/myapp"

DAEMON=/usr/local/bin/analyzer
NAME=freeling
DESC="Freeling text analyzer"
PIDFILE_ES=/var/run/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME
QUEUE=2
WORKERS=2
PORT=50005
CMD="/usr/local/bin/analyzer -f /home/deploy/apps/mapa76.info/hephaestus/current/config/freeling/config/es.cfg /usr/share/freeling/config/es.cfg --server --port $PORT --workers $WORKERS --queue $QUEUE  --outf tagged --nec --noflush"

case "$1" in
start)
    printf "%-50s" "Starting $NAME ES..."
#    cd $DAEMON_PATH
    export FREELINGSHARE=/usr/share/freeling
    export FREELINGCUSTOM=/home/deploy/apps/mapa76.info/hephaestus/current/config/freeling
    PID_ES=`$CMD > /var/log/freeling.log 2>&1 & echo $!`
    echo "Saving PID" $PID " to " $PIDFILE
        if [ -z $PID_ES ]; then
            printf "%sn" "Fail"
        else
            echo $PID_ES > "${PIDFILE_ES}"
            printf "%sn" "Ok"
        fi
;;
stop)
        printf "%-50s" "Stopping $NAME ES"
            PID_ES=`cat $PIDFILE_ES`
#            cd $DAEMON_PATH
        if [ -f $PIDFILE_ES ]; then
            kill -HUP $PID_ES
            printf "%s ESn" "Ok"
            rm -f $PIDFILE_ES
        else
            printf "%sn" "pidfile not found"
        fi
;;

restart)
      $0 stop
      $0 start
;;

*)
        echo "Usage: $0 {status|start|stop|restart}"
        exit 1
esac
