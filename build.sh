#!/bin/bash dry-wit
# Copyright 2014-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-t|--tag tagName] [-f|--force] [-o|--overwrite-latest] [-p|--registry] [-r|--reduce-image] [-ci|--cleanup-images] [-cc|--cleanup-containers] [-rt|--registry-tag] [repo]+
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
  * registry-tag: Whether to tag also for pushing to a registry later (implicit if -p is enabled).
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
  checkReq docker DOCKER_NOT_INSTALLED;
  checkReq date DATE_NOT_INSTALLED;
  checkReq realpath REALPATH_NOT_INSTALLED;
  checkReq envsubst ENVSUBST_NOT_INSTALLED;
  checkReq head HEAD_NOT_INSTALLED;
  checkReq grep GREP_NOT_INSTALLED;
  checkReq awk AWK_NOT_INSTALLED;
}

# Error messages
function defineErrors() {
  addError INVALID_OPTION "Unrecognized option";
  addError DOCKER_NOT_INSTALLED "docker is not installed";
  addError DATE_NOT_INSTALLED "date is not installed";
  addError REALPATH_NOT_INSTALLED "realpath is not installed";
  addError ENVSUBST_NOT_INSTALLED "envsubst is not installed";
  addError HEAD_NOT_INSTALLED "head is not installed";
  addError GREP_NOT_INSTALLED "grep is not installed";
  addError AWK_NOT_INSTALLED "awk is not installed";
  addError DOCKER_SQUASH_NOT_INSTALLED "docker-squash is not installed. Check out https://github.com/jwilder/docker-squash for details";
  addError NO_REPOSITORIES_FOUND "no repositories found";
  addError INVALID_URL "Invalid url";
  addError CANNOT_PROCESS_TEMPLATE "Cannot process template";
  addError INCLUDED_FILE_NOT_FOUND "The included file is missing";
  addError ERROR_BUILDING_REPO "Error building repository";
  addError ERROR_TAGGING_IMAGE "Error tagging image";
  addError ERROR_PUSHING_IMAGE "Error pushing image to ${REGISTRY}";
  addError ERROR_REDUCING_IMAGE "Error reducing the image size";
  addError CANNOT_COPY_LICENSE_FILE "Cannot copy the license file ${LICENSE_FILE}";
  addError LICENSE_FILE_DOES_NOT_EXIST "The specified license ${LICENSE_FILE} does not exist";
  addError CANNOT_COPY_COPYRIGHT_PREAMBLE_FILE "Cannot copy the license file ${COPYRIGHT_PREAMBLE_FILE}";
  addError COPYRIGHT_PREAMBLE_FILE_DOES_NOT_EXIST "The specified copyright-preamble file ${COPYRIGHT_PREAMBLE_FILE} does not exist";
  addError PARENT_REPO_NOT_AVAILABLE "The parent repository is not available";
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
         export REGISTRY_TAG=TRUE;
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
      -ci | --cleanup-images)
          shift;
          export CLEAUP_IMAGES=TRUE;
          ;;
      -cc | --cleanup-containers)
        shift;
        export CLEAUP_CONTAINERS=TRUE;
        ;;
      -rt | --registry-tag)
        shift;
        export REGISTRY_TAG=TRUE;
        ;;
    esac
  done

  if isEmpty "${TAG}"; then
    TAG="${DATE}";
  fi

  # Parameters
  if isEmpty "${REPOS}"; then
    REPOS="$@";
    shift;
  fi

  if isEmpty "${REPOS}"; then
    REPOS="$(find . -maxdepth 1 -type d | grep -v '^\.$' | sed 's \./  g' | grep -v '^\.')";
  fi

  if ! isEmpty "${REPOS}"; then
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
      -t | --tag | -p | --registry | -f | --force | -r | --reduce-image)
	      ;;
      -rt | --registry-tag)
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
    logDebugResult SUCCESS "valid";
  fi
}

