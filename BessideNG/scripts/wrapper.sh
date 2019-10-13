#!/bin/sh

PROCESS="$1"
PROCANDARGS=$*

while :
do
    RESULT=`pgrep ${PROCESS}`

    if [ "${RESULT:-null}" = null ]; then
            echo "${PROCESS} is not running! Retrying: "$PROCANDARGS
            $PROCANDARGS &
    else
            echo $PROCESS" is running"
    fi
    sleep 2
done 
