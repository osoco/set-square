#!/bin/bash

exec /opt/logstash/bin/logstash agent -f /etc/logstash/conf.d/cron.conf
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
