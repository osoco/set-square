#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L. http://www.acm-sl.com
    Distributed under the terms of the GNU General Public License v3

Copies the SQL files to set up the TT-RSS database in a MySQL/MariaDB database.

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
  checkReq find FIND_NOT_INSTALLED;
  checkReq ip IP_NOT_INSTALLED;
}

## Defines the errors
## dry-wit hook
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export CUT_NOT_INSTALLED="cut is not installed";
  export FIND_NOT_INSTALLED="find is not installed";
  export IP_NOT_INSTALLED="ip is not installed";
  export SOURCE_SQL_FOLDER_DOES_NOT_EXIST="Source SQL folder does not exist";
  export SOURCE_SQL_FOLDER_IS_NOT_A_FOLDER="Source SQL folder is not a folder";
  export SOURCE_SQL_FOLDER_CANNOT_BE_ACCESSED="Source SQL folder cannot be accessed";
  export SOURCE_SQL_FOLDER_CANNOT_BE_READ="Source SQL folder cannot be read";
  export TARGET_SQL_FOLDER_DOES_NOT_EXIST_AND_CANNOT_BE_CREATED="Targe SQL folder does not exist and cannot be created";
  export TARGET_SQL_FOLDER_IS_NOT_A_FOLDER="Target SQL folder is not a folder";
  export TARGET_SQL_FOLDER_CANNOT_BE_ACCESSED="Target SQL folder cannot be accessed";
  export TARGET_SQL_FOLDER_CANNOT_BE_WRITTEN="Target SQL folder cannot be written";
  
  ERROR_MESSAGES=(\
    INVALID_OPTION \
    CUT_NOT_INSTALLED \
    FIND_NOT_INSTALLED \
    IP_NOT_INSTALLED \
    SOURCE_SQL_FOLDER_DOES_NOT_EXIST \
    SOURCE_SQL_FOLDER_IS_NOT_A_FOLDER \
    SOURCE_SQL_FOLDER_CANNOT_BE_ACCESSED \
    SOURCE_SQL_FOLDER_CANNOT_BE_READ \
    TARGET_SQL_FOLDER_DOES_NOT_EXIST_AND_CANNOT_BE_CREATED \
    TARGET_SQL_FOLDER_IS_NOT_A_FOLDER \
    TARGET_SQL_FOLDER_CANNOT_BE_ACCESSED \
    TARGET_SQL_FOLDER_CANNOT_BE_WRITTEN \
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

  if [ ! -e "${SOURCE_SQL_FOLDER}" ]; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode SOURCE_SQL_FOLDER_DOES_NOT_EXIST;
  fi

  if [ ! -d "${SOURCE_SQL_FOLDER}" ]; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode SOURCE_SQL_FOLDER_IS_NOT_A_FOLDER;
  fi

  if [ ! -x "${SOURCE_SQL_FOLDER}" ]; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode SOURCE_SQL_FOLDER_CANNOT_BE_ACCESSED;
  fi

  if [ ! -r "${SOURCE_SQL_FOLDER}" ]; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode SOURCE_SQL_FOLDER_CANNOT_BE_READ;
  fi

  if [ ! -e "${TARGET_SQL_FOLDER}" ]; then
    mkdir -p "${TARGET_SQL_FOLDER}" 2>&1 > /dev/null;
    if [ $? -ne 0 ]; then
      logDebugResult FAILURE "failed";
      exitWithErrorCode TARGET_SQL_FOLDER_DOES_NOT_EXIST_AND_CANNOT_BE_CREATED;
    fi
  fi

  if [ ! -d "${TARGET_SQL_FOLDER}" ]; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode TARGET_SQL_FOLDER_IS_NOT_A_FOLDER;
  fi

  if [ ! -x "${TARGET_SQL_FOLDER}" ]; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode TARGET_SQL_FOLDER_CANNOT_BE_ACCESSED;
  fi

  if [ ! -w "${TARGET_SQL_FOLDER}" ]; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode TARGET_SQL_FOLDER_CANNOT_BE_WRITTEN;
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
      -h | --help | -v | -vv | -q | --quiet)
         shift;
         ;;
    esac
  done
}

## Finds the IP for given interface.
## -> 1: The network interface.
## <- RESULT: The IP.
## <- 0 if the IP was available; 1 otherwise.
## Example:
##   if find_ip eth0; then
##     echo "eth0's IP is ${RESULT}";
##   else
##     echo "Could not retrieve eth0's IP. Is eth0 up?"
##   fi
function find_ip() {
  local _iface="${1}";
  local _result;
  local _rescode;
  ip addr show ${_iface} > /dev/null 2>&1
  _rescode=$?;
  _result="$(ip addr show eth0 | grep 'inet ' | awk '{print $2;}' | cut -d'/' -f 1)";
  export RESULT="${_result}";
  return ${_rescode};
}

## Processes a SQL template file.
## -> 1: The source folder.
## -> 2: The SQL template file.
## <- 0 if the template was processes correctly; 1 otherwise.
## Example
##   if process_sql_template /tmp create-user.sql.tpl; then
##     echo "create-user.sql.tpl processed successfully onto create-user.sql"
function process_sql_template() {
  local _folder="${1}";
  local _template="${2}";
  local _rescode;
  local _ip;
  logInfo -n "Processing ${_folder}/${_template}";
  if find_ip "${NETWORK_INTERFACE}"; then
    _ip="${RESULT}";
    sed "s/___MYIP___/${_ip}/g" "${_folder}/$(basename ${_template})" > "${_folder}/$(basename ${_template} .tpl)";
    sed -i "s ___LAN___ $(echo ${_ip} | awk -F'.' '{printf("%d.%d.%d.%%\n", $1, $2, $3);}') g"  "${_folder}/$(basename ${_template} .tpl)";
    _rescode=$?;
  fi
  if [ ${_rescode} -eq 0 ]; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi
  return ${_rescode};
}

## Finds the sql template files under given folder.
## -> 1: The source folder.
## <- RESULT: The list of SQL template files.
## Example
##   find_sql_template_files /tmp;
##   echo "Found ${#RESULT} template files to process";
##   for f in ${RESULT}; do
##     ..
##   done
function find_sql_template_files() {
  local _folder="${1}";
  find_files_matching_name "${_folder}" '*.tpl';
}

## Finds the sql files under given folder.
## -> 1: The source folder.
## <- RESULT: The list of SQL files.
## Example
##   find_sql_files /tmp;
##   echo "Found ${#RESULT} files to copy";
##   for f in ${RESULT}; do
##     ..
##   done
function find_sql_files() {
  local _folder="${1}";
  find_files_matching_name "${_folder}" '*.sql';
}

## Finds the files under given folder, matching a certain name.
## -> 1: The source folder.
## -> 2: The naming filter.
## <- RESULT: The list of matching files.
## Example
##   find_files_matching_name /tmp '*.txt';
##   echo "Found ${#RESULT} txt files";
##   for f in ${RESULT}; do
##     ..
##   done
function find_files_matching_name() {
  local _folder="${1}";
  local _criteria="${2}";
  local _result="$(find "${_folder}" -maxdepth 2 -name "${_criteria}" 2> /dev/null)";
  export RESULT="${_result}";
}

## Main logic
## dry-wit hook
function main() {
  local _templateFiles;
  local _sqlFiles;
  local _includes;
  find_sql_template_files "${SOURCE_SQL_FOLDER}";
  _templateFiles="${RESULT}";
  for _templateFile in ${_templateFiles}; do
    process_sql_template "${SOURCE_SQL_FOLDER}" "${_templateFile}";
  done
  rsync -avz --exclude='*.tpl' "${SOURCE_SQL_FOLDER}/" "${TARGET_SQL_FOLDER}/" > /dev/null 2>&1;
}  
