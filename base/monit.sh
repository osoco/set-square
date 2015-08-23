#!/bin/bash

echo "Starting monit"
exec 2>&1
exec monit -I
