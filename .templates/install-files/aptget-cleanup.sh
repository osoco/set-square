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
  checkReq "apt-get" "APTGET_NOT_INSTALLED";
}

## Defines the errors
## dry-wit hook
function defineErrors() {
  addError "INVALID_OPTION" "Unrecognized option";
  addError "APTGET_NOT_INSTALLED" "apt-get not found";
  addError "ERROR_REMOVING_UNUSED_PACKAGES" "Error removing unused packages";
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
##   autoremove_packages
function autoremove_packages() {
  local -i _rescode;

  logInfo -n "Removing unused packages";
  ${APTGET_REMOVE} > /dev/null
  _rescode=$?;

  if isTrue ${_rescode}; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi

  return ${_rescode};
}

## Cleans up the system.
## Example:
##   clean_system
function clean_system() {
  local -i _rescode;

  logInfo -n "Cleaning up the system";
  ${APTGET_CLEAN} > /dev/null
  _rescode=$?;

  if isTrue ${_rescode}; then
    logInfoResult SUCCESS "done";

    logInfo -n "Autoremoving unused packages";
    ${APTGET_AUTOREMOVE} > /dev/null;
    _rescode=$?;

    if isTrue ${_rescode}; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILURE "failed";
    fi
  else
    logInfoResult FAILURE "failed";
  fi

  return ${_rescode};
}

## Deletes all caches.
## Example:
##   remove_cache
function delete_caches() {
  local -i _rescode;

  logInfo -n "Deleting caches";
  ${APTGET_CLEAN} > /dev/null
  _rescode=$?;

  if isTrue ${_rescode}; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi

  return ${_rescode};
}

## Truncates all log files.
## Example:
##   truncate_logs
function truncate_logs() {
  local -i _rescode;

  logInfo -n "Truncating log files";
  find /var/log -type f -name '*.log' -exec bash -c 'echo > {}' \;
  _rescode=$?;

  if isTrue ${_rescode}; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi

  return ${_rescode};
}

## Wipes the contents of the /tmp.
## Example:
##   wipe_temporary_folder
function wipe_temporary_folder() {
  local -i _rescode;

  logInfo -n "Wiping /tmp";
  rm -rf /tmp/*;
  _rescode=$?;

  if isTrue ${_rescode}; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi
  rm -rf /tmp/.* > /dev/null 2>&1

  return ${_rescode};
}

## Main logic
## dry-wit hook
function main() {
  autoremove_packages;
  clean_system;
  delete_caches;
  truncate_logs;
  wipe_temporary_folder;
}
