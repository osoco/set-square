#!/bin/bash dry-wit
# Copyright 2014-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-t|--tag tagName] [-f|--force] [-o|--overwrite-latest] [-p|--registry] [-r|--reduce-image] [repo]+
$SCRIPT_NAME [-h|--help]
(c) 2014-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3
 
Builds Docker images from templates, similar to wking's. If no repository (image folder) is specified, all repositories will be built.

Where:
  * repo: the repository to build (a folder with a Dockerfile template).
  * tag: the tag to use once the image is built successfully.
  * force: whether to build the image even if it's already built.
  * overwrite-latest: whether to overwrite the "latest" tag with the new one (default: false).
  * registry: optionally, the registry to push the image to.
  * reduce-image: whether to reduce the size of the resulting image.
  * stack-name: for stack images, the stack name (mandatory if the repository name ends with -stack).
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
  export DOCKER_SQUASH_NOT_INSTALLED="docker-squash is not installed. Check out https://github.com/jwilder/docker-squash for details";
  export NO_REPOSITORIES_FOUND="no repositories found";
  export REPO_IS_NOT_STACKED="Repository is not stacked (it should end with -stack)";
  export INVALID_URL="Invalid command";
  export CANNOT_PROCESS_TEMPLATE="Cannot process template";
  export INCLUDED_FILE_NOT_FOUND="The included file is missing";
  export ERROR_BUILDING_REPO="Error building repository";
  export ERROR_TAGGING_IMAGE="Error tagging image";
  export ERROR_PUSHING_IMAGE="Error pushing image to ${REGISTRY}";
  export ERROR_REDUCING_IMAGE="Error reducing the image size";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    DOCKER_NOT_INSTALLED \
    DATE_NOT_INSTALLED \
    REALPATH_NOT_INSTALLED \
    ENVSUBST_NOT_INSTALLED \
    HEAD_NOT_INSTALLED \
    GREP_NOT_INSTALLED \
    AWK_NOT_INSTALLED \
    DOCKER_SQUASH_NOT_INSTALLED \
    NO_REPOSITORIES_FOUND \
    REPO_IS_NOT_STACKED \
    INVALID_URL \
    CANNOT_PROCESS_TEMPLATE \
    INCLUDED_FILE_NOT_FOUND \
    ERROR_BUILDING_REPO \
    ERROR_TAGGING_IMAGE \
    ERROR_PUSHING_IMAGE \
    ERROR_REDUCING_IMAGE \
  );

  export ERROR_MESSAGES;
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
      -t | --tag)
         shift;
	       export TAG="${1}";
         shift;
	       ;;
      -p | --registry)
         shift;
	       export REGISTRY_PUSH=0;
	       ;;
      -f | --force)
          shift;
          export FORCE_MODE=0;
          ;;
      -o | --overwrite-latest)
          shift;
          export OVERWRITE_LATEST=0;
          ;;
      -r | --reduce-image)
          shift;
          export REDUCE_IMAGE=0;
          ;;
      -s | --stack)
          shift;
          export STACK="${1}";
          shift;
          ;;
    esac
  done
 
  if [[ ! -n ${TAG} ]]; then
    TAG="${DATE}";
  fi

  # Parameters
  if [[ -z ${REPOS} ]]; then
    REPOS="$@";
    shift;
  fi

  if [[ -z ${REPOS} ]]; then
    REPOS="$(find . -maxdepth 1 -type d | grep -v '^\.$' | sed 's \./  g' | grep -v '^\.')";
  fi

  if [[ -n ${REPOS} ]]; then
      loadRepoEnvironmentVariables "${REPOS}";
      evalEnvVars;
  fi
}

## Checking input
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
      -h | --help | -v | -vv | -q | -X:e | --X:eval-defaults | -o | --overwrite-latest)
        ;;
      -t | --tag | -p | --registry | -f | --force | -r | --reduce-image | -s | --stack)
	      ;;
      *) logDebugResult FAILURE "fail";
         exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done
 
  if [[ -z ${REPOS} ]]; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode NO_REPOSITORIES_FOUND;
  else
    if stack_image_enabled; then
      for _repo in ${REPOS}; do
        if ! is_stacked_repo "${_repo}"; then
          logDebugResult FAILURE "fail";
          exitWithErrorCode REPO_IS_NOT_STACKED;
        fi
      done
    fi
    logDebugResult SUCCESS "valid";
  fi 
}

