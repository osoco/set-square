#!/bin/bash dry-wit
# Copyright 2014-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

#set -o xtrace

function usage() {
cat <<EOF
$SCRIPT_NAME [-t|--tag tagName] [-f|--force] [-o|--overwrite-latest] [-p|--registry] [-r|--reduce-image] [-ci|--cleanup-images] [-cc|--cleanup-containers] [repo]+
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
  * cleanup-images: Whether to try to cleanup images.
  * cleanup-containers: Whether to try to cleanup containers.
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
function defineRequirements() {
  checkReq $(basename ${DOCKER:-docker});
  checkReq date;
  checkReq realpath;
  checkReq envsubst;
  checkReq head;
  checkReq grep;
  checkReq awk;
}

# Error messages
function defineErrors() {
  addError "INVALID_OPTION" "Unknown option";
  addError "DOCKER_NOT_INSTALLED" "docker is not installed";
  addError "DATE_NOT_INSTALLED" "date is not installed";
  addError "REALPATH_NOT_INSTALLED" "realpath is not installed";
  addError "ENVSUBST_NOT_INSTALLED" "envsubst is not installed";
  addError "HEAD_NOT_INSTALLED" "head is not installed";
  addError "GREP_NOT_INSTALLED" "grep is not installed";
  addError "AWK_NOT_INSTALLED" "awk is not installed";
  addError "DOCKER_SQUASH_NOT_INSTALLED" "docker-squash is not installed. Check out https://github.com/jwilder/docker-squash for details";
  addError "NO_REPOSITORIES_FOUND" "no repositories found";
  addError "REPO_DOES_NOT_EXIST" "Repository does not exist";
  addError "REPO_IS_NOT_A_FOLDER" "Repository is not a folder";
  addError "REPO_IS_NOT_STACKED" "Repository is not stacked (it should end with -stack)";
  addError "CANNOT_PROCESS_TEMPLATE" "Cannot process template";
  addError "INCLUDED_FILE_NOT_FOUND" "The included file is missing";
  addError "ERROR_BUILDING_REPO" "Error building repository";
  addError "ERROR_TAGGING_IMAGE" "Error tagging image";
  addError "ERROR_PUSHING_IMAGE" "Error pushing image to ${REGISTRY}";
  addError "ERROR_REDUCING_IMAGE" "Error reducing the image size";
  addError "CANNOT_COPY_LICENSE_FILE" "Cannot copy the license file ${LICENSE_FILE}";
  addError "LICENSE_FILE_DOES_NOT_EXIST" "The specified license ${LICENSE_FILE} does not exist";
  addError "CANNOT_COPY_COPYRIGHT_PREAMBLE_FILE" "Cannot copy the copyright-preamble file ${COPYRIGHT_PREAMBLE_FILE}";
  addError "COPYRIGHT_PREAMBLE_FILE_DOES_NOT_EXIST" "The specified copyright-preamble file ${COPYRIGHT_PREAMBLE_FILE} does not exist";
}

## Parses the input
## dry-wit hook
function parseInput() {

  local _flags=$(extractFlags $@);
  local _flagCount=0;
  local _currentCount;
  local _help=${FALSE};

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help)
        _help=${TRUE};
        shift;
        ;;
      -v | -vv | -q | -X:e | --X:eval-defaults)
        shift;
        ;;
      -t | --tag)
        shift;
	      export TAG="${1}";
        shift;
	      ;;
      -p | --registry)
        shift;
	      export REGISTRY_PUSH=TRUE;
	      ;;
      -f | --force)
        shift;
        export FORCE_MODE=TRUE;
        ;;
      -o | --overwrite-latest)
        shift;
        export OVERWRITE_LATEST=TRUE;
        ;;
      -r | --reduce-image)
        shift;
        export REDUCE_IMAGE=TRUE;
        ;;
      -s | --stack)
        shift;
        export STACK="${1}";
        shift;
        ;;
      -ci | --cleanup-images)
        shift;
        export CLEAUP_IMAGES=TRUE;
        ;;
      -cc | --cleanup-containers)
        shift;
        export CLEAUP_CONTAINERS=TRUE;
        ;;
      --)
        shift;
        break;
        ;;
    esac
  done

  if isEmpty "${TAG}"; then
    TAG="${DATE:-$(date '+%Y%m')}";
  fi

  # Parameters
  if isEmpty "${REPOS}"; then
    REPOS="$@";
    shift;
  fi

  if isEmpty "${REPOS}"; then
    REPOS="$(find . -maxdepth 1 -type d | grep -v '^\.$' | sed 's \./  g' | grep -v '^\.')";
  fi

  if ! isTrue ${_help} && ! isEmpty ${REPOS}; then
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
  local _oldIfs;

  logDebug -n "Checking input";

  # Flags
  for _flag in ${_flags}; do
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q | -X:e | --X:eval-defaults | -o | --overwrite-latest)
        ;;
      -t | --tag | -p | --registry | -f | --force | -r | --reduce-image | -s | --stack)
	      ;;
      --)
        break;
        ;;
      *) logDebugResult FAILURE "fail";
         exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done

  if isEmpty "${REPOS}"; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode NO_REPOSITORIES_FOUND;
  else
    _oldIfs="${IFS}";
    IFS=$'\t\n';
    for _repo in ${REPOS}; do
      IFS="${_oldIfs}";
      if [ ! -e "${_repo}" ]; then
          logDebugResult FAILURE "fail";
          exitWithErrorCode REPO_DOES_NOT_EXIST "${_repo}";
      elif [ ! -d "${_repo}" ]; then
        logDebugResult FAILURE "fail";
        exitWithErrorCode REPO_IS_NOT_A_DIRECTORY "${_repo}";
      fi
    done

    if stack_image_enabled; then
      IFS=$'\t\n';
      for _repo in ${REPOS}; do
        IFS="${_oldIfs}";
        if ! is_stacked_repo "${_repo}"; then
          logDebugResult FAILURE "fail";
          exitWithErrorCode REPO_IS_NOT_STACKED;
        fi
      done
    fi
  fi

