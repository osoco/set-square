#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-np|--no-pin] package [package]*
$SCRIPT_NAME [-h|--help]
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Installs packages via apt-get, so that their impact in the
overall image size is better. It requires the Dockerfile to install
packages using this script, and afterwards call aptget-cleanup.sh
to remove unnecessary dependencies. 

Where:
  * package: the package(s) to install.
  * -np | --no-pin: Do not pin the package.
Common flags:
    * -h | --help: Display this message.
    * -X:e | --X:eval-defaults: whether to eval all default values, which potentially slows down the script unnecessarily.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Declares the requirements.
## dry-wit hook
function checkRequirements() {
  checkReq apt-get APTGET_NOT_AVAILABLE;
  checkReq apt-mark APTMARK_NOT_AVAILABLE;
}

## Defines the errors.
## dry-wit hook
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export APTGET_NOT_AVAILABLE="apt-get not found";
  export APTMARK_NOT_AVAILABLE="apt-mark not found";
  export NO_PACKAGES_SPECIFIED="No packages specified";
  export CANNOT_WRITE_TO_INSTALLED_PACKAGES_FILE='Cannot write to ';
  export ERROR_INSTALLING_PACKAGE="Error installing ";
  export ERROR_PINNING_PACKAGE='Error pinning ';

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    APTGET_NOT_AVAILABLE \
    APTMARK_NOT_AVAILABLE \
    NO_PACKAGES_SPECIFIED \
    CANNOT_WRITE_TO_INSTALLED_PACKAGES_FILE \
    ERROR_INSTALLING_PACKAGE \
    ERROR_PINNING_PACKAGE \
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
      -h | --help | -v | -vv | -q | -X:e | --X:eval-defaults | -np | --no-pin)
         shift;
         ;;
      *) logDebugResult FAILURE "failed";
         exitWithErrorCode INVALID_OPTION;
         ;;
    esac
  done

  if [[ -z ${PACKAGES} ]]; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode NO_PACKAGES_SPECIFIED;
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
      -h | --help | -v | -vv | -q | -X:e | --X:eval-defaults)
        shift;
        ;;
      -np | --no-pin)
        export NO_PIN=0;
        shift
        ;;
    esac
  done

  if [[ -z ${PACKAGES} ]]; then
    PACKAGES="$@";
  fi  
}

## Updates the system via apt-get update
## Example:
##   update_system
function update_system() {
  logInfo -n "Updating system (this can take some time)";
  ${APTGET_UPDATE} > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi
}

## Checks the ${INSTALLED_PACKAGES_FILE} is writeable
## Example:
##   check_packages_file_writeable
function check_packages_file_writeable() {
  logDebug -n "Checking if ${INSTALLED_PACKAGES_FILE} is writeable";
  if fileIsWriteable "${INSTALLED_PACKAGES_FILE}"; then
    logDebugResult SUCCESS "true";
  else
    logDebugResult SUCCESS "false";
    exitWithErrorCode CANNOT_WRITE_TO_INSTALLED_PACKAGES_FILE ${INSTALLED_PACKAGES_FILE};
  fi
}

## Checks whether the -np flag is enabled
## Example:
##   if no_pin_enabled; then [..]; fi
function no_pin_enabled() {
  _flagEnabled NO_PIN;
}

## Installs a package.
## -> 1: the package to install
## Example:
##   install_package wget
function install_package() {
  local _package="${1}";
  logInfo -n "Installing ${_package}";
  grep -e "^${_package}$" ${INSTALLED_PACKAGES_FILE} > /dev/null
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "skipped";
  else
    ${APTGET_INSTALL} ${_package} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      echo "${_package}" >> ${INSTALLED_PACKAGES_FILE}
      logInfoResult SUCCESS "done";
    else
      logInfoResult FAILURE "failed";
      exitWithErrorCode ERROR_INSTALLING_PACKAGE "${_package}";
    fi
  fi
}

## Marks a package as sticky, so that it doesn't
## get automatically removed assuming it's not used.
## -> 1: the package to pin
## Example:
##   pin_package wget
function pin_package() {
  local _package="${1}";
  logInfo -n "Pinning ${_package}";
  ${HOLD_PACKAGE} ${_package} > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
    exitWithErrorCode ERROR_PINNING_PACKAGE "${_package}";
  fi
}
    
## Main logic
## dry-wit hook
function main() {
  local _package;
  update_system;

  check_packages_file_writeable;
  
  for _package in ${PACKAGES}; do
    install_package "${_package}";
    if ! no_pin_enabled; then
      pin_package "${_package}";
    fi
  done
}