## Checks whether the repository is part of a stack.
## Example:
##   if is_stacked_repo ${REPO}; then [..]; fi
function is_stacked_repo() {
  local _repo="${1}";
  local _result;
  if [ "x${_repo%%-stack}" == "x${_repo}" ]; then
      _result=1;
  else
      _result=0;
  fi
  return ${_result};
}

## Does "${NAMESPACE}/${REPO}:${TAG}" exist?
## -> 1: the repository.
## -> 2: the tag.
## -> 3: the stack (optional)
## <- 0 if it exists, 1 otherwise
## Example:
##   if repo_exists "myImage" "latest"; then [..]; fi
function repo_exists() {
  local _repo="${1}";
  local _tag="${2}";
  local _stack="${3}";
  local _stackSuffix;
  retrieve_stack_suffix "${_stack}";
  _stackSuffix="${RESULT}";

  local _images=$(${DOCKER} images "${NAMESPACE}/${_repo%%-stack}${_stackSuffix}")
  local _matches=$(echo "${_images}" | grep "${_tag}")
  local _rescode;
  if [ -z "${_matches}" ]; then
    _rescode=1
  else
    _rescode=0
  fi

  return ${_rescode};
}

## Returns the suffix to use should the image is part of
## a stack, and leaving it empty if not.
## -> 1: stack (optional).
## <- RESULT: "_${stack}" if stack is not empty, the empty string otherwise.
## Example:
##   retrieve_stack_suffix "examplecom"
##   stackSuffix="${RESULT}"
function retrieve_stack_suffix() {
  local _stack="${1}";
  local _result;
  if [[ -n ${_stack} ]]; then
    _result="-${_stack}"
  else
    _result=""
  fi
  export RESULT="${_result}";
}

## Builds the image if it's defined locally.
## -> 1: the repository.
## -> 2: the tag.
## -> 3: the stack (optional).
## Example:
##   build_repo_if_defined_locally "myImage" "latest";
function build_repo_if_defined_locally() {
  local _repo="${1}";
  local _tag="${2}";
  local _stack="${3}";
  if [[ -n ${_repo} ]] && \
     [[ -d ${_repo} ]] && \
     ! repo_exists "${_repo#${NAMESPACE}/}" "${_tag}" "${_stack}" ; then
    build_repo "${_repo}" "${_tag}" "${_stack}"
  fi
}

## Squashes the image with docker-squash [1]
## [1] https://github.com/jwilder/docker-squash
## -> 1: the current tag
## -> 2: the new tag for the squashed image
## -> 3: the namespace
## -> 4: the repo name
## Example:
##   reduce_image_size "namespace" "myimage" "201508-raw" "201508"
function reduce_image_size() {
  local _namespace="${1}";
  local _repo="${2}";
  local _currentTag="${3}";
  local _tag="${4}";
  checkReq docker-squash DOCKER_SQUASH_NOT_INSTALLED;
  logInfo -n "Squashing ${_image} as ${_namespace}/${_repo}:${_tag}"
  ${DOCKER} save "${_namespace}/${_repo}:${_currentTag}" | sudo docker-squash -t "${_namespace}/${_repo}:${_tag}" | ${DOCKER} load
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "done"
  else
    logInfoResult FAILURE "failed"
    exitWithErrorCode ERROR_REDUCING_IMAGE "${_namespace}/${_repo}:${_currentTag}";
  fi
}

