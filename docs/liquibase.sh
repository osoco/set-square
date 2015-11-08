#!/bin/bash

cd /opt/liquibase-${LIQUIBASE_VERSION}
echo "Running $*"
./liquibase --changeLogFile=/changelogs/changelog.yml $*
