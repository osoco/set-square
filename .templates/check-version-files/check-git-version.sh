#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Checks the versions of the remote and the local repository.

Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Defines the errors
## dry-wit hook
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export CANNOT_RETRIEVE_SERVICE_VERSION="Cannot retrieve the service version, neither via SERVICE_VERSION environment variable nor using dpkg -p ${SERVICE_PACKAGE}";
  export CHECK_VERSION_SCRIPT_UNAVAILABLE="The check-version.sh script is not available";
  export EMPTY_RESPONSE_FROM_CHECK_VERSION_SCRIPT="Empty response from check-version script";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    CANNOT_RETRIEVE_SERVICE_VERSION \
    CHECK_VERSION_SCRIPT_UNAVAILABLE \
    EMPTY_RESPONSE_FROM_CHECK_VERSION_SCRIPT \
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
      -h | --help | -v | -vv | -q)
         shift;
         ;;
      *) logDebugResult FAILURE "failed";
         exitWithErrorCode INVALID_OPTION;
         ;;
    esac
  done

  if [ ! -f "${CHECK_VERSION_SCRIPT}" ]; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode CHECK_VERSION_SCRIPT_UNAVAILABLE;
  fi
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
      -h | --help | -v | -vv | -q)
         shift;
         ;;
    esac
  done
}

## Retrieves the service version.
## <- RESULT: such information.
function retrieve_version() {
  local _result;

  if [ -n "${SERVICE_VERSION}" ]; then
    _result="${SERVICE_VERSION}";
  elif [ -n "${SERVICE_PACKAGE}" ]; then
    _result="$(dpkg -p ${SERVICE_PACKAGE} | grep -e '^Version: ' | cut -d' ' -f2)";
  fi
  if [ -z ${_result} ]; then
    exitWithErrorCode CANNOT_RETRIEVE_SERVICE_VERSION;
  fi

  export RESULT="${_result}";
}

## Main logic
## dry-wit hook
function main() {
  local _suffix="$(basename $SCRIPT_NAME .sh)";
  local _version;
  _suffix="${_suffix#latest}";
  local _latest=$("${CHECK_VERSION_SCRIPT}${_suffix}");
  if [ -n "${_latest}" ]; then
    retrieve_version;
    _version="${RESULT}";
    if [ "${_latest}" == "${_version}" ]; then
      echo "up to date";
    else
      echo "New version available: ${_latest}";
    fi
  else
    exitWithErrorCode EMPTY_RESPONSE_FROM_CHECK_VERSION_SCRIPT;
  fi
}

_name="${0#check-version}-";

cd /opt/${_name};
_localRev="$(git rev-parse HEAD)";
git ls-remote 2>&1 | grep HEAD | awk '{print $1;}'