#  if isEmpty "${INCLUDES_FOLDER}"; then
#    logDebugResult FAILURE "fail";
#    exitWithErrorCode INCLUDES_FOLDER_IS_NOT_DEFINED;
#  elif [ ! -e "${INCLUDES_FOLDER}" ]; then
#    logDebugResult FAILURE "fail";
#    exitWithErrorCode INCLUDES_FOLDER_DOES_NOT_EXIST "${INCLUDES_FOLDER}";
#  fi

  logDebugResult SUCCESS "valid";
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

  local _images=$(${DOCKER} ${DOCKER_OPTS} images "${NAMESPACE}/${_repo%%-stack}${_stackSuffix}")
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
  ${DOCKER} ${DOCKER_OPTS} save "${_namespace}/${_repo}:${_currentTag}" | sudo docker-squash -t "${_namespace}/${_repo}:${_tag}" | ${DOCKER} ${DOCKER_OPTS} load
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
## -> 5: the image.
## -> 6: the root image.
## -> 7: the namespace.
## -> 8: the tag.
## -> 9: the stack suffix.
## -> 10: the backup host's SSH port (optional).
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
  local _repo="${5}";
  local _rootImage="${6}";
  local _namespace="${7}";
  local _tag="${8}";
  local _stackSuffix="${9}";
  local _backupHostSshPort="${10:-22}";
  local _rescode=1;
  createTempFile;
  local _temp1="${RESULT}";
  createTempFile;
  local _temp2="${RESULT}";

  if isEmpty "${_file}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'file' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_output}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'output' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_repoFolder}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'repoFolder' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_templateFolder}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'templateFolder' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_repo}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'repo' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_rootImage}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'rootImage' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_namespace}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'namespace' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_tag}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'tag' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  fi

  if resolve_includes "${_file}" "${_temp1}" "${_repoFolder}" "${_templateFolder}" "${_repo}" "${_rootImage}" "${_namespace}" "${_tag}" "${_stackSuffix}" "${_backupHostSshPort}"; then
    logTrace -n "Resolving @include_env in ${_file}";
    if resolve_include_env "${_temp1}" "${_temp2}" "${_repo}" "${_rootImage}" "${_namespace}" "${_tag}" "${_stackSuffix}" "${_backupHostSshPort}"; then
      logTraceResult SUCCESS "done";
      logTrace -n "Resolving placeholders in ${_file}";
      if process_placeholders "${_temp2}" "${_output}" "${_repo}" "${_rootImage}" "${_namespace}" "${_tag}" "${_stackSuffix}" "${_backupHostSshPort}"; then
        _rescode=${TRUE};
        logTraceResult SUCCESS "done"
      else
        _rescode=${FALSE};
        logTraceResult FAILURE "failed";
      fi
    else
      _rescode=${FALSE};
      logTraceResult FAILURE "failed";
    fi
  else
    _rescode=${FALSE};
  fi

  return ${_rescode};
}

