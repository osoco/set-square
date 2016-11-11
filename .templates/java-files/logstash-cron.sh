#!/bin/bash

exec /opt/logstash/bin/logstash agent -f /etc/logstash/conf.d/cron.conf
