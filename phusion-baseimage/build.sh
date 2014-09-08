#!/bin/bash dry-wit
# Copyright 2013-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-v[v]] [-q|--quiet] [-t|--tag tagName] [repo]
$SCRIPT_NAME [-h|--help]
(c) 2014-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3
 
Builds Docker images from templates, similar to wking's. If no repo is specified, all repositories will be built.

Where:
  * repo: the repository image to build.
  * tag: the tag to use once the image is built successfully.
EOF
}
 
# Requirements
function checkRequirements() {
  checkReq docker DOCKER_NOT_INSTALLED;
  checkReq date DATE_NOT_INSTALLED;
  checkReq realpath REALPATH_NOT_INSTALLED;
  checkReq envsubst ENVSUBST_NOT_INSTALLED;
}
 
# Environment
function defineEnv() {
  
  export AUTHOR_DEFAULT="rydnr <rydnr@acm-sl.org>";
  export AUTHOR_DESCRIPTION="The author of the image(s) to build";
  if    [ "${AUTHOR+1}" != "1" ] \
     || [ "x${AUTHOR}" == "x" ]; then
    export AUTHOR="${AUTHOR_DEFAULT}";
  fi

  export NAMESPACE_DEFAULT="rydnr";
  export NAMESPACE_DESCRIPTION="The docker registry's namespace";
  if    [ "${NAMESPACE+1}" != "1" ] \
     || [ "x${NAMESPACE}" == "x" ]; then
    export NAMESPACE="${NAMESPACE_DEFAULT}";
  fi

  export DATE_DEFAULT="$(date '+%Y%m%d')";
  export DATE_DESCRIPTION="The date used to tag images";
  if    [ "${DATE+1}" != "1" ] \
     || [ "x${DATE}" == "x" ]; then
    export DATE="${DATE_DEFAULT}";
  fi

  export MYSQL_ROOT_PASSWORD_DEFAULT="secret";
  export MYSQL_ROOT_PASSWORD_DESCRIPTION="The default password for the root user in MySQL databases";
  if    [ "${MYSQL_ROOT_PASSWORD+1}" != "1" ] \
     || [ "x${MYSQL_ROOT_PASSWORD}" == "x" ]; then
    export MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD_DEFAULT}";
  fi

  export MYSQL_ADMIN_USER_DEFAULT="admin";
  export MYSQL_ADMIN_USER_DESCRIPTION="The name of the admin user in MySQL databases";
  if    [ "${MYSQL_ADMIN_USER+1}" != "1" ] \
     || [ "x${MYSQL_ADMIN_USER}" == "x" ]; then
    export MYSQL_ADMIN_USER="${MYSQL_ADMIN_USER_DEFAULT}";
  fi

  export MYSQL_ADMIN_PASSWORD_DEFAULT="secret";
  export MYSQL_ADMIN_PASSWORD_DESCRIPTION="The default password for the admin user in MySQL databases";
  if    [ "${MYSQL_ADMIN_PASSWORD+1}" != "1" ] \
     || [ "x${MYSQL_ADMIN_PASSWORD}" == "x" ]; then
    export MYSQL_ADMIN_PASSWORD="${MYSQL_ADMIN_PASSWORD_DEFAULT}";
  fi

  export GETBOO_DB_NAME_DEFAULT="bm";
  export GETBOO_DB_NAME_DESCRIPTION="The database name for getboo schema";
  if    [ "${GETBOO_DB_NAME+1}" != "1" ] \
     || [ "x${GETBOO_DB_NAME}" == "x" ]; then
    export GETBOO_DB_NAME="${GETBOO_DB_NAME_DEFAULT}";
  fi
  
  export GETBOO_DB_USERNAME_DEFAULT="bm";
  export GETBOO_DB_USERNAME_DESCRIPTION="The name for getboo user in MySQL";
  if    [ "${GETBOO_DB_USERNAME+1}" != "1" ] \
     || [ "x${GETBOO_DB_USERNAME}" == "x" ]; then
    export GETBOO_DB_USERNAME="${GETBOO_DB_USERNAME_DEFAULT}";
  fi
  
  export GETBOO_DB_PASSWORD_DEFAULT="secret";
  export GETBOO_DB_PASSWORD_DESCRIPTION="The password for getboo user in MySQL";
  if    [ "${GETBOO_DB_PASSWORD+1}" != "1" ] \
     || [ "x${GETBOO_DB_PASSWORD}" == "x" ]; then
    export GETBOO_DB_PASSWORD="${GETBOO_DB_PASSWORD_DEFAULT}";
  fi
  
  export GETBOO_DB_TABLE_PREFIX_DEFAULT="";
  export GETBOO_DB_TABLE_PREFIX_DESCRIPTION="The prefix used for all tables in getboo database";
  if    [ "${GETBOO_DB_TABLE_PREFIX+1}" != "1" ] \
     || [ "x${GETBOO_DB_TABLE_PREFIX}" == "x" ]; then
    export GETBOO_DB_TABLE_PREFIX="${GETBOO_DB_TABLE_PREFIX_DEFAULT}";
  fi
  
  export GETBOO_DOMAIN_DEFAULT="bm.acm-sl.org";
  export GETBOO_DOMAIN_DESCRIPTION="The domain getboo will be serving";
  if    [ "${GETBOO_DOMAIN+1}" != "1" ] \
     || [ "x${GETBOO_DOMAIN}" == "x" ]; then
    export GETBOO_DOMAIN="${GETBOO_DOMAIN_DEFAULT}";
  fi

  export HTTPS_DOMAIN_DEFAULT="${GETBOO_DOMAIN}";
  export HTTPS_DOMAIN_DESCRIPTION="The https domain";
  if    [ "${HTTPS_DOMAIN+1}" != "1" ] \
     || [ "x${HTTPS_DOMAIN}" == "x" ]; then
    export HTTPS_DOMAIN="${HTTPS_DOMAIN_DEFAULT}";
  fi

  ENV_VARIABLES=(\
    AUTHOR \
    NAMESPACE \
    MYSQL_ROOT_PASSWORD \
    MYSQL_ADMIN_USER \
    MYSQL_ADMIN_PASSWORD \
    GETBOO_DB_NAME \
    GETBOO_DB_USERNAME \
    GETBOO_DB_PASSWORD \
    GETBOO_DB_TABLE_PREFIX \
    GETBOO_DOMAIN \
    HTTPS_DOMAIN \
  );

 
  export ENV_VARIABLES;
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

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    DOCKER_NOT_INSTALLED \
    DATE_NOT_INSTALLED \
    REALPATH_NOT_INSTALLED \
    ENVSUBST_NOT_INSTALLED \
    NO_REPOSITORIES_FOUND \
    INVALID_URL \
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

