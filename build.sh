#!/bin/bash dry-wit
# Copyright 2013-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-t|--tag tagName] [-T|--tutum] [repo]
$SCRIPT_NAME [-h|--help]
(c) 2014-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3
 
Builds Docker images from templates, similar to wking's. If no repo is specified, all repositories will be built.

Where:
  * repo: the repository image to build.
  * tag: the tag to use once the image is built successfully.
  * tutum: whether to push the image to tutum.co.
Common flags:
    * -h | --help: Display this message.
    * -X:e | --X:eval-defaults: whether to eval all default values, which potentially slows down the script unnecessarily.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

DOCKER=$(which docker.io 2> /dev/null || which docker 2> /dev/null)

# Requirements
function checkRequirements() {
  checkReq ${DOCKER} DOCKER_NOT_INSTALLED;
  checkReq date DATE_NOT_INSTALLED;
  checkReq realpath REALPATH_NOT_INSTALLED;
  checkReq envsubst ENVSUBST_NOT_INSTALLED;
  checkReq head HEAD_NOT_INSTALLED;
  checkReq grep GREP_NOT_INSTALLED;
  checkReq awk AWK_NOT_INSTALLED;
}
 
# Error messages
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export DOCKER_NOT_INSTALLED="docker is not installed";
  export DATE_NOT_INSTALLED="date is not installed";
  export REALPATH_NOT_INSTALLED="realpath is not installed";
  export ENVSUBST_NOT_INSTALLED="envsubst is not installed";
  export HEAD_NOT_INSTALLED="head is not installed";
  export GREP_NOT_INSTALLED="grep is not installed";
  export AWK_NOT_INSTALLED="awk is not installed";
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
    HEAD_NOT_INSTALLED \
    GREP_NOT_INSTALLED \
    AWK_NOT_INSTALLED \
    NO_REPOSITORIES_FOUND \
    INVALID_URL \
    ERROR_BUILDING_REPO \
    ERROR_TAGGING_REPO \
    ERROR_PUSHING_IMAGE_TO_TUTUM \
  );

  export ERROR_MESSAGES;
}

# Parses the input
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
    esac
  done
 
  if [[ ! -n ${TAG} ]]; then
    TAG="${DATE}";
  fi

  # Parameters
  if [[ ! -n ${REPOS} ]]; then
    REPOS="$@";
    shift;
  fi

  if [[ ! -n ${REPOS} ]]; then
    REPOS="$(find . -maxdepth 1 -type d | grep -v '^\.$' | sed 's \./  g' | grep -v '^\.')";
  fi

  if [[ -n ${REPOS} ]]; then
      loadRepoEnvironmentVariables "${REPOS}";
      evalEnvVars;
  fi
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
      -h | --help | -v | -vv | -q | -X:e | --X:eval-defaults | -t | --tag | -T | --tutum)
	 ;;
      *) exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done
 
  if [[ ! -n ${REPOS} ]]; then
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

function build_repo_if_defined_locally() {
  local _repo="${1}";
  local _stack="${2}";
  if [[ -n ${_repo} ]] && \
     [[ -d ${_repo} ]] && \
     ! repo_exists "${_repo#${NAMESPACE}/}" "${_stack}"; then
    build_repo "${_repo}" "${_stack}"
  fi
}

