#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Cleans up the system by removing unused packages.

Common flags:
    * -h | --help: Display this message.
    * -X:e | --X:eval-defaults: whether to eval all default values, which potentially slows down the script unnecessarily.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Declares the requirements.
## dry-wit hook
function checkRequirements() {
  checkReq apt-get APTGET_NOT_AVAILABLE;
}

## Defines the errors
## dry-wit hook
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export APTGET_NOT_AVAILABLE="apt-get not found";
  export ERROR_REMOVING_UNUSED_PACKAGES="Error removing unused packages";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    APTGET_NOT_AVAILABLE \
    ERROR_REMOVING_UNUSED_PACKAGES \
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
      -h | --help | -v | -vv | -q | -X:e | --X:eval-defaults)
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
      -h | --help | -v | -vv | -q | -X:e | --X:eval-defaults)
         shift;
         ;;
    esac
  done
}

## Removes unused packages from the system.
## Example:
##   clean_packages
function autoremove_packages() {
  logInfo -n "Removing unused packages";
  ${APTGET_REMOVE} > /dev/null
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi
}

## Cleans up the system.
## Example:
##   clean_system
function clean_system() {
  logInfo -n "Cleaning up the system";
  ${APTGET_CLEAN} > /dev/null
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi
}

## Deletes all caches.
## Example:
##   remove_cache
function delete_caches() {
  logInfo -n "Deleting caches";
  ${APTGET_CLEAN} > /dev/null
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi
}

## Main logic
## dry-wit hook
function main() {
  autoremove_packages;
  clean_system;
  delete_caches;
}