## Processes given file.
## -> 1: the input file.
## -> 2: the output file.
## -> 3: the repo folder.
## -> 4: the templates folder.
## <- 0: if the file is processed correctly; 1 otherwise.
## Example:
##  if process_file "my.template" "my" "my-image-folder" ".templates"; then
##    echo "File processed successfully";
##  fi
function process_file() {
  local _file="${1}";
  local _output="${2}";
  local _repoFolder="${3}";
  local _templateFolder="${4}";
  local _rescode=1;
  createTempFile;
  local _temp1="${RESULT}";
  logTrace -n "Resolving @include()s in ${_file}";
  if resolve_includes "${_file}" "${_temp1}" "${_repoFolder}" "${_templateFolder}"; then
    logTraceResult SUCCESS "done";
    logTrace -n "Resolving placeholders in ${_file}";
    if process_placeholders "${_temp1}" "${_output}"; then
      _rescode=0;
      logTraceResult SUCCESS "done";
    else
      _rescode=1;
      logTraceResult FAILURE "failed";
    fi
  else
    _rescode=1;
    logTraceResult FAILURE "failed";
  fi
  return ${_rescode};
}

## Resolves given included file.
## -> 1: The file name.
## -> 2: The templates folder.
## -> 3: The repository's own folder.
## <- 0: if the file is found; 1 otherwise.
## Example:
##   if ! resolve_included_file "footer" "my-image-folder" ".templates"; then
##     echo "'footer' not found";
##   fi
function resolve_included_file() {
  local _file="${1}";
  local _repoFolder="${2}";
  local _templatesFolder="${3}";
  local _result;
  local _rescode=1;
  for d in "${_repoFolder}" "." "${_templatesFolder}"; do
    echo "Checking ${d}/${_file}" >> /tmp/log.txt;
    if    [[ -e "${d}/${_file}" ]] \
       || [[ -e "${d}/$(basename ${_file} .template).template" ]]; then
      echo "${d}/${_file} found!" >> /tmp/log.txt;
      _result="${d}/${_file}";
      export RESULT="${_result}";
      _rescode=0;
      break;
    fi
  done
  if isFalse ${_rescode}; then
    eval "echo ${_file}" > /dev/null 2>&1;
    if isTrue $?; then
      resolve_included_file "$(eval "echo ${_file}")" "${_repoFolder}" "${_templatesFolder}";
      _rescode=$?;
    fi
  fi
  echo "${_file} resolved -> ${_rescode}" >> /tmp/log.txt;
  return ${_rescode};
}

## Resolves any @include in given file.
## -> 1: the input file.
## -> 2: the output file.
## -> 4: the repository folder.
## -> 3: the templates folder.
## <- 0: if the @include()s are resolved successfully; 1 otherwise.
## Example:
##  resolve_includes "my.template" "my" "my-image-folder" ".templates"
function resolve_includes() {
  local _input="${1}";
  local _output="${2}";
  local _repoFolder="${3}";
  local _templateFolder="${4}";
  local _rescode;
  local _match;
  local _includedFile;

  echo '' > "${_output}";

  while IFS='' read -r line; do
    _match=1;
    _includedFile="";
    if    [[ "${line#@include(\"}" != "$line" ]] \
       && [[ "${line%\")}" != "$line" ]]; then
      _ref="$(echo "$line" | sed 's/@include(\"\(.*\)\")/\1/g')";
      if resolve_included_file "${_ref}" "${_repoFolder}" "${_templateFolder}"; then
        _includedFile="${RESULT}";
        if [ -e "${_includedFile}.template" ]; then
          if process_file "${_includedFile}.template" "${_includedFile}" "${_repoFolder}" "${_templateFolder}"; then
            _match=0;
          else
            _match=1;
            logDebugResult FAILURE "failed";
            exitWithErrorCode CANNOT_PROCESS_TEMPLATE "${_includedFile}";
          fi
        else
          _match=0;
        fi
      else
        _match=1;
        _errorRef="${_ref}";
        eval "echo ${_ref}" > /dev/null 2>&1;
        if [ $? -eq 0 ]; then
          _errorRef="${_input} contains ${_ref} with evaluates to $(eval "echo ${_ref}" 2> /dev/null), and it's not found in any of the expected paths: ${_repoFolder}, ${_templateFolder}";
        fi
      fi
    fi
    if [[ ${_match} -eq 0 ]]; then
      cat "${_includedFile}" >> "${_output}";
    else
      echo "$line" >> "${_output}";
    fi
  done < "${_input}";
  _rescode=$?;
  if [ "${_errorRef}" != "" ]; then
    logDebugResult FAILURE "failed";
    exitWithErrorCode INCLUDED_FILE_NOT_FOUND "${_errorRef}";
  fi
  return ${_rescode};
}

