
#!/bin/bash
### BEGIN INIT INFO
#
# Provides:	 location_server
# Required-Start:	$local_fs  $remote_fs
# Required-Stop:	$local_fs  $remote_fs
# Default-Start: 	2 3 4 5
# Default-Stop: 	0 1 6
# Short-Description:	initscript
# Description: 	This file should be used to construct scripts to be placed in /etc/init.d.
#
### END INIT INFO
 
## Fill in name of program here.
cd  $(dirname $0) # 当前位置跳到脚本位置
PROG="node"
PROG_PATH="$(pwd)" ## Not need, but sometimes helpful (if $PROG resides in /opt for example).

WORK_PATH="$PROG_PATH/work"

start() {
    if [[ -e "$WORK_PATH/$PROG.env" ]]; then
        source $WORK_PATH/$PROG.env
    fi

    ADMIN=$1
    INSTANCE=$2
    CONFIG_PATH=$WORK_PATH/goku-node.json
    RUN_MODEL="console"
    if [ -f "$CONFIG_PATH" ]; then
	RUN_MODEL="config"  
    fi

    if [[ "$ADMIN" = "" ]] ; then
        ADMIN=${ENV_ADMIN}
    fi
    
    if [[ "$INSTANCE" = "" ]]; then
	INSTANCE = ${ENV_INSTANCE}
    fi

    if [[ "$ADMIN" == "" && "$RUN_MODEL" == "console" ]] ; then
        echo "start fail :need admin url"
        exit 1
    fi

    mkdir -p $WORK_PATH/logs
    echo -e "ENV_PORT=$PORT\nENV_ADMIN=$ADMIN" > $WORK_PATH/$PROG.env
    
    if [[ "$ADMIN" != "NULL" ]]; then
    	$PROG_PATH/$PROG --admin=$ADMIN --instance=$INSTANCE
    else 
	$PROG_PATH/$PROG --config=$CONFIG_PATH
    fi
}
 
stop() {
    echo "begin stop"
    if [[ -e "$WORK_PATH/$PROG.pid" ]]; then
        ## Program is running, so stop it
        pid="$(cat $WORK_PATH/$PROG.pid)"
        if [[ "ps ax|grep $pid|grep '$PROG' |awk '{print \$1}'" != ""  ]];then
            kill $pid
            if [[ $? != 0 ]];then
                echo "$PROG stop error"
                exit 1
            fi
            rm -f  "$WORK_PATH/$PROG.pid"
            echo "$PROG stopped"
        fi
    else
        ## Program is not running, exit with error.
        echo "Note! $PROG not started!" 1>&2

    fi
}
 
## Check to see if we are running as root first.
## Found at http://www.cyberciti.biz/tips/shell-root-user-check-script.html
#if [[ "$(id -u)" != "0" ]]; then
#    echo "This script must be run as root" 1>&2
#    exit 1
#fi
#
case "$1" in
    start)
        start $2 $3
        exit 0
    ;;
    stop)
        stop
        exit 0
    ;;
    reload|restart|force-reload)
        stop
        start $2 $3
        exit 0
    ;;
    **)
        echo "Usage: $0 {start|stop|reload|restart|force-reload} [admin url] [port] " 1>&2
        exit 1
    ;;
esac

