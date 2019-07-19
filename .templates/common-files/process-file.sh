#!/bin/bash /usr/local/bin/dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3

# fun: replace_placeholders
# api: public
# txt: Replaces any placeholders in given file.
# opt: input: The file to process.
# opt: output:: The output file.
# txt: Returns 0/TRUE if the file is processed, 1/FALSE otherwise.
# txt: The variable RESULT contains the path of the processed file if the function returns 0/TRUE.
function replace_placeholders() {
  local _file="${1}";
  local _output="${2}";
  local -i _rescode;
  local _env="$(IFS=" \t" env | awk -F'=' '{printf("%s=\"%s\" ", $1, $2);}')";
  local _envsubstDecl=$(echo -n "'"; IFS=" \t" env | cut -d'=' -f 1 | awk '{printf("${%s} ", $0);}'; echo -n "'";);

  echo "${_env} envsubst ${_envsubstDecl} < ${_file} > ${_output}" | sh;
  _rescode=$?;

  if isTrue ${_rescode}; then
    export RESULT="${_output}";
  fi

  return ${_rescode};
}

# fun: main
# api: public
# txt: Main logic.
# txt: Retuns 0/TRUE always
# use: main
function main() {
  replace_placeholders "${INPUT_FILE}" "${OUTPUT_FILE}";
}

setScriptDescription "Processes a file, replacing any placeholders with the contents of the \
environment variables, and stores the result in the specified output file.";

addCommandLineFlag "output" "o" "The command"
addCommandLineParameter "input" "The input file" MANDATORY SINGLE;

checkReq envsubst ENVSUBST_NOT_INSTALLED;
addError INVALID_OPTION "Unrecognized option";
addError ENVSUBST_NOT_INSTALLED "envsubst is not installed";
addError NO_INPUT_FILE_SPECIFIED "The input file is mandatory";
addError NO_OUTPUT_FILE_SPECIFIED "The output file is mandatory";

function dw_parse_input_cli_parameter() {
  local _input="${1}";
  if isEmpty "${_input}"; then
    if isEmpty ${INPUT_FILE}; then
      exitWithErrorCode NO_INPUT_FILE_SPECIFIED;
    fi
  fi
}

function dw_parse_output_cli_flag() {
  local _output="$[1]";

  if isEmpty "${_output}"; then
    if isEmpty ${OUTPUT_FILE}; then
      exitWithErrorCode NO_OUTPUT_FILE_SPECIFIED;
    fi
  fi
}
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet

