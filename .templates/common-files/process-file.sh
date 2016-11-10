#!/bin/bash /usr/local/bin/dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

function usage() {
cat <<EOF
$SCRIPT_NAME -o|--output output input
$SCRIPT_NAME [-h|--help]
(c) 2016-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

Processes a file, replacing any placeholders with the contents of the
environment variables, and stores the result in the specified output file.

Where:
    * input: the input file.
    * output: the output file.
Common flags:
    * -h | --help: Display this message.
    * -v: Increase the verbosity.
    * -vv: Increase the verbosity further.
    * -q | --quiet: Be silent.
EOF
}

# Requirements
function checkRequirements() {
  checkReq envsubst ENVSUBST_NOT_INSTALLED;
}
 
# Error messages
function defineErrors() {
  export INVALID_OPTION="Unrecognized option";
  export ENVSUBST_NOT_INSTALLED="envsubst is not installed";
  export NO_INPUT_FILE_SPECIFIED="The input file is mandatory";
  export NO_OUTPUT_FILE_SPECIFIED="The output file is mandatory";

  ERROR_MESSAGES=(\
    INVALID_OPTION \
    ENVSUBST_NOT_INSTALLED \
    NO_INPUT_FILE_SPECIFIED \
    NO_OUTPUT_FILE_SPECIFIED \
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
      -h | --help | -v | -vv | -q)
         shift;
         ;;
      -o | --output)
         shift;
         OUTPUT_FILE="${1}";
         shift;
         ;;
    esac
  done

  # Parameters
  if [[ -z ${INPUT_FILE} ]]; then
    INPUT_FILE="$1";
    shift;
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
      -h | --help | -v | -vv | -q | --quiet)
         ;;
      -o | --output)
         ;;
      *) logDebugResult FAILURE "fail";
         exitWithErrorCode INVALID_OPTION ${_flag};
         ;;
    esac
  done

  if [[ -z ${INPUT_FILE} ]]; then
    logDebugResult FAILURE "fail";
    exitWithErrorCode NO_INPUT_FILE_SPECIFIED;
  fi

  if [[ -z ${OUTPUT_FILE} ]]; then
      logDebugResult FAILURE "fail";
      exitWithErrorCode NO_OUTPUT_FILE_SPECIFIED;
  fi
}

## Replaces any placeholders in given file.
## -> 1: The file to process.
## -> 2: The output file.
## <- 0 if the file is processed, 1 otherwise.
## <- RESULT: the path of the processed file.
function replace_placeholders() {
  local _file="${1}";
  local _output="${2}";
  local _rescode;
  local _env="$(IFS=" \t" env | awk -F'=' '{printf("%s=\"%s\" ", $1, $2);}')";
  local _envsubstDecl=$(echo -n "'"; IFS=" \t" env | cut -d'=' -f 1 | awk '{printf("${%s} ", $0);}'; echo -n "'";);

  echo "${_env} envsubst ${_envsubstDecl} < ${_file} > ${_output}" | sh;
  _rescode=$?;
  export RESULT="${_output}";
  return ${_rescode};
}

## Main logic
## dry-wit hook
function main() {
  replace_placeholders "${INPUT_FILE}" "${OUTPUT_FILE}";
}
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
