#!/bin/bash dry-wit
# Copyright 2013-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-v[v]] [-q|--quiet] [-t|--tag tagName] [-T|--tutum] [repo]
$SCRIPT_NAME [-h|--help]
(c) 2014-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3
 
Builds Docker images from templates, similar to wking's. If no repo is specified, all repositories will be built.

Where:
  * repo: the repository image to build.
  * tag: the tag to use once the image is built successfully.
  * tutum: whether to push the image to tutum.co.
EOF
}

DOCKER=$(which docker.io 2> /dev/null || which docker 2> /dev/null)

# Requirements
function checkRequirements() {
  checkReq ${DOCKER} DOCKER_NOT_INSTALLED;
  checkReq date DATE_NOT_INSTALLED;
  checkReq realpath REALPATH_NOT_INSTALLED;
  checkReq envsubst ENVSUBST_NOT_INSTALLED;
}
 
# Error messages
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export DOCKER_NOT_INSTALLED="docker is not installed";
  export DATE_NOT_INSTALLED="date is not installed";
  export REALPATH_NOT_INSTALLED="realpath is not installed";
  export ENVSUBST_NOT_INSTALLED="envsubst is not installed";
  export NO_REPOSITORIES_FOUND="no repositories found";
  export INVALID_URL="Invalid command";
  export ERROR_BUILDING_REPO="Error building image";
  export ERROR_TAGGING_REPO="Error tagging image";
  export ERROR_PUSHING_IMAGE_TO_TUTUM="Error pushing image to tutum.co";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    DOCKER_NOT_INSTALLED \
    DATE_NOT_INSTALLED \
    REALPATH_NOT_INSTALLED \
    ENVSUBST_NOT_INSTALLED \
    NO_REPOSITORIES_FOUND \
    INVALID_URL \
    ERROR_BUILDING_REPO \
    ERROR_TAGGING_REPO \
    ERROR_PUSHING_IMAGE_TO_TUTUM \
  );

  export ERROR_MESSAGES;
}
 
# Checking input
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
      -t | --tag)
         shift;
	 TAG="${1}";
         shift;
	 ;;
      -T | --tutum)
         shift;
	 TUTUM=1;
         shift;
	 ;;
      *) exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done
 
  if [ "x${TAG}" == "x" ]; then
    TAG="${DATE}";
  fi

  # Parameters
  if [ "x${REPOS}" == "x" ]; then
    REPOS="$@";
    shift;
  fi

  if [ "x${REPOS}" == "x" ]; then
    REPO="$(find . -maxdepth 1 -type d | grep -v '^\.$' | sed 's \./  g' | grep -v '^\.')";
  fi

  if [ "x${REPOS}" == "x" ]; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode NO_REPOSITORIES_FOUND;
  else
    logDebugResult SUCCESS "valid";
  fi 
}

## Does "${NAMESPACE}/${REPO}:${TAG}" exist?
## Returns 0 (exists) or 1 (missing).
##
## Arguments:
##
## 1: REPO
function repo_exists() {
  local _repo="${1}";
  local _stack="${2}";
  local _images=$(${DOCKER} images "${NAMESPACE}/${_repo}${_stack}")
  local _matches=$(echo "${_images}" | grep "${TAG}")
  local _rescode;
  if [ -z "${MATCHES}" ]; then
    _rescode=1
  else
    _rescode=0
  fi

  return ${_rescode};
}

