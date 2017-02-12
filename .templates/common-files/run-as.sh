#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [[-u|--userId=userId|-U|--user=userName] [-g|--groupId=groupId]|-G|--group=groupName]? folder command [args]*
$SCRIPT_NAME [-h|--help]
(c) 2016-today ACM-SL
    Distributed this under the GNU General Public License v3.

Runs a command within given folder, under certain user/group.
If userId and groupId are omitted, those values are taken from the ownership information
of the folder parameter.

Where:
  * -u | --userId: The user id. Optional.
  * -U | --userName: The user name. Optional.
  * -g | --groupId: The group id. Optional.
  * -G | --groupName: The group name. Optional.
  * folder: the folder where the command will be run.
  * command: anything to run.
  * args: the command arguments.
Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Defines the errors.
## dry-wit hook
function defineErrors() {
  addError "INVALID_OPTION" "Unrecognized option";
  addError "NO_FOLDER_SPECIFIED" "No folder specified";
  addError "NO_COMMAND_SPECIFIED" "No command specified";
  addError "NO_RUN_AS_USER_SPECIFIED" "No RUN_AS_USER specified";
  addError "CANNOT_CHANGE_UID" "Cannot change the uid of ";
  addError "CANNOT_CHANGE_GID" 'Cannot change the gid of ';
  addError "CANNOT_RETRIEVE_USER_UID_OF_FOLDER" "Cannot retrieve the user uid of ";
  addError "CANNOT_RETRIEVE_GROUP_GID_OF_FOLDER" "Cannot retrieve the group gid of ";
  addError "USER_ID_IS_MANDATORY" "The user id is mandatory if the -u flag is provided";
  addError "USER_DOES_NOT_EXIST" "The user does not exist";
  addError "USER_NAME_IS_MANDATORY" "The user name is mandatory if the -U flag is provided";
  addError "INVALID_USER_NAME" "Invalid user name";
  addError "GROUP_ID_IS_MANDATORY" "The group id is mandatory if the -g flag is provided";
  addError "GROUP_NAME_IS_MANDATORY" "The group name is mandatory if the -G flag is provided";
  addError "GROUP_DOES_NOT_EXIST" "The group does not exist";
  addError "INVALID_GROUP_NAME" "Invalid group name";
}

## Validates the input.
## dry-wit hook
function checkInput() {

  local _uidSpecified=${FALSE};

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
      -u | --userId)
        shift;
        if isEmpty "${1}"; then
            logDebugResult FAILURE "failed";
            exitWithErrorCode USER_ID_IS_MANDATORY "${1}";
        fi
        if ! uidAlreadyExists "${1}"; then
            logDebugResult FAILURE "failed";
            exitWithErrorCode USER_DOES_NOT_EXIST "${1}";
        fi
        shift;
        _uidSpecified=${TRUE};
        ;;
      -U | --userName)
        shift;
        if isEmpty "${1}"; then
            logDebugResult FAILURE "failed";
            exitWithErrorCode USER_NAME_IS_MANDATORY "${1}";
        fi
        if ! userAlreadyExists "${1}"; then
            logDebugResult FAILURE "failed";
            exitWithErrorCode USER_DOES_NOT_EXIST "${1}";
        fi
        retrieveUidFromUser "${1}";
        if isEmpty "${RESULT}"; then
           logDebugResult FAILURE "failed";
           exitWithErrorCode INVALID_USER_NAME "${1}";
        fi
        shift;
        _uidSpecified=${TRUE};
        ;;
      -g | --groupId)
        shift;
        if isEmpty "${1}"; then
            logDebugResult FAILURE "failed";
            exitWithErrorCode GROUP_ID_IS_MANDATORY "${1}";
        fi
        if ! gidAlreadyExists "${1}"; then
            logDebugResult FAILURE "failed";
            exitWithErrorCode GROUP_DOES_NOT_EXIST "${1}";
        fi
        shift;
        ;;
      -G | --groupName)
        shift;
        if isEmpty "${1}"; then
            logDebugResult FAILURE "failed";
            exitWithErrorCode GROUP_NAME_IS_MANDATORY "${1}";
        fi
        if ! groupAlreadyExists "${1}"; then
            logDebugResult FAILURE "failed";
            exitWithErrorCode GROUP_DOES_NOT_EXIST "${1}";
        fi
        retrieveGidFromGroup "${1}";
        if isEmpty "${RESULT}"; then
            logDebugResult FAILURE "failed";
            exitWithErrorCode INVALID_GROUP_NAME "${1}";
        fi
        shift;
        ;;
      --) shift;
          break;
          ;;
      *) logDebugResult FAILURE "failed";
         exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done

  if isEmpty "${FOLDER}"; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode NO_FOLDER_SPECIFIED;
  fi

  if isEmpty "${COMMAND}"; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode NO_COMMAND_SPECIFIED;
  fi

  if isFalse ${_uidSpecified} && isEmpty "${RUN_AS_USER}"; then
      logDebugResult FAILURE "fail";
      exitWithErrorCode NO_RUN_AS_USER_SPECIFIED;
  else
    logDebugResult SUCCESS "valid";
  fi
}