## Builds "${NAMESPACE}/${REPO}:${TAG}"
## Arguments:
##
## 1: REPO
function build_repo() {
  local _repo="${1}";
  local _stack="${2}";
  local _stackSuffix;
  local _cmdResult;
  local _rootImage=;
  if is_32bit; then
    _rootImage="${ROOT_IMAGE_32BIT}:${ROOT_IMAGE_VERSION}";
  else
    _rootImage="${ROOT_IMAGE_64BIT}:${ROOT_IMAGE_VERSION}";
  fi
  if [[ -n ${STACK} ]]; then
    _stackSuffix="-${STACK}"
  else
    _stackSuffix=""
  fi
  local _env="$( \
      for ((i = 0; i < ${#ENV_VARIABLES[*]}; i++)); do
        echo ${ENV_VARIABLES[$i]} | awk -v dollar="$" -v quote="\"" '{printf("echo  %s=\\\"%s%s{%s}%s\\\"", $0, quote, dollar, $0, quote);}' | sh; \
      done;) TAG=\"${TAG}\" DATE=\"${DATE}\" MAINTAINER=\"${AUTHOR} <${AUTHOR_EMAIL}>\" STACK=\"${STACK}\" REPO=\"${_repo}\" ROOT_IMAGE=\"${_rootImage}\" BASE_IMAGE=\"${BASE_IMAGE}\" STACK_SUFFIX=\"${_stackSuffix}\" ";

  local _envsubstDecl=$(echo -n "'"; echo -n "$"; echo -n "{TAG} $"; echo -n "{DATE} $"; echo -n "{MAINTAINER} $"; echo -n "{STACK} $"; echo -n "{REPO} $"; echo -n "{ROOT_IMAGE} $"; echo -n "{BASE_IMAGE} $"; echo -n "{STACK_SUFFIX} "; echo ${ENV_VARIABLES[*]} | tr ' ' '\n' | awk '{printf("${%s} ", $0);}'; echo -n "'";);

  if [ $(ls ${_repo} | grep -e '\.template$' | wc -l) -gt 0 ]; then
    for f in ${_repo}/*.template; do
      echo "${_env} \
        envsubst \
          ${_envsubstDecl} \
      < ${f} > ${_repo}/$(basename ${f} .template)" | sh;
    done
  fi

  logInfo "Building ${NAMESPACE}/${_repo}${_stack}:${TAG}"
#  echo docker build ${BUILD_OPTS} -t "${NAMESPACE}/${_repo}${_stack}:${TAG}" --rm=true "${_repo}"
  docker build ${BUILD_OPTS} -t "${NAMESPACE}/${_repo}${_stack}:${TAG}" --rm=true "${_repo}"
  _cmdResult=$?
  logInfo -n "${NAMESPACE}/${_repo}${_stack}:${TAG}";
  if [ ${_cmdResult} -eq 0 ]; then
    logInfoResult SUCCESS "built"
  else
    logInfo -n "${NAMESPACE}/${_repo}${_stack}:${TAG}";
    logInfoResult FAILURE "not built"
    exitWithErrorCode ERROR_BUILDING_REPO "${_repo}";
  fi
  logInfo "Tagging ${NAMESPACE}/${_repo}${_stack}:latest"
  docker tag -f "${NAMESPACE}/${_repo}${_stack}:${TAG}" "${NAMESPACE}/${_repo}${_stack}:latest"
  _cmdResult=$?
  logInfo -n "${NAMESPACE}/${_repo}${_stack}:${TAG}";
  if [ ${_cmdResult} -eq 0 ]; then
    logInfoResult SUCCESS "tagged"
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

function is_32bit() {
  [ "$(uname -m)" == "i686" ]
}

function find_parent_repo() {
  local _repo="${1}"
  local _result=$(grep -e '^FROM ' ${_repo}/Dockerfile.template 2> /dev/null | head -n 1 | awk '{print $2;}' | awk -F':' '{print $1;}')
  if [[ -n ${_result} ]] && [[ "${_result#\$\{NAMESPACE\}/}" != "${_result}" ]]; then
    # parent under our namespace
    _result="${_result#\$\{NAMESPACE\}/}"
  fi
  if [[ -n ${_result} ]] && [[ ! -n ${_result#\$\{BASE_IMAGE\}} ]]; then
    _result=$(echo ${BASE_IMAGE} | awk -F'/' '{print $2;}')
  fi
  if [[ -n ${_result} ]] && [[ ! -n ${_result#\$\{ROOT_IMAGE\}} ]]; then
    _result=${ROOT_IMAGE}
  fi
   export RESULT="${_result}"
}

function find_parents() {
  local _repo="${1}"
  local _result=();
  declare -a _result;
  find_parent_repo "${_repo}"
  local _parent="${RESULT}"
  while [[ -n ${_parent} ]] && [[ "${_parent#.*/}" == "${_parent}" ]]; do
    _result[${#_result[@]}]="${_parent}"
    find_parent_repo "${_parent}"
    _parent="${RESULT}"
  done;
  export RESULT="${_result[@]}"
}

function resolve_base_image() {
  if is_32bit; then
    BASE_IMAGE=${BASE_IMAGE_32BIT}
  else
    BASE_IMAGE=${BASE_IMAGE_64BIT}
  fi
  export BASE_IMAGE
}

function loadRepoEnvironmentVariables() {
  local _repos="${1}";

  for _repo in ${_repos}; do
    for f in "${_repo}/build-settings.sh" "${_repo}/build-settings.sh-private"; do
      if [ -e "${f}" ]; then
        source "${f}";
      fi
    done
  done
}

function main() {
  local _repo;
  local _parents;
  local _stack="${STACK}";
  if [ "x${_stack}" != "x" ]; then
    _stack="_${_stack}";
  fi
  resolve_base_image
  for _repo in "${REPOS}"; do
    if ! repo_exists "${_repo}" "${_stack}"; then
      find_parents "${_repo}"
      _parents="${RESULT}"
      for _parent in ${_parents}; do
        build_repo_if_defined_locally "${_parent}" "" # stack is empty for parent images
      done
      build_repo "${_repo}" "${_stack}"
      if [ "x${TUTUM}" == "x1" ]; then
        tutum_push "${_repo}" "${_stack}"
      fi
    fi
  done
}