## Resolves given included file.
## -> 1: The file name.
## -> 2: The repository's own folder.
## -> 3: The templates folder.
## <- 0/${TRUE}: if the file is found; 1/${FALSE} otherwise.
## Example:
##   if ! resolve_included_file "footer" "my-image-folder" ".templates"; then
##     echo "'footer' not found";
##   fi
function resolve_included_file() {
  local _file="${1}";
  local _repoFolder="${2}";
  local _templatesFolder="${3}";
  local _result;
  local _rescode=${FALSE};
  local _fileAux;

  if isEmpty "${_repoFolder}"; then
      exitWithErrorCode UNACCEPTABLE_API_CALL "'file' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_repoFolder}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'repoFolder' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_templatesFolder}"; then
      exitWithErrorCode UNACCEPTABLE_API_CALL "'templatesFolder' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  fi

  for d in "${_templatesFolder}" "${_repoFolder}" "."; do
    if    [[ -f "${d}/${_file}" ]] \
       || [[ -f "${d}/$(basename ${_file} .template).template" ]]; then
      _result="${d}/${_file}";
      export RESULT="${_result}";
      _rescode=${TRUE};
      break;
    fi
  done
  if isFalse ${_rescode}; then
    _fileAux=$(eval "echo ${_file}");
    if    isTrue $? \
       && isNotEmpty "${_fileAux}"; then
      resolve_included_file "${_fileAux}" "${_repoFolder}" "${_templatesFolder}";
      _rescode=$?;
    fi
  fi

  return ${_rescode};
}

