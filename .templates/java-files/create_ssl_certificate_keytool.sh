#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Creates a SSL certificate.
See http://www.eclipse.org/jetty/documentation/current/configuring-ssl.html

Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Defines required dependencies
## dry-wit hook
function defineReq() {
  checkReq keytool KEYTOOL_NOT_AVAILABLE;
}

## Defines the errors
## dry-wit hook
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export KEYTOOL_NOT_AVAILABLE="keytool is not installed";
  export CANNOT_SIGN_SSL_CERTIFICATE="Cannot sign the SSL certificate";
  export CANNOT_UPDATE_KEYSTORE_FOLDER_PERMISSIONS="Cannot update the permissions of ${SSL_KEYSTORE_FOLDER}";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    KEYTOOL_NOT_AVAILABLE \
    CANNOT_SIGN_SSL_CERTIFICATE \
    CANNOT_UPDATE_KEYSTORE_FOLDER_PERMISSIONS \
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
      -h | --help | -v | -vv | -q)
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
      -h | --help | -v | -vv | -q)
         shift;
         ;;
    esac
  done
}

## Generates and signs a new certificate.
function generateAndSignCertificate() {

  # See https://stackoverflow.com/questions/33827789/self-signed-certificate-dnsname-components-must-begin-with-a-letter

  logInfo -n "Signing the SSL certificate";
  keytool -keystore "${SSL_KEYSTORE_PATH}" \
          -alias "${SSL_CERTIFICATE_ALIAS}" \
          -genkey \
          -noprompt \
          -dname "${SSL_CERTIFICATE_DNAME}" \
          -keyalg "${SSL_KEY_ALGORITHM}" \
          -keypass "${SSL_KEY_PASSWORD}" \
          -storepass "${SSL_KEYSTORE_PASSWORD}" \
          -storetype "${SSL_KEYSTORE_TYPE}" \
          -keysize ${SSL_KEY_LENGTH} \
          -validity ${SSL_CERTIFICATE_EXPIRATION_DAYS} \
          -sigalg "${SSL_JAVA_SIGN_ALGORITHM}";
#          -ext "SAN=${SSL_SAN_EXTENSIONS}";

  if isTrue $?; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
    echo keytool -keystore "${SSL_KEYSTORE_PATH}" \
            -alias "${SSL_CERTIFICATE_ALIAS}" \
            -genkey \
            -noprompt \
            -dname "${SSL_CERTIFICATE_DNAME}" \
            -keyalg "${SSL_KEY_ALGORITHM}" \
            -keypass "${SSL_KEY_PASSWORD}" \
            -storepass "${SSL_KEYSTORE_PASSWORD}" \
            -storetype "${SSL_KEYSTORE_TYPE}" \
            -keysize ${SSL_KEY_LENGTH} \
            -validity ${SSL_CERTIFICATE_EXPIRATION_DAYS} \
            -sigalg "${SSL_JAVA_SIGN_ALGORITHM}";
    #          -ext "SAN=${SSL_SAN_EXTENSIONS}";
    exitWithErrorCode CANNOT_SIGN_SSL_CERTIFICATE;
  fi

  export RESULT="${_result}";
}

## Changes the permissions of given folder.
## -> 1: The folder to update.
## -> 2: The user.
## -> 3: The group.
function updateFolderPermissions() {
  local _dir="${1}";
  local _user="${2}";
  local _group="${3}";

  logInfo -n "Fixing permissions of ${_dir}";

  chown -R ${_user}:${_group} ${_dir};

  if isTrue $?; then
      logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
    exitWithErrorCode CANNOT_UPDATE_KEYSTORE_FOLDER_PERMISSIONS;
  fi

}

## Main logic
## dry-wit hook
function main() {
  generateAndSignCertificate;
  updateFolderPermissions "${SSL_KEYSTORE_FOLDER}" "${SERVICE_USER}" "${SERVICE_GROUP}";
}

