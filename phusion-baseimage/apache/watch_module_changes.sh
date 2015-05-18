#!/bin/bash

function compile() {
    make > /dev/null && \
    make install > /dev/null
}

FILE="$1"
LAST=$(md5sum "$FILE")
while true; do
  sleep 1
  NEW=$(md5sum "$FILE")
  if [ "$NEW" != "$LAST" ]; then
    LAST="$NEW"
    compile && \
    service apache2 restart > /dev/null 3>&1 2>&1 > /dev/null && \
    echo "Apache restarted as ${FILE} changed"
  fi
done

