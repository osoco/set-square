#!/bin/bash

cd /opt/liquibase
shift
echo "Running liquibase --changeLogFile=/changelogs/changelog.yml --driver=org.postgresql.Driver $*"
./liquibase --changeLogFile=/changelogs/changelog.yml --driver=org.postgresql.Driver $*
