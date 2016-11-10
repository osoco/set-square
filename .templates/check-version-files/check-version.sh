#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Checks whether the current version is the latest available.

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
  addError INVALID_OPTION "Unrecognized option";
  addError LOCAL_VERSION_SCRIPT_UNAVAILABLE "The local-version script is not available";
  addError REMOTE_VERSION_SCRIPT_UNAVAILABLE "The remote-version script is not available";
  addError EMPTY_RESPONSE_FROM_LOCAL_VERSION_SCRIPT "Empty response from local-version script";
  addError EMPTY_RESPONSE_FROM_REMOTE_VERSION_SCRIPT "Empty response from remote-version script";
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
      --) shift;
          break;
          ;;
      *) logDebugResult FAILURE "failed";
         exitWithErrorCode INVALID_OPTION;
         ;;
    esac
  done

  if [ ! -f "${LOCAL_VERSION_SCRIPT}" ]; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode LOCAL_VERSION_SCRIPT_UNAVAILABLE;
  fi
  if [ ! -f "${REMOTE_VERSION_SCRIPT}" ]; then
      logDebugResult FAILURE "failed";
      exitWithErrorCode REMOTE_VERSION_SCRIPT_UNAVAILABLE;
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
      --)
        shift;
        break;
        ;;
    esac
  done
}

## Retrieves the service version.
## <- RESULT: such information.
function retrieve_version() {
  local _result;

  if ! isEmpty "${SERVICE_VERSION}"; then
    _result="${SERVICE_VERSION}";
  elif ! isEmpty "${SERVICE_PACKAGE}"; then
    _result="$(dpkg -p ${SERVICE_PACKAGE} | grep -e '^Version: ' | cut -d' ' -f2)";
  fi
  if isEmpty ${_result}; then
    exitWithErrorCode CANNOT_RETRIEVE_SERVICE_VERSION;
  fi

  export RESULT="${_result}";
}

## Main logic
## dry-wit hook
function main() {
  local _local=$("${LOCAL_VERSION_SCRIPT}");
  if isEmpty "${_local}"; then
    exitWithErrorCode EMPTY_RESPONSE_FROM_LOCAL_VERSION_SCRIPT;
  fi
  local _remote=$("${REMOTE_VERSION_SCRIPT}");
  if isEmpty "${_remote}"; then
    exitWithErrorCode EMPTY_RESPONSE_FROM_REMOTE_VERSION_SCRIPT;
  fi
  if [ "${_remote}" == "${_local}" ]; then
    echo "up to date";
  else
    echo "Current version: ${_local}";
    echo "New version available: ${_remote}";
  fi
}

