#!/bin/bash

for d in $(find /usr/local/lib/apache2/ -maxdepth 1 -type d); do
  cd /etc/apache2/mods-available;
  for ext in load conf; do
    ln -s ${d}/$(basename ${d}).${ext} $(basename ${d}).${ext};
  done
  cd ${d};
  for f in $(find . -maxdepth 1 -name '*.c'); do
    # We don't need the ${d} parameter
    # but it makes easier to find out
    # which folder is being monitored
    # when inspecting processes via ps -ef
    /usr/local/bin/watch_module_changes.sh ${f} ${d} &
  done
  a2enmod $(basename ${d});
done

service apache2 restart &

exit 0
