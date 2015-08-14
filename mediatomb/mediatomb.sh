#!/bin/bash

sed 's/exit/return/g' ./etc/init.d/mediatomb > /tmp/mediatomb
source /tmp/mediatomb status 2>&1 > /dev/null
rm -f /tmp/mediatomb

$DAEMON $DAEMON_ARGS
