#!/bin/bash

_var="$(basename ${0})";

if export | grep -e "^declare -x SQ_${_var}" > /dev/null 2>&1; then
    eval echo $(echo \${SQ_${_var}})
else
  echo "Environment variable not found";
  exit 1;
fi