## Resolves any @include in given file.
## -> 1: the input file.
## -> 2: the output file.
## -> 3: the templates folder.
## -> 4: the repository folder.
## -> 5: the image.
## -> 6: the root image.
## -> 7: the namespace.
## -> 8: the tag.
## -> 9: the stack suffix.
## -> 10: the backup host's SSH port for this image (optional).
## <- 0: if the @include()s are resolved successfully; 1 otherwise.
## Example:
##  resolve_includes "my.template" "my" "my-image-folder" ".templates" "myImage" "myRoot" "example" "latest" "" "22"
function resolve_includes() {
  local _input="${1}";
  local _output="${2}";
  local _repoFolder="${3}";
  local _templateFolder="${4}";
  local _repo="${5}";
  local _rootImage="${6}";
  local _namespace="${7}";
  local _tag="${8}";
  local _stackSuffix="${9}";
  local _backupHostSshPort="${10:-22}";
  local _rescode;
  local _match;
  local _includedFile;
  local _includedFolder;
  local _includedFileBundle;
  local _includedFileBundleName;
  local _includedFileBundleSettings;
  local line;

  if isEmpty "${_input}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'input' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif [ ! -e "${_input}" ]; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'input' \"${_input}\" does not exist, and it's mandatory for ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_output}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'output' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_repoFolder}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'repoFolder' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif [ ! -e "${_repoFolder}" ]; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'repoFolder' \"${_repoFolder}\" does not exist, and it's mandatory for ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_templateFolder}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'templateFolder' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif [ ! -e "${_templateFolder}" ]; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'templateFolder' \"${_templateFolder}\" does not exist, and it's mandatory for ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_repo}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'repo' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_rootImage}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'rootImage' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_namespace}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'namespace' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_tag}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'tag' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  fi

  logTrace -n "Resolving @include()s in ${_input}";

  echo -n '' > "${_output}";

  while IFS='' read -r line; do
    _match=1;
    _includedFile="";
    if    [[ "${line#@include(\"}" != "$line" ]] \
       && [[ "${line%\")}" != "$line" ]]; then
      _ref="$(echo "$line" | sed 's/@include(\"\(.*\)\")/\1/g')";
      if resolve_included_file "${_ref}" "${_repoFolder}" "${_templateFolder}"; then
        _includedFile="${RESULT}";
        _includedFolder="$(dirname ${_includedFile})";
        _includedFileBundleSettings="${_includedFolder}/$(basename ${_includedFile} .template).settings";
        if [ -e "${_includedFileBundleSettings}" ]; then
          source "${_includedFileBundleSettings}";
        fi
        _includedFileBundleName="$(basename ${_includedFile} .template)-files";
        _includedFileBundle="${_includedFolder}/${_includedFileBundleName}";
        if [ -e "${_includedFileBundleSettings}" ]; then
          source "${_includedFileBundleSettings}";
        fi
        if [ -d "${_includedFileBundle}" ]; then
          if [ -d "${_repoFolder}/${_includedFileBundleName}" ]; then
            rsync -az "${_includedFileBundle}/" "${_repoFolder}/${_includedFileBundleName}/";
          else
            cp -r "${_includedFileBundle}" "${_repoFolder}";
          fi
          for f in $(find ${_repoFolder}/${_includedFileBundleName}/ -name '*.template'); do
            if [ -e ${f} ]; then
#              _debugEcho "process_file ${f} ${_repoFolder}/${_includedFileBundleName}/$(basename ${f} .template) ${_repoFolder} ${_templateFolder} ${_repo} ${_rootImage} ${_namespace} ${_tag} ${_stackSuffix} ${_backupHostSshPort}";
              process_file "${f}" "${_repoFolder}/${_includedFileBundleName}/$(basename ${f} .template)" "${_repoFolder}" "${_templateFolder}" "${_repo}" "${_rootImage}" "${_namespace}" "${_tag}" "${_stackSuffix}" "${_backupHostSshPort}";
            fi
          done
        fi
        if [ -e "${_includedFile}.template" ]; then
          if process_file "${_includedFile}.template" "${_includedFile}" "${_repoFolder}" "${_templateFolder}" "${_repo}" "${_rootImage}" "${_namespace}" "${_tag}" "${_stackSuffix}" "${_backupHostSshPort}"; then
            _match=${TRUE};
          else
            _match=${FALSE};
            logTraceResult FAILURE "failed";
            exitWithErrorCode CANNOT_PROCESS_TEMPLATE "${_includedFile}";
          fi
        else
          _match=${TRUE};
        fi
      else
        _match=${FALSE};
        _errorRef="${_ref}";
        eval "echo ${_ref}" > /dev/null 2>&1;
        if [ $? -eq 0 ]; then
          _errorRef="${_input} contains ${_ref} with evaluates to $(eval "echo ${_ref}" 2> /dev/null), and it's not found in any of the expected paths: ${_repoFolder}, ${_templateFolder}";
        fi
      fi
    fi
    if isTrue ${_match}; then
#      _debugEcho "Appending ${_includedFile} to ${_output}";
      cat "${_includedFile}" >> "${_output}";
    else
      echo "$line" >> "${_output}";
    fi
  done < "${_input}";
  _rescode=$?;
  if [ -n "${_errorRef}" ]; then
    logTraceResult FAILURE "failed";
    exitWithErrorCode INCLUDED_FILE_NOT_FOUND "${_errorRef}";
  else
    if [ ${_rescode} -eq 0 ]; then
      logTraceResult SUCCESS "done";
    else
      logTraceResult FAILURE "failed";
    fi
  fi
  return ${_rescode};
}

