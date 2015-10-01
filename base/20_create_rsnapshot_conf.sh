#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Appends VOLUME folders declared in this image's dockerfiles, to
the rsnapshot configuration, for auto-configuring backup.

Common flags:
    * -h | --help: Display this message.
    * -X:e | --X:eval-defaults: whether to eval all default values, which potentially slows down the script unnecessarily.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Defines the errors
## dry-wit hook
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
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

## Process a Docker volume for backup.
## -> 1: The volume folder.
## <- RESULT: the rsnapshot.conf syntax for the folder.
## Example:
##   process_volume /var/lib/mysql
##   echo "${RESULT}" >> /etc/rsnapshot.conf
function process_volume() {
  local _volume="${1}";
  local _result;
  local _single=0;
  if [ "${_volume#[}" == "${_volume}" ]; then
    _single=0; # true, single
  else
    _single=1; # false, multiple
  fi
  if [ ${_single} -eq 0 ]; then
    _result="${_aux}"
  else
    local _oldIFS="${IFS}";
    IFS='"';
    for item in $(echo ${_aux} | tr -d '[],'); do
      IFS="${_oldIFS}";
      _result="${_result} $(echo ${item} | sed -e 's/^"//g' | sed -e 's/"$//g')"
    done
    _result="$(echo "${_result}" | sed -e 's/^ //g')";
  fi
  export RESULT="${_result}";
}

## Checks whether a volume is suitable of backup.
## -> 1: The volume
## <- RESULT: 0 if so, 1 otherwise.
## Example:
##   is_backup_volume "/var/log/" -> false
##   is_backup_volume "/backup/data" -> true
function is_backup_volume() {
  local _volume="${1}";
  local _result;
  if [ "x${_volume##/backup}" == "x${_volume}" ]; then
    _result=1;
  else
    result=0;
  fi
  return ${_result};
}

## Extracts the volumes from a given Dockerfile.
## -> 1: the Dockerfile.
## <- RESULT: the space-separated volumes.
## Example:
##   extract_volumes /Dockerfiles/Dockerfile
##   echo "Volumes found: ${RESULT}"
function extract_volumes() {
  local _dockerfile="${1}"
  local _result=();
  local _aux;
  local _single;
  local _oldIFS="${IFS}";
  IFS=$'\n';
  for _aux in $(grep VOLUME "${_dockerfile}" | cut -d' ' -f 2- | sed -e 's/^ \+//g'); do
    IFS="${_oldIFS}";
    if is_backup_volume "${_aux}"; then
      process_volume "${_aux}";
      for v in ${RESULT}; do
        _result[${#_result[@]}]="${v}";
      done
    fi
  done
  export RESULT=${_result[@]}
}                

## Checks whether backups are enabled as a whole.
## <- RESULT: 0 if so, 1 otherwise.
## Example:
##   is_backup_enabled -> false
##   # assuming the environment variable is DOBACKUP
##   export DOBACKUP=0; is_backup_enabled -> true
function is_backup_enabled() {
  local _result;
  _evalVar "${ENABLE_BACKUP_ENVIRONMENT_VARIABLE}";
  local _dobackup="${RESULT}";
  if [ -z ${_dobackup+x} ]; then
    _result=0;
  else
    result=1;
  fi
  return ${_result};
}

## Main logic
## dry-wit hook
function main() {
  if is_backup_enabled; then
    sed -i -e 's/^backup/#backup/g' ${RSNAPSHOT_CONF}
    for p in $(ls ${DOCKERFILES_LOCATION} | grep -v -e '^Dockerfile'); do
      extract_volumes "${DOCKERFILES_LOCATION}/${p}";
      for v in ${RESULT}; do
        logInfo -n "Annotating ${v} for backup (defined as volume in ${DOCKERFILES_LOCATION}/${p})";
        echo "backup ${v}/"$'\t'"${BACKUP_REMOTE_USER}@${BACKUP_HOST}:${v}/" >> ${RSNAPSHOT_CONF};
        logInfoResult SUCCESS "done";
        for f in ${CUSTOM_BACKUP_SCRIPTS_FOLDER}/${CUSTOM_BACKUP_SCRIPT_PREFIX}-*; do
          if [ -x "$f" ]; then
            logInfo -n "Annotating custom backup script for ${v} ${f}";
            echo "backup_script"$'\t'"${f} ${v}" >> ${RSNAPSHOT_CONF}
            logInfoResult SUCCESS "done";
          fi
        done
      done
    done
  fi
}  
