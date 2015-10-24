#!/bin/bash

cd /opt/liquibase
echo "Running liquibase --changeLogFile=/changelogs/changelog.yml --driver=org.mariadb.jdbc.Driver $*"
./liquibase --changeLogFile=/changelogs/changelog.yml --driver=org.mariadb.jdbc.Driver $*