## Does "${NAMESPACE}/${REPO}:${TAG}" exist?
## -> 1: the repository.
## -> 2: the tag.
## <- 0 if it exists, 1 otherwise
## Example:
##   if repo_exists "myImage" "latest"; then [..]; fi
function repo_exists() {
  local _repo="${1}";
  local _tag="${2}";

  checkNotEmpty "repository" "${_repo}" 1;
  checkNotEmpty "tag" "${_tag}" 2;

  if _evalEnvVar "${_tag}"; then
      _tag="${RESULT}";
  fi

  local _images=$(${DOCKER} images "${NAMESPACE}/${_repo}")
  local _matches=$(echo "${_images}" | grep "${_tag}")
  local -i _rescode;

  if isEmpty "${_matches}"; then
      _rescode=${FALSE};
  else
    _rescode=${TRUE};
  fi

  return ${_rescode};
}

## Builds the image if it's defined locally.
## -> 1: the repository.
## Example:
##   build_repo_if_defined_locally "myImage:latest";
function build_repo_if_defined_locally() {
  local _repo="${1}";
  local _name="${_repo%:*}";
  local _tag="${_repo#*:}";

  if ! isEmpty "${_name}" && \
     [[ -d ${_name} ]] && \
     ! repo_exists "${_name#${NAMESPACE}/}" "${_tag}"; then
      build_repo "${_name}" "${_tag}"
  fi
}

