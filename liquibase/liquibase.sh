#!/bin/bash

cd /opt/liquibase
echo "Running $*"
./liquibase --changeLogFile=/changelogs/changelog.yml $*
