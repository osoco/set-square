#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Creates Monit configuration to check the exposed ports are running correctly.

Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Defines the requirements
## dry-wit hook
function defineReq() {
  checkReq cut CUT_NOT_INSTALLED;
  checkReq sed SED_NOT_INSTALLED;
  checkReq grep GREP_NOT_INSTALLED;
}

## Defines the errors
## dry-wit hook
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export CUT_NOT_INSTALLED="cut is not installed";
  export SED_NOT_INSTALLED="sed is not installed";
  export GREP_NOT_INSTALLED="grep is not installed";
  
  ERROR_MESSAGES=(\
    INVALID_OPTION \
    CUT_NOT_INSTALLED \
    SED_NOT_INSTALLED \
    GREP_NOT_INSTALLED \
  );

  export ERROR_MESSAGES;
}

## Validates the input.
## dry-wit hook
function checkInput() {

  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;
  logDebug -n "Checking input";

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
        -h | --help | -v | -vv | -q | --quiet)
         shift;
         ;;
      *) logDebugResult FAILURE "failed";
         exitWithErrorCode INVALID_OPTION;
         ;;
    esac
  done

  logDebugResult SUCCESS "valid";
}

## Parses the input
## dry-wit hook
function parseInput() {

  local _flags=$(extractFlags $@);
  local _flagCount;
  local _currentCount;

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q | --quiet)
         shift;
         ;;
    esac
  done
}

## Retrieves the exposed ports in given Dockerfile.
## -> 1: the dockerfile
## <- RESULT: the space-separated list of ports exposed in the Dockerfile.
## Usage:
##   retrieve_exposed_ports /Dockerfiles/Dockerfile;
##   echo "Exposed ports in the Dockerfile: ${RESULT}"
function extract_ports() {
  local _dockerfile="${1}";
  local _result=();
  local _aux;
  local _single;
  local _oldIFS="${IFS}";
  IFS=$'\n';
  for _aux in $(grep EXPOSE "${_dockerfile}" | cut -d' ' -f 2- | sed -e 's/^ \+//g'); do
    IFS="${_oldIFS}";
    for p in ${_aux}; do
      if ! arrayContainsElement "${p}" "${_result[@]}"; then
        _result[${#_result[@]}]="${p}";
      fi
    done
  done
  export RESULT=${_result[@]}
}
        
## Main logic
## dry-wit hook
function main() {
  local _ports;
  echo 'check host localhost with address 0.0.0.0' > ${MONIT_CONF_FILE}
  for d in $(ls ${DOCKERFILES_LOCATION} | grep -v -e '^Dockerfile'); do
    extract_ports "${DOCKERFILES_LOCATION}/${d}";
    _ports="${RESULT}";
    for _port in ${_ports}; do
      logInfo -n "Creating Monit check for ${_port} port (exposed in ${DOCKERFILES_LOCATION}/${d})";
      cat <<EOF >> ${MONIT_CONF_FILE}
	if failed port ${_port} with timeout ${PORT_TIMEOUT} then alert
EOF
      logInfoResult SUCCESS "done";
    done
  done
}  
