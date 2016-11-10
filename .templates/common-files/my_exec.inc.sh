#!/bin/bash

function run_help() {
  /usr/local/bin/help
}

trap 'run_help' ERR

function cron_check() {
  if [ "${ENABLE_CRON}" -ne "true" ]; then
    chmod -x /etc/service/cron/run > /dev/null 2>&1
  fi
}

function monit_check() {
  if [ "${ENABLE_MONIT}" -ne "true" ]; then
    chmod -x /etc/my_init.d/*monit*.sh > /dev/null 2>&1
    chmod -x /etc/service/monit/run > /dev/null 2>&1
  fi
}

if [ "${ENABLE_RSNAPSHOT}" -ne "true" ]; then
    chmod -x /etc/cron.*/rsnapshot* > /dev/null 2>&1
fi

$*
