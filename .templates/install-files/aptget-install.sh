#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME [-u|--update] [-np|--no-pin] package [package]*
$SCRIPT_NAME [-h|--help]
(c) 2015-today ACM-SL
    Distributed this under the GNU General Public License v3.

Installs packages via apt-get, so that their impact in the
overall image size is better. It requires the Dockerfile to install
packages using this script, and afterwards call aptget-cleanup.sh
to remove unnecessary dependencies.

Where:
  * package: the package(s) to install.
  * -u | --update: Update the system before installing anything.
  * -np | --no-pin: Do not pin the package.
Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

## Declares the requirements.
## dry-wit hook
function checkRequirements() {
  checkReq apt-get;
  checkReq apt-mark;
}

## Defines the errors.
## dry-wit hook
function defineErrors() {
  addError "INVALID_OPTION" "Unrecognized option";
  addError "APTGET_NOT_INSTALLED" "apt-get not found";
  addError "APTMARK_NOT_INSTALLED" "apt-mark not found";
  addError "NO_PACKAGES_SPECIFIED" "No packages specified";
  addError "CANNOT_WRITE_TO_INSTALLED_PACKAGES_FILE" 'Cannot write to ';
  addError "ERROR_INSTALLING_PACKAGE" "Error installing ";
  addError "ERROR_PINNING_PACKAGE" 'Error pinning ';
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
    logTrace -n "Checking ${_flag}";
    _flagCount=$((_flagCount+1));
    case ${_flag} in
      -h | --help | -v | -vv | -q | -u | --update | -np | --no-pin)
         logTraceResult SUCCESS "${_flag}";
         shift;
         ;;
      *) logTraceResult FAILURE "${_flag}";
         ;;
    esac
  done

  if [[ -z "${PACKAGES}" ]]; then
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
      -h | --help | -v | -vv | -q )
        shift;
        ;;
      -u | --update)
        export UPDATE=TRUE;
        shift
        ;;
      -np | --no-pin)
          export NO_PIN=TRUE;
          shift
          ;;
      *)
          export EXTRA_ARGS="${EXTRA_ARGS} ${_flag}";
          shift
    esac
  done

  if isEmpty "${PACKAGES}"; then
    PACKAGES="$@";
  fi
}

## Updates the system via apt-get update
## <- 0 if the system gets updated; 1 otherwise.
## Example:
##   if ! update_system; then
##     echo "Error updating system"
##   fi
function update_system() {
  local _rescode;
  logInfo -n "Updating system (this can take some time)";
  ${APTGET_UPDATE} > /dev/null 2>&1
  _rescode=$?;
  if isTrue ${_rescode}; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
  fi
  return ${_rescode};
}

## Checks the ${INSTALLED_PACKAGES_FILE} is writeable
## Example:
##   check_packages_file_writeable
function check_packages_file_writeable() {
  logDebug -n "Checking if ${INSTALLED_PACKAGES_FILE} is writeable";
  if fileIsWriteable "${INSTALLED_PACKAGES_FILE}"; then
    logDebugResult SUCCESS "true";
  else
    logDebugResult FAILURE "false";
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
  local -i _aux;

  logInfo -n "Checking if ${_package} is already installed";
  grep -e "^${_package}$" ${INSTALLED_PACKAGES_FILE} > /dev/null
  if isTrue $?; then
    logInfoResult SUCCESS "true";
  else
    logInfoResult SUCCESS "false";
    logInfo "Installing ${_package}";
    runCommandLongOutput "apt-get install -y ${EXTRA_ARGS} --no-install-recommends ${_package}"
    _aux=$?;
    logInfo -n "Installing ${_package}";
    if isTrue ${_aux}; then
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
  if isTrue $?; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
    exitWithErrorCode ERROR_PINNING_PACKAGE "${_package} ($(${HOLD_PACKAGE} ${_package}))";
  fi
}

## Main logic
## dry-wit hook
function main() {
  local _package;
  if isTrue ${UPDATE}; then
    update_system;
  fi

  check_packages_file_writeable;

  for _package in ${PACKAGES}; do
    install_package "${_package}";
    if ! no_pin_enabled; then
      pin_package "${_package}";
    fi
  done
}