# Does "${NAMESPACE}/${REPO}:${TAG}" exist?
# Returns 0 (exists) or 1 (missing).
#
# Arguments:
#
# 1: REPO
function repo_exists() {
  local _repo="${1}"
  local _images=$("${DOCKER}" images "${NAMESPACE}/${_repo}")
  local _matches=$(echo "${_images}" | grep "${TAG}")
  local _rescode;
  if [ -z "${MATCHES}" ]; then
    _rescode=1
  else
    _rescode=0
  fi

  return ${_rescode};
}

function repo_exists() {
  local _repo="${1}"


  for f in ${_repo}/*.template; do
    echo env -i \
      $(for ((i = 0; i < ${#ENV_VARIABLES[*]}; i++)); do
        echo ${ENV_VARIABLES[$i]} | awk -v dollar="$" -v quote="\"" '{printf("echo %s=%s%s{%s}%s ", $0, quote, dollar, $0, quote);}' | sh;
      done) \
      envsubst \
        ${ENV_VARIABLES[*]} \
      \
    < "${f}" > "${_repo}/$(basename ${f} .template)"
  done
  echo "build ${NAMESPACE}/${_repo}:${TAG}"
  echo docker build ${BUILD_OPTS} -t "${NAMESPACE}/${_repo}:${TAG}" --rm=true "${_repo}" || die "failed to build"
  echo "tag ${NAMESPACE}/${_repo}:latest"
  echo docker tag -f "${NAMESPACE}/${_repo}:${TAG}" "${NAMESPACE}/${_repo}:latest" || die "failed to tag"
}

function main() {
  local _repo;
  for _repo in ${REPOS}; do
    if ! repo_exists "${_repo}"; then
      buildRepo "_repo"
    fi
  done
}