## Squashes the image with docker-squash [1]
## [1] https://github.com/jwilder/docker-squash
## -> 1: the namespace.
## -> 2: the repo name.
## -> 3: the current tag.
## -> 4: the new tag for the squashed image.
## Example:
##   reduce_image_size "namespace" "myimage" "201508-raw" "201508"
function reduce_image_size() {
  local _namespace="${1}";
  local _repo="${2}";
  local _currentTag="${3}";
  local _tag="${4}";
  checkReq docker-squash DOCKER_SQUASH_NOT_INSTALLED;

  checkNotEmpty "namespace" "${_namespace}" 1;
  checkNotEmpty "repository" "${_repo}" 2;
  checkNotEmpty "currentTag" "${_currentTag}" 3;
  checkNotEmpty "tag" "${_tag}" 4;

  logInfo -n "Squashing ${_image} as ${_namespace}/${_repo}:${_tag}"
  ${DOCKER} save "${_namespace}/${_repo}:${_currentTag}" | sudo docker-squash -t "${_namespace}/${_repo}:${_tag}" | ${DOCKER} load
  if isTrue $?; then
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
  local _backupHostSshPort="${10:-22}";
  local _rescode=${FALSE};

  local _temp1;
  local _temp2;

  checkNotEmpty "file" "${_file}" 1;
  checkNotEmpty "output" "${_output}" 2;
  checkNotEmpty "repoFolder" "${_repoFolder}" 3;
  checkNotEmpty "templateFolder" "${_templateFolder}" 4;
  checkNotEmpty "repository" "${_repo}" 5;
  checkNotEmpty "rootImage" "${_rootImage}" 6;
  checkNotEmpty "namespace" "${_namespace}" 7;
  checkNotEmpty "tag" "${_tag}" 8;

  local _settingsFile="$(dirname ${_file})/$(basename ${_file} .template).settings";

  if createTempFile; then
      _temp1="${RESULT}";
  fi

  if createTempFile; then
      _temp2="${RESULT}";
  fi

  if isNotEmpty "${_temp1}" && isNotEmpty "${_temp2}" && \
     resolve_includes "${_file}" "${_temp1}" "${_repoFolder}" "${_templateFolder}" "${_repo}" "${_rootImage}" "${_namespace}" "${_tag}" "${_backupHostSshPort}"; then
      logTrace -n "Resolving @include_env in ${_file}";
      _debugEcho "Resolving @include_env in ${_file}";
      if resolve_include_env "${_temp1}" "${_temp2}" "${_repo}" "${_rootImage}" "${_namespace}" "${_tag}" "${_backupHostSshPort}"; then
          logTraceResult SUCCESS "done";
          if [ -e "${_settingsFile}" ]; then
              process_settings_file "${_settingsFile}";
          fi
          logTrace -n "Resolving placeholders in ${_file}";
          _debugEcho "Resolving placeholders in ${_temp2}";
          if process_placeholders "${_temp2}" "${_output}" "${_repo}" "${_rootImage}" "${_namespace}" "${_tag}" "${_backupHostSshPort}"; then
              _rescode=${TRUE};
              _debugEcho "Resolving placeholders in ${_file} succeeded -> ${_output}";
              logTraceResult SUCCESS "done"
          else
            _rescode=${FALSE};
            _debugEcho "Resolving placeholders in ${_file} failed";
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
  local _rescode=${FALSE};

  checkNotEmpty "file" "${_file}" 1;
  checkNotEmpty "repoFolder" "${_repoFolder}" 2;
  checkNotEmpty "templatesFolder" "${_templatesFolder}" 3;

  for d in "${_templatesFolder}"; do
    _debugEcho "Checking ${d}/${_file}";
    if    [[ -f "${d}/${_file}" ]] \
       || [[ -f "${d}/$(basename ${_file} .template).template" ]]; then
      _debugEcho "${d}/${_file} found!";
      _result="${d}/${_file}";
      export RESULT="${_result}";
      _rescode=${TRUE};
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

  _debugEcho "${_file} resolved -> ${_rescode}";

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
  local _backupHostSshPort="${10:-22}";
  local _rescode;
  local _match;
  local _includedFile;
  local line;

  checkNotEmpty "input" "${_input}" 1;
  checkNotEmpty "output" "${_output}" 2;
  checkNotEmpty "repoFolder" "${_repoFolder}" 3;
  checkNotEmpty "templateFolder" "${_templateFolder}" 4;
  checkNotEmpty "repository" "${_repo}" 5;
  checkNotEmpty "rootImage" "${_rootImage}" 6;
  checkNotEmpty "namespace" "${_namespace}" 7;
  checkNotEmpty "tag" "${_tag}" 8;

  logTrace -n "Resolving @include()s in ${_input}";

  echo -n '' > "${_output}";

  while IFS='' read -r line; do
    _match=${FALSE};
    _includedFile="";
    if    [[ "${line#@include(\"}" != "$line" ]] \
       && [[ "${line%\")}" != "$line" ]]; then
      _ref="$(echo "$line" | sed 's/@include(\"\(.*\)\")/\1/g')";
      if resolve_included_file "${_ref}" "${_repoFolder}" "${_templateFolder}"; then
          _includedFile="${RESULT}";
          if [ -d "${_templateFolder}/$(basename ${_includedFile})-files" ]; then
              mkdir "${_repoFolder}/$(basename ${_includedFile})-files" 2> /dev/null;
              rsync -az "${PWD}/${_templateFolder#\./}/$(basename ${_includedFile})-files/" "${_repoFolder}/$(basename ${_includedFile})-files/"
              _debugEcho "Processing ${_repoFolder}/$(basename ${_includedFile})-files"
              shopt -s nullglob dotglob;
              _files=(${_repoFolder}/$(basename ${_includedFile})-files/*.template);
              shopt -u nullglob dotglob;
              if [ ${#_files[@]} -gt 0 ]; then
                for p in ${_repoFolder}/$(basename ${_includedFile})-files/*.template; do
                  _debugEcho "Processing ${p}";
                  process_file "${p}" "$(dirname ${p})/$(basename ${p} .template)" "${_repoFolder}" "${_templateFolder}" "${_repo}" "${_rootImage}" "${_namespace}" "${_tag}" "${_backupHostSshPort}";
                done
              fi
          fi
          if [ -e "${_includedFile}.template" ]; then
              if process_file "${_includedFile}.template" "${_includedFile}" "${_repoFolder}" "${_templateFolder}" "${_repo}" "${_rootImage}" "${_namespace}" "${_tag}" "${_backupHostSshPort}"; then
                  _match=${TRUE};
              else
                _match=${FALSE};
                logTraceResult FAILURE "failed";
                exitWithErrorCode CANNOT_PROCESS_TEMPLATE "${_includedFile}";
              fi
          elif [ -e "${_includedFile}.settings" ]; then
              if process_settings_file "${_includedFile}.settings"; then
                  _match=${TRUE};
              else
                _match=${FALSE};
                logTraceResult FAILURE "failed";
                exitWithErrorCode CANNOT_PROCESS_TEMPLATE "${_includedFile}.settings";
              fi
          else
            _match=${TRUE};
          fi
      else
        _match=${FALSE};
        _errorRef="${_ref}";
        eval "echo ${_ref}" > /dev/null 2>&1;
        if isTrue $?; then
          _errorRef="${_input} contains ${_ref} with evaluates to $(eval "echo ${_ref}" 2> /dev/null), and it's not found in any of the expected paths: ${_repoFolder}, ${_templateFolder}";
        fi
      fi
    fi
    if isTrue ${_match}; then
        cat "${_includedFile}" >> "${_output}";
    else
      echo "$line" >> "${_output}";
    fi
  done < "${_input}";
  _rescode=$?;
  if isEmpty "${_errorRef}" && isTrue ${_rescode}; then
      logTraceResult SUCCESS "done";
  else
    logTraceResult FAILURE "failed";
  fi

  return ${_rescode};
}

## Processes a settings file for a template.
## -> 1: The settings file.
## <- 0/${TRUE} if the settings file was processed successfully; 1/${FALSE} otherwise.
## Example:
##   if process_settings_file "my.settings"; then
##     echo "my.settings processed successfully";
##   fi
function process_settings_file() {
  local _file="${1}";
  local -i _rescode=${FALSE};

  checkNotEmpty "file" "${_file}" 1;

  logInfo -n "Reading ${_file}";
  source "${_file}";
  _rescode=$?;
  if isTrue ${_rescode}; then
      logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
    exit 1;
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
  local _backupHostSshPort="${7:-22}";
  local _rescode;

  checkNotEmpty "file" "${_file}" 1;
  checkNotEmpty "output" "${_output}" 2;
  checkNotEmpty "repository" "${_repo}" 3;
  checkNotEmpty "rootImage" "${_rootImage}" 4;
  checkNotEmpty "namespace" "${_namespace}" 5;
  checkNotEmpty "tag" "${_tag}" 6;

  local _env="$( \
    for ((i = 0; i < ${#ENV_VARIABLES[*]}; i++)); do \
      echo ${ENV_VARIABLES[$i]} | awk -v dollar="$" -v quote="\"" '{printf("echo  %s=\\\"%s%s{%s}%s\\\"", $0, quote, dollar, $0, quote);}' | sh; \
    done;) TAG=\"${_tag}\" DATE=\"${DATE}\" TIME=\"${TIME}\" MAINTAINER=\"${AUTHOR} <${AUTHOR_EMAIL}>\" STACK=\"${STACK}\" REPO=\"${_repo}\" IMAGE=\"${_repo}\" ROOT_IMAGE=\"${_rootImage}\" BASE_IMAGE=\"${BASE_IMAGE}\" NAMESPACE=\"${_namespace}\" BACKUP_HOST_SSH_PORT=\"${_backupHostSshPort}\" DOLLAR='$' ";

  local _envsubstDecl=$(echo -n "'"; echo -n "$"; echo -n "{_tag} $"; echo -n "{DATE} $"; echo -n "{TIME} $"; echo -n "{MAINTAINER} $"; echo -n "{STACK} $"; echo -n "{REPO} $"; echo -n "{IMAGE} $"; echo -n "{ROOT_IMAGE} $"; echo -n "{BASE_IMAGE} $"; echo -n "{NAMESPACE} $"; echo -n "{BACKUP_HOST_SSH_PORT} $"; echo -n "{DOLLAR}"; echo ${ENV_VARIABLES[*]} | tr ' ' '\n' | awk '{printf("${%s} ", $0);}'; echo -n "'";);

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
## -> 8: the backup host's SSH port (optional).
## <- 0: if the @include_env is resolved successfully; 1 otherwise.
## Example:
##  resolve_include_env "my.template" "my"
function resolve_include_env() {
  local _input="${1}";
  local _output="${2}";
  local _image="${3}";
  local _rootImage="${4}";
  local _namespace="${5}";
  local _tag="${6}";
  local _backupHostSshPort="${7:-22}";
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
  if isTrue ${_rescode}; then
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
## -> 1: the repository.
## -> 2: the folder where the license file is included.
## Example:
##   copy_license_file "myImage" ${PWD}
function copy_license_file() {
  local _repo="${1}";
  local _folder="${2}";
  if [ -e "${_folder}/${LICENSE_FILE}" ]; then
    logDebug -n "Using ${LICENSE_FILE} for ${_repo} image";
    cp "${_folder}/${LICENSE_FILE}" "${_repo}/LICENSE";
    if isTrue $?; then
      logDebugResult SUCCESS "done";
    else
      logDebugResult FAILURE "failed";
      exitWithErrorCode CANNOT_COPY_LICENSE_FILE;
    fi
  else
    exitWithErrorCode LICENSE_FILE_DOES_NOT_EXIST "${_folder}/${LICENSE_FILE}";
  fi
}

## PUBLIC
## Copies the copyright-preamble file from specified folder to the repository folder.
## -> 1: the repository.
## -> 2: the folder where the copyright preamble file is included.
## Example:
##   copy_copyright_preamble_file "myImage" ${PWD}
function copy_copyright_preamble_file() {
  local _repo="${1}";
  local _folder="${2}";
  if [ -e "${_folder}/${COPYRIGHT_PREAMBLE_FILE}" ]; then
      logDebug -n "Using ${COPYRIGHT_PREAMBLE_FILE} for ${_repo} image";
      cp "${_folder}/${COPYRIGHT_PREAMBLE_FILE}" "${_repo}/copyright-preamble.txt";
      if [ $? -eq 0 ]; then
          logDebugResult SUCCESS "done";
      else
        logDebugResult FAILURE "failed";
        exitWithErrorCode CANNOT_COPY_COPYRIGHT_PREAMBLE_FILE;
      fi
  else
    exitWithErrorCode COPYRIGHT_PREAMBLE_FILE_DOES_NOT_EXIST "${_folder}/${COPYRIGHT_PREAMBLE_FILE}";
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
      logDebug -n "Retrieving the ssh port of the backup host for ${_repo}";
      _result="$(echo -n ''; (grep -e ${_repo} ${SSHPORTS_FILE} || echo ${_repo} 22) | awk '{print $2;}' | head -n 1)";
      if isTrue $?; then
          logDebugResult SUCCESS "${_result}";
          export RESULT="${_result}";
      else
        logDebugResult FAILURE "not-found";
      fi
  else
    _result="";
  fi
}

## PUBLIC
## Builds "${NAMESPACE}/${REPO}:${TAG}" image.
## -> 1: the repository.
## -> 2: the tag.
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
  local _cmdResult;
  local _rootImage;
  retrieve_backup_host_ssh_port "${_repo}";
  local _backupHostSshPort="${RESULT:-22}";
  if is_32bit; then
    _rootImage="${ROOT_IMAGE_32BIT}:${ROOT_IMAGE_VERSION}";
  else
    _rootImage="${ROOT_IMAGE_64BIT}:${ROOT_IMAGE_VERSION}";
  fi
  update_log_category "${_repo}";

  defineEnvVar IMAGE "The image to build" "${_repo}";

  copy_license_file "${_repo}" "${PWD}";
  copy_copyright_preamble_file "${_repo}" "${PWD}";

  if [ $(ls ${_repo} | grep -e '\.template$' | wc -l) -gt 0 ]; then
      for f in ${_repo}/*.template; do
        logDebug -n "Processing ${f}";
        if process_file "${f}" "${_repo}/$(basename ${f} .template)" "${_repo}" "${INCLUDES_FOLDER}" "${_repo}" "${_rootImage}" "${NAMESPACE}" "${_tag}" "${_backupHostSshPort}"; then
            logDebugResult SUCCESS "done";
        else
          logDebugResult FAILURE "failed";
          exitWithErrorCode CANNOT_PROCESS_TEMPLATE "${f}";
      fi
    done
  fi

  logInfo "Building ${NAMESPACE}/${_repo}:${_tag}"
#  echo docker build ${BUILD_OPTS} -t "${NAMESPACE}/${_repo}:${_tag}" --rm=true "${_repo}"
  runCommandLongOutput "${DOCKER} build ${BUILD_OPTS} -t ${NAMESPACE}/${_repo}:${_tag} --rm=true ${_repo}";
  _cmdResult=$?
  logInfo -n "${NAMESPACE}/${_repo}:${_tag}";
  if [ ${_cmdResult} -eq 0 ]; then
    logInfoResult SUCCESS "built"
  else
    logInfo -n "${NAMESPACE}/${_repo}:${_tag}";
    logInfoResult FAILURE "not built"
    exitWithErrorCode ERROR_BUILDING_REPO "${_repo}";
  fi
  if reduce_image_enabled; then
    reduce_image_size "${NAMESPACE}" "${_repo}" "${_tag}" "${_canonicalTag}";
  fi
  if overwrite_latest_enabled; then
    logInfo -n "Tagging ${NAMESPACE}/${_repo}:${_canonicalTag} as ${NAMESPACE}/${_repo}:latest"
    docker tag "${NAMESPACE}/${_repo}:${_canonicalTag}" "${NAMESPACE}/${_repo}:latest"
    if isTrue $?; then
      logInfoResult SUCCESS "${NAMESPACE}/${_repo}:latest";
    else
      logInfoResult FAILURE "failed"
      exitWithErrorCode ERROR_TAGGING_IMAGE "${_repo}";
    fi
  fi
}

## Tags the image anticipating it will be pushed to a Docker registry later.
## -> 1: the repository.
## -> 2: the tag.
## Example:
##   registry_tag "myImage" "latest"
function registry_tag() {
  local _repo="${1}";
  local _tag="${2}";

  checkNotEmpty "repository" "${_repo}" 1;
  checkNotEmpty "tag" "${_tag}" 2;

  local _remoteTag="${REGISTRY}/${REGISTRY_NAMESPACE}/${_repo}:${_tag}";
  if isTrue ${PUSH_TO_DOCKERHUB}; then
    _remoteTag="${REGISTRY}/${_repo}:${_tag}";
  fi

  update_log_category "${_repo}";
  logInfo -n "Tagging ${NAMESPACE}/${_repo}:${_tag} as ${_remoteTag}";
  docker tag ${DOCKER_TAG_OPTIONS} "${NAMESPACE}/${_repo}:${_tag}" "${_remoteTag}";
  if isTrue $?; then
    logInfoResult SUCCESS "done"
  else
    logInfoResult FAILURE "failed"
    exitWithErrorCode ERROR_TAGGING_IMAGE "${_repo}";
  fi
}

## Pushes the image to a Docker registry.
## -> 1: the repository.
## -> 2: the tag.
## Example:
##   registry_push "myImage" "latest"
function registry_push() {
  local _repo="${1}";
  local _tag="${2}";

  checkNotEmpty "repository" "${_repo}" 1;
  checkNotEmpty "tag" "${_tag}" 2;

  local _remoteTag="${REGISTRY}/${REGISTRY_NAMESPACE}/${_repo}:${_tag}";
  if isTrue ${PUSH_TO_DOCKERHUB}; then
    _remoteTag="${REGISTRY}/${_repo}:${_tag}";
  fi

  local -i _pushResult;
  update_log_category "${_repo}";

  logInfo -n "Pushing ${_remoteTag}";
  docker push "${_remoteTag}"
  _pushResult=$?;
  if isTrue ${_pushResult}; then
    logInfoResult SUCCESS "done"
  else
    logInfoResult FAILURE "failed"
    exitWithErrorCode ERROR_PUSHING_IMAGE "${_remoteTag}"
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
## <- RESULT: the parent, if any, with the format name:tag.
## Example:
##   find_parent_repo "myImage"
##   parent="${RESULT}"
function find_parent_repo() {
  local _repo="${1}"
  local _result="$(grep -e '^FROM ' ${_repo}/Dockerfile.template 2> /dev/null | head -n 1 | awk '{print $2;}')";
  if isNotEmpty ${_result} && [[ "${_result#\$\{NAMESPACE\}/}" != "${_result}" ]]; then
    # parent under our namespace
    _result="${_result#\$\{NAMESPACE\}/}"
  fi
  if isNotEmpty "${_result}" && isEmpty "${_result#\$\{BASE_IMAGE\}}"; then
    _result=$(echo ${BASE_IMAGE} | awk -F'/' '{print $2;}')
  fi
  if isNotEmpty "${_result}" && isEmpty "${_result#\$\{ROOT_IMAGE\}}"; then
    _result="${ROOT_IMAGE}";
  fi
  export RESULT="${_result}";
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
  find_parent_repo "${_repo}";
  local _parent="${RESULT}"
  while ! isEmpty "${_parent}" && [[ "${_parent#.*/}" == "${_parent}" ]]; do
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
  local _repoSettings;
  local _privateSettings;

  checkNotEmpty "repositories" "${_repos}" 1;

  for _repo in ${_repos}; do
    for f in "${DRY_WIT_SCRIPT_FOLDER}/${_repo}/build-settings.sh" \
                 "./${_repo}/build-settings.sh"; do
      if [ -e "${f}" ]; then
          _repoSettings="${f}";
      fi
    done

    for f in "${DRY_WIT_SCRIPT_FOLDER}/${_repo}/.build-settings.sh" \
                 "./${_repo}/.build-settings.sh"; do
      if [ -e "${f}" ]; then
          _privateSettings="${f}";
      fi
    done

    for f in "${_repoSettings}" "${_privateSettings}"; do
      if [ -e "${f}" ]; then
          logTrace -n "Sourcing ${f}";
          source "${f}";
          if isTrue $?; then
              logTraceResult SUCCESS "done";
          else
            logTraceResult FAILURE "failed";
          fi
      fi
    done
  done
}

