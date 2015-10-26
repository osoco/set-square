#!/bin/bash

cd /opt/liquibase
shift
echo "Running liquibase --changeLogFile=/changelogs/changelog.yml --driver=org.mariadb.jdbc.Driver $@"
./liquibase --changeLogFile=/changelogs/changelog.yml --driver=org.mariadb.jdbc.Driver "$@"
