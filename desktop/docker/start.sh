#!/bin/sh

$MAPUTNIK_DESKTOP && (
    cd /data
    while true
    do
        maputnik --static /data/
        sleep 1
    done
) &