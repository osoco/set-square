#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3
# mod: common
# api: public
# txt: A simple "copy" tool to copy files/folders from containers to host-mounted volumes, ensuring the permissions are kept after copying.

DW.import user;

# fun: copy_folder
# api: public
# txt: Copies the contents of a folder into another.
# opt: origin: The origin folder.
# opt: destination: The destination folder.
# txt: Returns 0/TRUE if the contents were copied successfully; 1/FALSE otherwise.
# use: if copy_folder /var/local/mysql/conf.d /tmp/conf.d; then echo "/var/local/mysql/conf.d contents copied to /tmp/conf.d successfully"; fi
function copy_folder() {
  local _origin="${1}";
  local _destination="${2}";
  local -i _rescode;

  logInfo -n "Copying the contents of ${_origin} into ${_destination}";
  rsync -az "${_origin}"/ "${_destination}"/ > /dev/null;
  _rescode=$?;
  if isTrue ${_rescode}; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi

  return ${_rescode};
}

# fun: preserve_permissions
# api: public
# txt: Preserves the permissions of given folder to any file inside of that folder.
# opt: folder: The folder.
# txt: Returns 0/TRUE if the permissions were restored successfully; 1/FALSE otherwise.
# use: if preserve_pemissions "/tmp"; then echo "/tmp contents permissions restored"; fi
function preserve_permissions() {
  local _folder="${1}";
  local -i _rescode;
  local _userId;
  local _groupId;

  checkNotEmpty "folder" "${_folder}" 1;

  if retrieveOwnerUid "${_folder}"; then
    _userId="${RESULT}";
  else
    exitWithErrorCode CANNOT_RETRIEVE_UID_OF_FOLDER "${_folder}";
  fi
  if retrieveOwnerGid "${_folder}"; then
    _groupId="${RESULT}";
  else
    exitWithErrorCode CANNOT_RETRIEVE_GID_OF_FOLDER "${_folder}";
  fi

  logInfo -n "Restoring permissions of ${_folder}/* to ${_userId}:${_groupId}";
  chown -R ${_userId}:${_groupId} "${_folder}"/* > /dev/null;
  _rescode=$?;
  if isTrue ${_rescode}; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi

  return ${_rescode};
}

# fun: main
# api: public
# txt: Main logic
# txt: Returns 0/TRUE always.
# use: main
function main() {
  copy_folder "${ORIGIN}" "${DESTINATION}";
  preserve_permissions "${DESTINATION}";
}

## Script metadata and CLI settings.

setScriptDescription "A simple \"copy\" tool to copy files/folders from containers to host-mounted volumes, ensuring the permissions are kept after copying.";

addCommandLineParameter "input" "The source file to copy" MANDATORY SINGLE;
addCommandLineParameeter "output" "The destination" MANDATORY SINGLE;

addError ORIGIN_PARAMETER_IS_MANDATORY "origin is mandatory";
addError DESTINATION_PARAMETER_IS_MANDATORY "destination is mandatory";
addError ORIGIN_DOES_NOT_EXIST "origin does not exist";
addError ORIGIN_IS_NOT_READABLE "No permissions to read from ";
addError CANNOT_WRITE_TO_DESTINATION "Cannot write to ";
addError CANNOT_RETRIEVE_UID_OF_FOLDER "Cannot retrieve uid of folder ";
addError CANNOT_RETRIEVE_GID_OF_FOLDER "Cannot retrieve gid of folder ";

function dw_parse_input_cli_parameter() {
  local _input="${1}";

  if isEmpty "${_input}"; then
    if isEmpty "${ORIGIN}"; then
      exitWithErrorCode ORIGIN_PARAMETER_IS_MANDATORY;
    else
      _input="${ORIGIN}";
    fi
  fi
  if ! fileExists "${_input}"; then
    exitWithErrorCode ORIGIN_DOES_NOT_EXIST "${_input}";
  fi
  if ! fileIsReadable "${_input}"; then
    exitWithErrorCode ORIGIN_IS_NOT_READABLE "${_input}";
  fi
}

function dw_parse_output_cli_parameter() {
  local _output="${1}";

  if isEmpty "${_output}"; then
    if isEmpty "${DESTINATION}"; then
      exitWithErrorCode DESTINATION_PARAMETER_IS_MANDATORY;
    else
      _output="${DESTINATION}";
    fi
  fi
  if ! fileIsWritable "${_output}"; then
    exitWithErrorCode DESTINATION_IS_NOT_READABLE "${_output}";
  fi
}
#
