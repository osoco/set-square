#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-l|--local] localRepository branch
$SCRIPT_NAME [-r|--remote] remoteUrl branch
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Retrieves the latest version of a remote git repository, either cloned locally or using its URL.

Where:
  - localRepository: The folder of the repository.
  - remoteUrl: The remote URL.
  - branch: The branch name.
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
  addError "EITHER_LOCAL_OR_REMOTE_MUST_BE_SPECIFIED" "Either -l or -r must be specified"
  addError "LOCAL_REPOSITORY_IS_MANDATORY" "The local repository is mandatory";
  addError "LOCAL_REPOSITORY_DOES_NOT_EXIST" "The local repository ${LOCAL_REPOSITORY} does not exist";
  addError "CANNOT_RETRIEVE_HEAD_FROM_LOCAL_REPOSITORY" "Could not retrieve the HEAD hash of the remote ${BRANCH} branch in ${LOCAL_REPOSITORY}";
  addError "REMOTE_URL_IS_MANDATORY" "The remote URL is mandatory";
  addError "ERROR_ANALYZING_REMOTE_URL" "Error analyzing the remote URL ${REMOTE_URL}";
  addError 'CANNOT_RETRIEVE_HEAD_FROM_REMOTE_URL' "Could not retrieve the HEAD hash of the ${BRANCH} branch in ${REMOTE_URL}";
  addError "BRANCH_IS_MANDATORY" "The remote branch is mandatory";
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
      -h | --help | -v | -vv | -q | -l | --local | -r | --remote )
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

  if    isTrue "${LOCAL_FLAG}" \
     || isTrue "${REMOTE_FLAG}"; then
    if    isTrue "${LOCAL_FLAG}" \
       && isEmpty "${LOCAL_REPOSITORY}"; then
      logDebugResult FAILURE "failed";
      exitWithErrorCode LOCAL_REPOSITORY_IS_MANDATORY;
    fi

    if    isTrue "${REMOTE_FLAG}" \
       && isEmpty "${REMOTE_URL}"; then
      logDebugResult FAILURE "failed";
      exitWithErrorCode REMOTE_URL_IS_MANDATORY;
    fi
  else
    logDebugResult FAILURE "failed";
    exitWithErrorCode EITHER_LOCAL_OR_REMOTE_MUST_BE_SPECIFIED;
  fi

  if isEmpty "${BRANCH}"; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode BRANCH_IS_MANDATORY;
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
      -l | --local)
        shift;
        LOCAL_REPOSITORY="${1}";
        LOCAL_FLAG=${TRUE};
        shift;
        ;;
      -r | --remote)
        shift;
        REMOTE_URL="${1}";
        REMOTE_FLAG=${TRUE};
        shift;
        ;;
    esac
  done

  BRANCH="${1}";
  shift;
}

## Retrieves the hash of the HEAD of a certain remote branch in given local repository.
## -> 1: The repository folder.
## -> 2: The remote branch.
## <- 0/${TRUE} if the folder could be processed; 1/${FALSE} otherwise.
## <- RESULT: The hash.
## Examples:
##   if retrieveRemoteHeadFromLocalRepo "/tmp/my-Rep" "master"; then
##     echo "HEAD->${RESULT}"
##   fi
function retrieveRemoteHeadFromLocalRepo() {
  local repo="${1}";
  local _branch="${2}";
  local _result;
  local _rescode;

  pushd "${_repo}" > /dev/null 2>&1;
  _result=$(git ls-remote 2> /dev/null | grep "${_branch}" | awk '{print $1;}');
  _rescode=$?;
  if isTrue ${_rescode}; then
    export RESULT="${_result}";
  fi
  popd > /dev/null 2>&1
  return ${_rescode};
}

## Retrieves the hash of the HEAD for a certain branch in given remote URL.
## -> 1: The remote URL.
## -> 2: The remote branch.
## <- 0/${TRUE} if the URL could be processed; 1/${FALSE} otherwise.
## <- RESULT: The hash.
## Example:
##   if retrieveRemoteHeadFromURL "http://github.com/Ryder/set-square" "master"; then
##     echo "HEAD->${RESULT}";
##   fi
function retrieveRemoteHeadFromURL() {
  local _url="${1}";
  local _branch="${2}";
  local _result;
  local _rescode;

  _result="$(git ls-remote "${_url}" | grep "${_branch}" | head -n 1 | cut -f 1)";
  _rescode=$?;
  if isTrue ${_rescode}; then
    export RESULT="${_result}";
  fi
  return ${_rescode};
}

## Main logic
## dry-wit hook
function main() {
  local _result;
  local _hash;

  if isTrue "${LOCAL_FLAG}"; then
    logDebug -n "Retrieving HEAD for remote ${BRANCH} in ${LOCAL_REPOSITORY}";
    if retrieveRemoteHeadFromLocalRepo "${LOCAL_REPOSITORY}" "${BRANCH}"; then
        _hash="${RESULT}";
        logDebugResult SUCCESS "${_hash}";
    else
      logDebugResult FAILURE "failed";
      exitWithErrorCode CANNOT_RETRIEVE_HEAD_FROM_LOCAL_REPOSITORY;
    fi
  else
    logDebug -n "Retrieving HEAD for remote ${BRANCH} in ${REMOTE_URL}";
    if retrieveRemoteHeadFromURL "${REMOTE_URL}" "${BRANCH}"; then
      _hash="${RESULT}";
      logDebugResult SUCCESS "${_hash}";
    else
      logDebugResult FAILURE "failed";
      exitWithErrorCode CANNOT_RETRIEVE_HEAD_FROM_REMOTE_URL;
    fi
  fi
  echo "${_hash}";
}