## Processes placeholders in given file.
## -> 1: the input file.
## -> 2: the output file.
## <- 0 if the file was processed successfully; 1 otherwise.
## Example:
##  if process_placeholders my.template" "my"; then
##    echo "my.template -> my";
##  fi
function process_placeholders() {
  local _file="${1}";
  local _output="${2}";
  local _rescode;
  local _env="$( \
    for ((i = 0; i < ${#ENV_VARIABLES[*]}; i++)); do \
      echo ${ENV_VARIABLES[$i]} | awk -v dollar="$" -v quote="\"" '{printf("echo  %s=\\\"%s%s{%s}%s\\\"", $0, quote, dollar, $0, quote);}' | sh; \
    done;) TAG=\"${_canonicalTag}\" DATE=\"${DATE}\" TIME=\"${TIME}\" MAINTAINER=\"${AUTHOR} <${AUTHOR_EMAIL}>\" STACK=\"${STACK}\" REPO=\"${_repo}\" IMAGE=\"${_repo}\" ROOT_IMAGE=\"${_rootImage}\" BASE_IMAGE=\"${BASE_IMAGE}\" STACK_SUFFIX=\"${_stackSuffix}\" DOLLAR='$' ";

  local _envsubstDecl=$(echo -n "'"; echo -n "$"; echo -n "{TAG} $"; echo -n "{DATE} $"; echo -n "{MAINTAINER} $"; echo -n "{STACK} $"; echo -n "{REPO} $"; echo -n "{IMAGE} $"; echo -n "{ROOT_IMAGE} $"; echo -n "{BASE_IMAGE} $"; echo -n "{STACK_SUFFIX} $"; echo -n "{DOLLAR}"; echo ${ENV_VARIABLES[*]} | tr ' ' '\n' | awk '{printf("${%s} ", $0);}'; echo -n "'";);

  echo "${_env} envsubst ${_envsubstDecl} < ${_file}" | sh > "${_output}";
  _rescode=$?;
  return ${_rescode};
}

## Updates the log category to include the current image.
## -> 1: the image.
## Example:
##   update_log_category "mysql"
function update_log_category() {
  local _image="${1}";
  local _logCategory;
  getLogCategory;
  _logCategory="${RESULT%/*}/${_image}";
  setLogCategory "${_logCategory}";
}

