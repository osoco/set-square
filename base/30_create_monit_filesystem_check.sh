#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Creates Monit configuration to check disk usage for the root partition.

Common flags:
    * -h | --help: Display this message.
    * -X:e | --X:eval-defaults: whether to eval all default values, which potentially slows down the script unnecessarily.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Defines the requirements
## dry-wit hook
function defineReq() {
  checkReq cut CUT_NOT_INSTALLED;
  checkReq mount MOUNT_NOT_INSTALLED;
}

## Defines the errors
## dry-wit hook
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export CUT_NOT_INSTALLED="cut is not installed";
  export MOUNT_NOT_INSTALLED="mount not installed";
  export CANNOT_FIND_OUT_THE_DEVICE_FOR_THE_ROOT_FILESYSTEM="Cannot find out the device for the root filesystem";
  
  ERROR_MESSAGES=(\
    INVALID_OPTION \
    CUT_NOT_INSTALLED \
    MOUNT_NOT_INSTALLED \
    CANNOT_FIND_OUT_THE_DEVICE_FOR_THE_ROOT_FILESYSTEM \
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

## Retrieves the root path.
## <- RESULT: the device where the root filesystem is stored.
## Usage:
##   retrieve_root_path;
##   echo "The root filesystem is in ${RESULT}"
function retrieve_root_path() {
  local _result;
  logInfo -n "Finding out where the root filesystem is";
  _result="$(mount 2> /dev/null | grep ' on / ' | cut -d' ' -f1)";
  if [[ -n ${_result} ]]; then
    logInfoResult SUCCESS "done";
    export RESULT="${_result}";
  else
    logInfoResult FAILED "failed";
    exitWithErrorCode CANNOT_FIND_OUT_THE_DEVICE_FOR_THE_ROOT_FILESYSTEM;
  fi
}
        
## Main logic
## dry-wit hook
function main() {
  local _rootPath;
  retrieve_root_path;
  _rootPath="${RESULT}";

  logInfo -n "Creating monit check for root filesystem";
  cat <<EOF > ${MONIT_CONF_FILE}
check filesystem rootDisk with path / #(${_rootPath})
	if space usage > ${DISK_SPACE_THRESHOLD} for ${DISK_SPACE_POSITIVES} times within ${DISK_SPACE_CYCLES} cycles then alert
	if inode usage > ${INODE_USAGE_THRESHOLD} for ${INODE_USAGE_POSITIVES} times within ${INODE_USAGE_CYCLES} cycles then alert
EOF
  logInfoResult SUCCESS "done";
}  
