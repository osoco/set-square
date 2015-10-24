#!/bin/bash

cd /opt/liquibase
echo "Running liquibase --changeLogFile=/changelogs/changelog.yml --driver=org.postgresql.Driver $*"
./liquibase --changeLogFile=/changelogs/changelog.yml --driver=org.postgresql.Driver $*