## Checks whether the -f flag is enabled
## Example:
##   if force_mode_enabled; then [..]; fi
function force_mode_enabled() {
  flagEnabled FORCE_MODE;
}

## Checks whether the -o flag is enabled
## Example:
##   if overwrite_latest_enabled; then [..]; fi
function overwrite_latest_enabled() {
  flagEnabled OVERWRITE_LATEST;
}

## Checks whether the -p flag is enabled
## Example:
##   if registry_push_enabled; then [..]; fi
function registry_push_enabled() {
  flagEnabled REGISTRY_PUSH;
}

## Checks whether the -rt flag is enabled
## Example:
##   if registry_tag_enabled; then [..]; fi
function registry_tag_enabled() {
  flagEnabled REGISTRY_TAG;
}

## Checks whether the -r flag is enabled
## Example:
##   if reduce_image_enabled; then [..]; fi
function reduce_image_enabled() {
  flagEnabled REDUCE_IMAGE;
}

## Checks whether the -cc flag is enabled.
## Example:
##   if cleanup_containers_enabled; then [..]; fi
function cleanup_containers_enabled() {
  flagEnabled CLEANUP_CONTAINERS;
}

## Cleans up the docker containers
## Example:
##   cleanup_containers
function cleanup_containers() {

  if cleanup_containers_enabled; then
    local _count="$(${DOCKER} ps -a -q | xargs -n 1 -I {} | wc -l)";
    #  _count=$((_count-1));
    if [ ${_count} -gt 0 ]; then
      logInfo -n "Cleaning up ${_count} stale container(s)";
      ${DOCKER} ps -a -q | xargs -n 1 -I {} sudo docker rm -v {} > /dev/null;
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
  flagEnabled CLEANUP_IMAGES;
}

