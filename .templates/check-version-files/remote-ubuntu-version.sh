#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Retrieves the current version of the package.

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
  addError "INVALID_OPTION" "Unrecognized option";
  addError "CANNOT_RETRIEVE_SERVICE_VERSION" "Cannot retrieve the service version, neither via SERVICE_VERSION environment variable nor using dpkg -p ${SERVICE_PACKAGE}";
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
      --)
        shift;
        break;
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
      -h | --help | -v | -vv | -q)
         shift;
         ;;
      --)
        shift;
        break;
        ;;
    esac
  done

  if isEmpty "${PACKAGE}"; then
    PACKAGE="${1}";
    shift;
  fi
}

## Main logic
## dry-wit hook
function main() {
  local _result;
  local _package;
  local _rescode=-1;

  if ! isEmpty "${PACKAGE}"; then
    _package="${PACKAGE}";
  elif ! isEmpty "${SERVICE_PACKAGE}"; then
    _package="${SERVICE_PACKAGE}";
  fi

  logDebug -n "Checking ${PACKAGE} local version";
  _result="$(apt-get update > /dev/null; apt-cache madison ${_package} | grep 'Packages' | head -n 1 | awk '{print $3;}'; /usr/local/bin/aptget-cleanup.sh > /dev/null)";
  _rescode=$?;
  if ! isTrue ${_rescode}; then
    logDebugResult FAILURE "${_result}";
    exitWithErrorCode CANNOT_RETRIEVE_SERVICE_VERSION;
  fi

  if isEmpty ${_result}; then
    logDebugResult FAILURE "${_result}";
    exitWithErrorCode CANNOT_RETRIEVE_SERVICE_VERSION;
  else
    logDebugResult SUCCESS "${_result}";
    echo "${_result}";
  fi
}