## Parses the input.
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
      -u | --userId)
        shift;
        export USER_ID="${1}";
        shift;
        ;;
      -U | --userName)
        shift;
        retrieveUidFromUser "${1}";
        export USER_ID="${RESULT}";
        shift;
        ;;
      -g | --groupId)
        shift;
        export GROUP_ID="${1}";
        shift;
        ;;
      -G | --groupName)
        shift;
        retrieveGidFromGroup "${1}";
        export GROUP_ID="${RESULT}";
        shift;
        ;;
    esac
  done

  if isEmpty "${FOLDER}" ; then
    FOLDER="${1}";
    shift;
  fi

  if isEmpty "${COMMAND}"; then
    COMMAND="$1";
    shift;
  fi

  if isEmpty "${ARGS}"; then
    ARGS="$@";
  fi
}

## Updates given account.
## -> 1: The user name.
## -> 2: The new user id.
## -> 3: The new group id.
## Example:
##   update_service_user_account guest 1000 1000
function update_account() {
  local _user="${1}";
  local _tempGroup;
  local _deleteGroup=${FALSE};
  local _tempGroup;

  checkNotEmpty "user" "${_user}" 1;

  local _userId="${2}";
  checkNotEmpty "userId" "${_userId}" 2;

  local _groupId="${3}";
  checkNotEmpty "groupId" "${_groupId}" 3;

  if ! updateUserUid ${_user} ${_userId}; then
    exitWithErrorCode CANNOT_CHANGE_UID "${_user}";
  fi

  if ! gidAlreadyExists "${_groupId}"; then
    _tempGroup="temp$$";
    createGroup "${_tempGroup}" "${_groupId}";
    _deleteGroup=${TRUE};
  fi

  if ! updateUserGid "${_user}" ${_groupId}; then
    exitWithErrorCode CANNOT_CHANGE_GID "${_user} -> ${_groupId}";
  fi

  if isTrue ${_deleteGroup}; then
    deleteGroup "${_tempGroup}";
  fi
}

## Main logic
## dry-wit hook
function main() {
  local _uid="${USER_ID}";
  local _gid="${GROUP_ID}";
  local _restoreUid=${FALSE};
  local _uidUser;
  local _temporaryUser;
  local _temporaryUid;
  local _command;

  if isEmpty "${_uid}"; then
    retrieveOwnerUid "${FOLDER}";
    _uid="${RESULT}";
  fi
  if isEmpty "${_uid}"; then
    exitWithErrorCode CANNOT_RETRIEVE_USER_UID_OF_FOLDER "${FOLDER}";
  fi
  if isEmpty "${_gid}"; then
    retrieveOwnerGid "${FOLDER}";
    _gid="${RESULT}";
  fi
  if isEmpty "${_gid}"; then
    exitWithErrorCode CANNOT_RETRIEVE_GROUP_GID_OF_FOLDER "${FOLDER}";
  fi

  retrieveUidFromUser "${RUN_AS_USER}";
  _serviceUserId="${RESULT}";

  if uidAlreadyExists "${_uid}" && [ "${_uid}" != "${_serviceUserId}" ]; then
    _restoreUid=${TRUE};
    retrieveUserFromUid "${_uid}";
    _uidUser="${RESULT}";
    _temporaryUser="temp$$";
    createUser "${_temporaryUser}";
    retrieveUidFromUser "${_temporaryUser}";
    _temporaryUid="${RESULT}";
    deleteUser "${_temporaryUser}";
    update_account "${_uidUser}" "${_temporaryUid}" "${_gid}";
  fi

  update_account "${RUN_AS_USER}" "${_uid}" "${_gid}";

  resolveCommandForUser "${RUN_AS_USER}" "${COMMAND}";
  _command="${RESULT}";
  if isEmpty "${_command}"; then
     _command="${COMMAND}";
  fi

  runCommandAsUidGid "${_uid}" "${_gid}" "${FOLDER}" "${_command}" "${ARGS}";

  update_account "${RUN_AS_USER}" "${_serviceUserId}" "${_gid}";

  if isTrue ${_restoreUid}; then
    update_account "${_uidUser}" "${_uid}" "${_gid}";
  fi
}