## Processes placeholders in given file.
## -> 1: the input file.
## -> 2: the output file.
## -> 3: the image.
## -> 4: the root image.
## -> 5: the namespace.
## -> 6: the tag.
## -> 7: the stack suffix.
## -> 8: the backup host's SSH port (optional).
## <- 0 if the file was processed successfully; 1 otherwise.
## Example:
##  if process_placeholders my.template" "my" "myImage" "root" "example" "latest" "" "2222"; then
##    echo "my.template -> my";
##  fi
function process_placeholders() {
  local _file="${1}";
  local _output="${2}";
  local _repo="${3}";
  local _rootImage="${4}";
  local _namespace="${5}";
  local _tag="${6}";
  local _stackSuffix="${7}";
  local _backupHostSshPort="${8:-22}";
  local _rescode;
  local _env="$( \
    for ((i = 0; i < ${#ENV_VARIABLES[*]}; i++)); do \
      echo ${ENV_VARIABLES[$i]} | awk -v dollar="$" -v quote="\"" '{printf("echo  %s=\\\"%s%s{%s}%s\\\"", $0, quote, dollar, $0, quote);}' | sh; \
    done;) TAG=\"${_tag}\" DATE=\"${DATE}\" TIME=\"${TIME}\" MAINTAINER=\"${AUTHOR} <${AUTHOR_EMAIL}>\" STACK=\"${STACK}\" REPO=\"${_repo}\" IMAGE=\"${_repo}\" ROOT_IMAGE=\"${_rootImage}\" BASE_IMAGE=\"${BASE_IMAGE}\" STACK_SUFFIX=\"${_stackSuffix}\" NAMESPACE=\"${_namespace}\" BACKUP_HOST_SSH_PORT=\"${_backupHostSshPort}\" DOLLAR='$' ";

  local _envsubstDecl=$(echo -n "'"; echo -n "$"; echo -n "{TAG} $"; echo -n "{DATE} $"; echo -n "{MAINTAINER} $"; echo -n "{STACK} $"; echo -n "{REPO} $"; echo -n "{IMAGE} $"; echo -n "{ROOT_IMAGE} $"; echo -n "{BASE_IMAGE} $"; echo -n "{STACK_SUFFIX} $"; echo -n "{NAMESPACE} $"; echo -n "{BACKUP_HOST_SSH_PORT} $"; echo -n "{DOLLAR}"; echo ${ENV_VARIABLES[*]} | tr ' ' '\n' | awk '{printf("${%s} ", $0);}'; echo -n "'";);

  echo "${_env} envsubst ${_envsubstDecl} < ${_file}" | sh > "${_output}";
  _rescode=$?;
  return ${_rescode};
}