## Cleans up unused docker images.
## Example:
##   cleanup_images
function cleanup_images() {
  if cleanup_images_enabled; then
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
  fi
}

# Main logic
function main() {
  local _repo;
  local _parents;
  local _buildRepo;
  resolve_base_image
  for _repo in ${REPOS}; do
    _buildRepo=${FALSE};
    if force_mode_enabled; then
      _buildRepo=${TRUE};
    elif ! repo_exists "${_repo}" "${TAG}"; then
      _buildRepo=${TRUE};
    else
      logInfo -n "Not building ${NAMESPACE}/${_repo}:${TAG} since it's already built";
      logInfoResult SUCCESS "skipped";
    fi
    if isTrue ${_buildRepo}; then
      find_parents "${_repo}"
      _parents="${RESULT}"
      for _parent in ${_parents}; do
        build_repo_if_defined_locally "${_parent}";
      done

      build_repo "${_repo}" "${TAG}"
    fi
    if registry_tag_enabled; then
        registry_tag "${_repo}" "${TAG}";
        if overwrite_latest_enabled; then
            registry_tag "${_repo}" "latest";
        fi
    fi
    if registry_push_enabled; then
      registry_push "${_repo}" "${TAG}";
      if overwrite_latest_enabled; then
        registry_push "${_repo}" "latest";
      fi
    fi
  done
  cleanup_containers;
  cleanup_images;
}