## Builds "${NAMESPACE}/${REPO}:${TAG}"
## Arguments:
##
## 1: REPO
function build_repo() {
  local _repo="${1}";
  local _stack="${2}";
  
  local _env="$( \
      for ((i = 0; i < ${#ENV_VARIABLES[*]}; i++)); do
        echo ${ENV_VARIABLES[$i]} | awk -v dollar="$" -v quote="\"" '{printf("echo  %s=\\\"%s%s{%s}%s\\\"", $0, quote, dollar, $0, quote);}' | sh; \
      done;) TAG=\"${TAG}\" DATE=\"${DATE}\" MAINTAINER=\"${AUTHOR} <${AUTHOR_EMAIL}>\" STACK=\"${STACK}\" REPO=\"${_repo}\"";

  local _envsubstDecl=$(echo -n "'"; echo -n "$"; echo -n "{TAG} $"; echo -n "{DATE} $"; echo -n "{MAINTAINER} $"; echo -n "{STACK} $"; echo -n "{REPO} "; echo ${ENV_VARIABLES[*]} | tr ' ' '\n' | awk '{printf("${%s} ", $0);}'; echo -n "'";);

  if [ $(ls ${_repo} | grep -e '\.template$' | wc -l) -gt 0 ]; then
    for f in ${_repo}/*.template; do
      echo "${_env} \
        envsubst \
          ${_envsubstDecl} \
      < ${f} > ${_repo}/$(basename ${f} .template)" | sh;
    done
  fi

  logInfo -n "Building ${NAMESPACE}/${_repo}${_stack}:${TAG}"
#  echo docker build ${BUILD_OPTS} -t "${NAMESPACE}/${_repo}${_stack}:${TAG}" --rm=true "${_repo}"
  docker build ${BUILD_OPTS} -t "${NAMESPACE}/${_repo}${_stack}:${TAG}" --rm=true "${_repo}"
  if [ $? -eq 0 ]; then
    logInfo -n "${NAMESPACE}/${_repo}${_stack}:${TAG}";
    logInfoResult SUCCESS "built"
  else
    logInfo -n "${NAMESPACE}/${_repo}${_stack}:${TAG}";
    logInfoResult FAILURE "not built"
    exitWithErrorCode ERROR_BUILDING_REPO "${_repo}";
  fi
  logInfo -n "Tagging ${NAMESPACE}/${_repo}${_stack}:latest"
  docker tag -f "${NAMESPACE}/${_repo}${_stack}:${TAG}" "${NAMESPACE}/${_repo}${_stack}:latest"
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "done"
  else
    logInfoResult FAILURE "failed"
    exitWithErrorCode ERROR_TAGGING_REPO "${_repo}";
  fi
}

function tutum_push() {
  local _repo="${1}";
  local _stack="${2}";
  logInfo -n "Tagging image for uploading to tutum.co";
  docker tag "${NAMESPACE}/${_repo}${_stack}:${TAG}" "tutum.co/${TUTUM_NAMESPACE}/${_repo}${_stack}:${TAG}";
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "done"
  else
    logInfoResult FAILURE "failed"
    exitWithErrorCode ERROR_TAGGING_REPO "${_repo}";
  fi
  logInfo -n "Pushing image to tutum";
  docker push "tutum.co/${TUTUM_NAMESPACE}/${_repo}${_stack}:${TAG}"
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "done"
  else
    logInfoResult FAILURE "failed"
    exitWithErrorCode ERROR_PUSHING_IMAGE "tutum.co/${TUTUM_NAMESPACE}/${_repo}${_stack}:${TAG}"
  fi
}

#echo $(dirname ${SCRIPT_NAME})
#echo $(basename ${SCRIPT_NAME})
[ -e "$(dirname ${SCRIPT_NAME})/$(basename ${SCRIPT_NAME} .sh).inc.sh" ] && source "$(dirname ${SCRIPT_NAME})/$(basename ${SCRIPT_NAME} .sh).inc.sh"

function main() {
  local _repo;
  local _stack="${STACK}";
  if [ "x${_stack}" != "x" ]; then
    _stack="_${_stack}";
  fi
  for _repo in ${REPOS}; do
    if ! repo_exists "${_repo}" "${_stack}"; then
      build_repo "${_repo}" "${_stack}"
      if [ "x${TUTUM}" == "x1" ]; then
        tutum_push "${_repo}" "${_stack}"
      fi
    fi
  done
}
