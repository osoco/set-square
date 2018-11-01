#!/bin/bash

if [[ -n "${1}" ]] && [[ -e "/Dockerfiles/${1}" ]]; then
    cat "/Dockerfiles/${1}"
else
    cat /Dockerfiles/Dockerfile
fi