## Builds "${NAMESPACE}/${REPO}:${TAG}" image.
## -> 1: the repository.
## -> 2: the tag.
## -> 3: the stack (optional).
## Example:
##  build_repo "myImage" "latest" "";
function build_repo() {
  local _repo="${1}";
  local _canonicalTag="${2}";
  if reduce_image_enabled; then
    _rawTag="${2}-raw";
    _tag="${_rawTag}";
  else
    _tag="${_canonicalTag}";
  fi
  local _stack="${3}";
  local _stackSuffix;
  local _cmdResult;
  local _rootImage=;
  if is_32bit; then
    _rootImage="${ROOT_IMAGE_32BIT}:${ROOT_IMAGE_VERSION}";
  else
    _rootImage="${ROOT_IMAGE_64BIT}:${ROOT_IMAGE_VERSION}";
  fi
  update_log_category "${_repo}";
  retrieve_stack_suffix "${STACK}";
  _stackSuffix="${RESULT}";

  if [ $(ls ${_repo} | grep -e '\.template$' | wc -l) -gt 0 ]; then
    for f in ${_repo}/*.template; do
      if ! process_file "${f}" "${_repo}/$(basename ${f} .template)" "${_repo}" "${INCLUDES_FOLDER}"; then
        exitWithErrorCode  CANNOT_PROCESS_TEMPLATE "${f}";
      fi
    done
  fi

  logInfo "Building ${NAMESPACE}/${_repo%%-stack}${_stack}:${_tag}"
#  echo docker build ${BUILD_OPTS} -t "${NAMESPACE}/${_repo%%-stack}${_stack}:${_tag}" --rm=true "${_repo}"
  docker build ${BUILD_OPTS} -t "${NAMESPACE}/${_repo%%-stack}${_stack}:${_tag}" --rm=true "${_repo}"
  _cmdResult=$?
  logInfo -n "${NAMESPACE}/${_repo%%-stack}${_stack}:${_tag}";
  if [ ${_cmdResult} -eq 0 ]; then
    logInfoResult SUCCESS "built"
  else
    logInfo -n "${NAMESPACE}/${_repo%%-stack}${_stack}:${_tag}";
    logInfoResult FAILURE "not built"
    exitWithErrorCode ERROR_BUILDING_REPO "${_repo}";
  fi
  if reduce_image_enabled; then
    reduce_image_size "${NAMESPACE}" "${_repo%%-stack}${_stack}" "${_tag}" "${_canonicalTag}";
  fi
  if overwrite_latest_enabled; then
    logInfo -n "Tagging ${NAMESPACE}/${_repo%%-stack}${_stack}:${_canonicalTag} as ${NAMESPACE}/${_repo%%-stack}${_stack}:latest"
    docker tag -f "${NAMESPACE}/${_repo%%-stack}${_stack}:${_canonicalTag}" "${NAMESPACE}/${_repo%%-stack}${_stack}:latest"
    if [ $? -eq 0 ]; then
      logInfoResult SUCCESS "${NAMESPACE}/${_repo%%-stack}${_stack}:latest";
    else
      logInfoResult FAILURE "failed"
      exitWithErrorCode ERROR_TAGGING_IMAGE "${_repo%%-stack}${_stack}";
    fi
  fi
}

## Pushes the image to a Docker registry.
## -> 1: the repository.
## -> 2: the tag.
## -> 3: the stack (optional).
## Example:
##   registry_push "myImage" "latest"
function registry_push() {
  local _repo="${1}";
  local _tag="${2}";
  local _stack="${3}";
  local _stackSuffix;
  local _pushResult;
  update_log_category "${_repo}";
  retrieve_stack_suffix "${_stack}";
  _stackSuffix="${RESULT}";
  logInfo -n "Tagging ${NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag} for uploading to ${REGISTRY}";
  docker tag -f "${NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag}" "${REGISTRY}/${REGISTRY_NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag}";
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "done"
  else
    logInfoResult FAILURE "failed"
    exitWithErrorCode ERROR_TAGGING_IMAGE "${_repo}";
  fi
  logInfo "Pushing ${NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag} to ${REGISTRY}";
  docker push "${REGISTRY}/${REGISTRY_NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag}"
  _pushResult=$?;
  logInfo "Pushing ${NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag} to ${REGISTRY}";
  if [ ${_pushResult} -eq 0 ]; then
    logInfoResult SUCCESS "done"
  else
    logInfoResult FAILURE "failed"
    exitWithErrorCode ERROR_PUSHING_IMAGE "${REGISTRY}/${REGISTRY_NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag}"
  fi
}

## Finds out if the architecture is 32 bits.
## <- 0 if 32b, 1 otherwise.
## Example:
##   if is_32bit; then [..]; fi
function is_32bit() {
  [ "$(uname -m)" == "i686" ]
}

## Finds the parent image for a given repo.
## -> 1: the repository.
## <- RESULT: the parent, if any.
## Example:
##   find_parent_repo "myImage"
##   parent="${RESULT}"
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

## Recursively finds all parents for a given repo.
## -> 1: the repository.
## <- RESULT: a space-separated list with the parent images.
## Example:
##   find_parents "myImage"
##   parents="${RESULT}"
##   for p in ${parents}; do [..]; done
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

## Resolves which base image should be used,
## depending on the architecture.
## Example:
##   resolve_base_image;
##   echo "the base image is ${BASE_IMAGE}"
function resolve_base_image() {
  if is_32bit; then
    BASE_IMAGE=${BASE_IMAGE_32BIT}
  else
    BASE_IMAGE=${BASE_IMAGE_64BIT}
  fi
  export BASE_IMAGE
}

## Loads image-specific environment variables,
## sourcing the build-settings.sh and .build-settings.sh files
## in the repo folder, if they exist.
## -> 1: The repository.
## Example:
##   echo 'defineEnvVar MY_VAR "My variable" "default value"' > myImage/build-settings.sh
##   loadRepoEnvironmentVariables "myImage"
##   echo "MY_VAR is ${MY_VAR}"
function loadRepoEnvironmentVariables() {
  local _repos="${1}";

  for _repo in ${_repos}; do
    for f in "${DRY_WIT_SCRIPT_FOLDER}/${_repo}/build-settings.sh" \
             "./${_repo}/build-settings.sh" \
             "${DRY_WIT_SCRIPT_FOLDER}/${_repo}/.build-settings.sh" \
             "${_repo}/.build-settings.sh"; do
      if [ -e "${f}" ]; then
        source "${f}";
      fi
    done
  done
}

## Checks whether the -f flag is enabled
## Example:
##   if force_mode_enabled; then [..]; fi
function force_mode_enabled() {
  _flagEnabled FORCE_MODE;
}

## Checks whether the -o flag is enabled
## Example:
##   if overwrite_latest_enabled; then [..]; fi
function overwrite_latest_enabled() {
  _flagEnabled OVERWRITE_LATEST;
}

## Checks whether the -p flag is enabled
## Example:
##   if registry_push_enabled; then [..]; fi
function registry_push_enabled() {
  _flagEnabled REGISTRY_PUSH;
}

## Checks whether the -r flag is enabled
## Example:
##   if reduce_image_enabled; then [..]; fi
function reduce_image_enabled() {
  _flagEnabled REDUCE_IMAGE;
}

## Checks whether the -s flag is enabled
## Example:
##   if stack_image_enabled; then [..]; fi
function stack_image_enabled() {
  _flagEnabled STACK;
}

## Cleans up the docker containers
## Example:
##   cleanup_containers
function cleanup_containers() {
  local _count="$(${DOCKER} ps -a -q | xargs -n 1 -I {} | wc -l)";
  #  _count=$((_count-1));
  if [ ${_count} -gt 0 ]; then
    logInfo -n "Cleaning up ${_count} stale container(s)";
    ${DOCKER} ps -a -q | xargs -n 1 -I {} sudo docker rm {} > /dev/null;
    if [ $? -eq 0 ]; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILED "failed";
    fi
  fi
}

## Cleans up unused docker images
## Example:
##   cleanup_images
function cleanup_images() {
  local _count="$(${DOCKER} images | grep '<none>' | wc -l)";
  if [ ${_count} -gt 0 ]; then
    logInfo -n "Trying to delete up to ${_count} unnamed image(s)";
    ${DOCKER} images | grep '<none>' | awk '{printf("docker rmi -f %s\n", $3);}' | sh > /dev/null
    if [ $? -eq 0 ]; then
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILED "failed";
    fi
  fi
}

# Main logic
function main() {
  local _repo;
  local _parents;
  local _stack="${STACK}";
  local _buildRepo=1;
  if [ "x${_stack}" != "x" ]; then
    _stack="_${_stack}";
  fi
  resolve_base_image
  for _repo in ${REPOS}; do
    _buildRepo=1;
    if force_mode_enabled; then
      _buildRepo=0;
    elif ! repo_exists "${_repo}" "${TAG}" "${_stack}"; then
      _buildRepo=0;
    else
      logInfo -n "Not building ${NAMESPACE}/${_repo}:${TAG} since it's already built";
      logInfoResult SUCCESS "skipped";
    fi
    if [ ${_buildRepo} -eq 0 ]; then
      find_parents "${_repo}"
      _parents="${RESULT}"
      for _parent in ${_parents}; do
        build_repo_if_defined_locally "${_parent}" "${TAG}" "" # stack is empty for parent images
      done

      build_repo "${_repo}" "${TAG}" "${_stack}"
    fi
    if registry_push_enabled; then
      registry_push "${_repo}" "${TAG}" "${_stack}"
      if overwrite_latest_enabled; then
        registry_push "${_repo}" "latest" "${_stack}"
      fi
    fi
  done
  cleanup_containers;
  cleanup_images;
}