## Resolves any @include_env in given file.
## -> 1: the input file.
## -> 2: the output file.
## -> 3: the image.
## -> 4: the root image.
## -> 5: the namespace.
## -> 6: the tag.
## -> 7: the stack suffix.
## -> 8: the backup host's SSH port (optional).
## <- 0: if the @include_env is resolved successfully; 1 otherwise.
## Example:
##  resolve_include_env "my.template" "my"
function resolve_include_env() {
  local _input="${1}";
  local _output="${2}";
  export IMAGE="${3}";
  export ROOT_IMAGE="${4}";
  export NAMESPACE="${5}";
  export TAG="${6}";
  export STACK_SUFFIX="${7}";
  export BACKUP_HOST_SSH_PORT="${8:-22}";
  local _includedFile;
  local _rescode;
  local _envVar;
  local line;
  local -a _envVars=();
  for ((i = 0; i < ${#ENV_VARIABLES[*]}; i++)); do \
    _envVars[${i}]="${ENV_VARIABLES[${i}]}";
  done
  _envVars[${#_envVars[*]}]="IMAGE";
  _envVars[${#_envVars[*]}]="TAG";
  _envVars[${#_envVars[*]}]="DATE";
  _envVars[${#_envVars[*]}]="TIME";
  _envVars[${#_envVars[*]}]="MAINTAINER";
  _envVars[${#_envVars[*]}]="AUTHOR";
  _envVars[${#_envVars[*]}]="AUTHOR_EMAIL";
  _envVars[${#_envVars[*]}]="STACK";
  _envVars[${#_envVars[*]}]="ROOT_IMAGE";
  _envVars[${#_envVars[*]}]="BASE_IMAGE";
  _envVars[${#_envVars[*]}]="STACK_SUFFIX";
  _envVars[${#_envVars[*]}]="NAMESPACE";
  _envVars[${#_envVars[*]}]="BACKUP_HOST_SSH_PORT";

  logTrace -n "Resolving @include_env in ${_input}";

  echo -n '' > "${_output}";

  while IFS='' read -r line; do
    _includedFile="";
    if [[ "${line#@include_env}" != "$line" ]]; then
      echo -n "ENV " >> "${_output}";
      for ((i = 0; i < ${#_envVars[*]}; i++)); do \
        _envVar="${_envVars[$i]}";
        if [ "${_envVar#ENABLE_}" == "${_envVar}" ]; then
          if [ $i -ne 0 ]; then
            echo >> "${_output}";
            echo -n "    " >> "${_output}";
          fi
          echo "${_envVar}" | awk -v dollar="$" -v quote="\"" '{printf("echo -n \"SQ_%s=\\\"%s%s{%s}%s\\\"\"", $0, quote, dollar, $0, quote);}' | sh >> "${_output}"
          if [ $i -lt $((${#_envVars[@]} - 1)) ]; then
            echo -n " \\" >> "${_output}";
          fi
        fi
      done
      echo >> "${_output}";
    elif [[ "${line# +}" == "${line}" ]]; then
      echo "$line" >> "${_output}";
    fi
  done < "${_input}";
  _rescode=$?;
  if [ ${_rescode} -eq 0 ]; then
    logTraceResult SUCCESS "done";
  else
    logTraceResult FAILURE "failed";
  fi
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

## PUBLIC
## Copies the license file from specified folder to the repository folder.
## -> 1: the folder where the license file is included.
## -> 2: the repository.
## Example:
##   copy_license_file "${PWD}" "myImage"
function copy_license_file() {
  local _folder="${1}";
  local _repo="${2}";
  local _licenseFile="${LICENSE_FILE}";

  checkNotEmpty "folder" "${_folder}" 1;
  checkNotEmpty "repo" "${_repo}" 2;

  if [ "${_repo}" == "set-square" ]; then
    _licenseFile="LICENSE.set-square";
  fi

  if [ -e "${_repo}/${_licenseFile}" ] || \
     [ -e "${_folder}/${_licenseFile}" ]; then
    if [ ! -e "${_repo}/LICENSE" ]; then
      logDebug -n "Using ${_licenseFile} for ${_repo} image";
      cp "${_folder}/${_licenseFile}" "${_repo}/LICENSE";
      if isTrue $?; then
        logDebugResult SUCCESS "done";
      else
        logDebugResult FAILURE "failed";
        exitWithErrorCode CANNOT_COPY_LICENSE_FILE;
      fi
    fi
  else
    exitWithErrorCode LICENSE_FILE_DOES_NOT_EXIST "${_folder}/${_licenseFile}";
  fi
}

## PUBLIC
## Copies the copyright-preamble file from specified folder to the repository folder.
## -> 1: the folder where the copyright preamble file is included.
## -> 2: the repository.
## Example:
##   copy_copyright_preamble_file "${PWD}" "myImage";
function copy_copyright_preamble_file() {
  local _folder="${1}";
  local _repo="${2}";
  local _copyrightPreambleFile="${COPYRIGHT_PREAMBLE_FILE}";

  checkNotEmpty "folder" "${_folder}" 1;
  checkNotEmpty "repo" "${_repo}" 2;

  if [ "${_repo}" == "set-square" ]; then
    _copyrightPreambleFile="copyright-preamble.set-square";
  fi

  if [ -e "${_repo}/${_copyrightPreambleFile}" ] || \
     [ -e "${_folder}/${_copyrightPreambleFile}" ]; then

    if [ ! -e "${_repo}/copyright-preamble.txt" ]; then
      logDebug -n "Using ${_copyrightPreambleFile} for ${_repo} image";
      cp "${_folder}/${_copyrightPreambleFile}" "${_repo}/copyright-preamble.txt";
      if isTrue $?; then
        logDebugResult SUCCESS "done";
      else
        logDebugResult FAILURE "failed";
        exitWithErrorCode CANNOT_COPY_COPYRIGHT_PREAMBLE_FILE;
      fi
    fi
  else
    exitWithErrorCode COPYRIGHT_PREAMBLE_FILE_DOES_NOT_EXIST "${_folder}/${_copyrightPreambleFile}";
  fi
}

## PUBLIC
## Resolves the BACKUP_HOST_SSH_PORT variable.
## -> 1: the image.
## <- RESULT: the value of such variable.
## Example:
##   retrieve_backup_host_ssh_port mariadb;
##   export BACKUP_HOST_SSH_PORT="${RESULT}";f
function retrieve_backup_host_ssh_port() {
  local _repo="${1}";
  local _result;
  if [ -e "${SSHPORTS_FILE}" ]; then
    _result="$(echo -n ''; (grep -e ${_repo} ${SSHPORTS_FILE} || echo ${_repo} 22) | awk '{print $2;}')";
  else
    _result="";
  fi
  export RESULT="${_result}";
}

## PUBLIC
## Copies dry-wit to given folder.
## -> 1: dry-wit location.
## -> 2: The destination folder.
## <- 0/${TRUE}: if dry-wit is copied correctly; 1/${FALSE} otherwise.
## Example:
##   copy_dry_wit_to_folder "${PWD}/dry-wit" ".templates/common-files"
function copy_dry_wit_to_folder() {
  local _dryWit="${1}";
  local _folder="${2}";
  local -i _rescode=${TRUE};

  if isEmpty "${_dryWit}"; then
      exitWithErrorCode UNACCEPTABLE_API_CALL "'dryWit' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_folder}"; then
      exitWithErrorCode UNACCEPTABLE_API_CALL "'folder' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  fi

  logTrace -n "Copying dry-wit to ${_folder}";
  cp "${_dryWit}" "${_folder}"/
  _rescode=$?;
  if isTrue ${_rescode}; then
    logTraceResult SUCCESS "done";
  else
    logTraceResult FAILURE "failed";
  fi

  return ${_rescode};
}

## PUBLIC
## Copies dry-wit to the repository folder if it's used.
## The rationale is to make sure dry-wit inside the repository is up to date.
## Docker does not allow using symlinks for files to be copied inside the container.
## -> 1: The location of the dry-wit file.
## -> 2: The repository.
## <- 0/${TRUE}: if dry-wit is not used, or if it is copied successfully;
##    1/${FALSE}: if it was meant to be copied but it failed for some reason.
## Example:
##   copy_dry_wit_if_needed "${PWD}/dry-wit" "base"
function copy_dry_wit_if_needed() {
  local _dryWit="${1}";
  local _repo="${2}";
  local -i _rescode=${TRUE};

  if isEmpty "${_dryWit}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'dryWit' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_repo}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'repo' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  fi

  if    [ -e "${_repo}/dry-wit" ] \
     || [ "x${_repo}" == "xbase" ]; then
    copy_dry_wit_to_folder "${_dryWit}" "${_repo}";
  fi

  return ${_rescode};
}

## PRIVATE
## Copies set-square files and folders to its own Docker build folder.
## -> 1: The repo folder.
## <- 0/${TRUE} if the files are copied successfully; 1/${FALSE} otherwise.
## Example:
##   if _copy_set_square_files_to_repo; then
##     echo "set-square files copied successfully";
##   fi
function _copy_set_square_files_to_repo() {
  local _repo="${1}";
  local -i _rescode;

  checkNotEmpty "repo" "${_repo}" 1;

  for f in build.sh build.inc.sh; do
    cp -r ${f} "${_repo}";
    _rescode=$?;
    if isFalse ${_rescode}; then
      break;
    fi
  done

  return ${_rescode};
}

## PUBLIC
## Builds "${NAMESPACE}/${REPO}:${TAG}" image.
## -> 1: the repository.
## -> 2: the tag.
## -> 3: the stack (optional).
## Example:
##  build_repo "myImage" "latest" "";
function build_repo() {
  local _repo="${1}";
  local _canonicalTag="${2}";

  if isEmpty "${_repo}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'repository' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${_canonicalTag}"; then
    exitWithErrorCode UNACCEPTABLE_API_CALL "'tag' cannot be empty when calling ${FUNCNAME[0]}. Review ${FUNCNAME[1]}";
  elif isEmpty "${INCLUDES_FOLDER}"; then
    exitWithErrorCode UNACCEPTABLE_ENVIRONMENT_VARIABLE "'INCLUDES_FOLDER' cannot be empty";
  fi

  local _stack="${3}";

  if reduce_image_enabled; then
      _rawTag="${2}-raw";
      _tag="${_rawTag}";
  else
    _tag="${_canonicalTag}";
  fi

  local _stackSuffix;
  local _cmdResult;
  local _rootImage=;
  retrieve_backup_host_ssh_port "${_repo}";
  local _backupHostSshPort="${RESULT:-22}";
  if is_32bit; then
    _rootImage="${ROOT_IMAGE_32BIT}:${ROOT_IMAGE_VERSION}";
  else
    _rootImage="${ROOT_IMAGE_64BIT}:${ROOT_IMAGE_VERSION}";
  fi
  update_log_category "${_repo}";
  retrieve_stack_suffix "${STACK}";
  _stackSuffix="${RESULT}";

  copy_dry_wit_to_folder "${PWD}/dry-wit" "${INCLUDES_FOLDER}/common-files";
  #  copy_dry_wit_if_needed "${PWD}/dry-wit" "${_repo}";
  if [ "${_repo}" == "set-square" ]; then
    _copy_set_square_files_to_repo "${_repo}";
  fi

  copy_license_file "${PWD}" "${_repo}";
  copy_copyright_preamble_file "${PWD}" "${_repo}";

  if [ $(ls ${_repo} | grep -e '\.template$' | wc -l) -gt 0 ]; then
    for f in ${_repo}/*.template; do
      if ! process_file "${f}" "${_repo}/$(basename ${f} .template)" "${_repo}" "${INCLUDES_FOLDER}" "${_repo}" "${_rootImage}" "${NAMESPACE}" "${_tag}" "${_stackSuffix}" "${_backupHostSshPort}"; then
        exitWithErrorCode CANNOT_PROCESS_TEMPLATE "${f}";
      fi
    done
  fi

  logInfo "Building ${NAMESPACE}/${_repo%%-stack}${_stack}:${_tag}"
#  echo ${DOCKER} ${DOCKER_OPTS} build ${BUILD_OPTS} -t "${NAMESPACE}/${_repo%%-stack}${_stack}:${_tag}" ${DOCKER_BUILD_OPTS} "${_repo}"
  runCommandLongOutput "${DOCKER_BUILD} ${BUILD_OPTS} -t ${NAMESPACE}/${_repo%%-stack}${_stack}:${_tag} ${DOCKER_BUILD_OPTS} ${_repo}";
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
    ${DOCKER} ${DOCKER_OPTS} tag ${DOCKER_TAG_OPTS} "${NAMESPACE}/${_repo%%-stack}${_stack}:${_canonicalTag}" "${NAMESPACE}/${_repo%%-stack}${_stack}:latest"
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
  ${DOCKER} ${DOCKER_OPTS} tag ${DOCKER_TAG_OPTS} "${NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag}" "${REGISTRY}/${REGISTRY_NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag}";
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "done"
  else
    logInfoResult FAILURE "failed"
    exitWithErrorCode ERROR_TAGGING_IMAGE "${_repo}";
  fi
  logInfo "Pushing ${NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag} to ${REGISTRY}";
  ${DOCKER} ${DOCKER_OPTS} push "${REGISTRY}/${REGISTRY_NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag}"
  _pushResult=$?;
  logInfo -n "Pushing ${NAMESPACE}/${_repo%%-stack}${_stackSuffix}:${_tag} to ${REGISTRY}";
  if [ ${_pushResult} -eq 0 ]; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
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
             "./${_repo}/.build-settings.sh"; do
      sourceFileIfExists "${f}";
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

## Checks whether the -cc flag is enabled.
## Example:
##   if cleanup_containers_enabled; then [..]; fi
function cleanup_containers_enabled() {
  _flagEnabled CLEANUP_CONTAINERS;
}

## Cleans up the docker containers
## Example:
##   cleanup_containers
function cleanup_containers() {

  if cleanup_containers_enabled; then
    local _count="$(${DOCKER} ${DOCKER_OPTS} ps -a -q | xargs -n 1 -I {} | wc -l)";
    #  _count=$((_count-1));
    if [ ${_count} -gt 0 ]; then
      logInfo -n "Cleaning up ${_count} stale container(s)";
      ${DOCKER} ${DOCKER_OPTS} ps -a -q | xargs -n 1 -I {} sudo ${DOCKER} ${DOCKER_OPTS} rm -v {} > /dev/null;
      if [ $? -eq 0 ]; then
        logInfoResult SUCCESS "done";
      else
        logInfoResult FAILED "failed";
      fi
    fi
  fi
}

## Checks whether the -ci flag is enabled.
## Example:
##   if cleanup_images_enabled; then [..]; fi
function cleanup_images_enabled() {
  _flagEnabled CLEANUP_IMAGES;
}

## Cleans up unused docker images.
## Example:
##   cleanup_images
function cleanup_images() {
  if cleanup_images_enabled; then
    local _count="$(${DOCKER} ${DOCKER_OPTS} images | grep '<none>' | wc -l)";
    if [ ${_count} -gt 0 ]; then
      logInfo -n "Trying to delete up to ${_count} unnamed image(s)";
      ${DOCKER} ${DOCKER_OPTS} images | grep '<none>' | awk '{printf("${DOCKER} ${DOCKER_OPTS} rmi -f %s\n", $3);}' | sh > /dev/null
      if [ $? -eq 0 ]; then
        logInfoResult SUCCESS "done";
      else
        logInfoResult FAILED "failed";
      fi
    fi
  fi
}

# Main logic
function main() {
  local _repo;
  local _parents;
  local _stack="${STACK}";
  local _buildRepo=${FALSE};

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
