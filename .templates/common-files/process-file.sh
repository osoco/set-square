#!/bin/bash dry-wit
# Copyright 2016-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3
# mod: common
# api: public
# txt: Processes a file, replacing any placeholders with the contents of the environment variables, and stores the result in the specified output file.

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

  checkNotEmpty file "${_file}" 1;
  checkNotEmpty output "${_output}" 2;

  local _env="$(IFS=" \t" env | awk -F'=' '{printf("%s=\"%s\" ", $1, $2);}')";
  replaceVariablesInFile "${_file}" "${_output}" ${_env};
}

# fun: main
# api: public
# txt: Main logic.
# txt: Retuns 0/TRUE always
# use: main
function main() {
  replace_placeholders "${INPUT_FILE}" "${OUTPUT_FILE}";
}

## Script metadata and CLI options
setScriptDescription "Processes a file, replacing any placeholders with the contents of the \
environment variables, and stores the result in the specified output file.";

addCommandLineFlag "output" "o" "The command"
addCommandLineParameter "input" "The input file" MANDATORY SINGLE;

checkReq envsubst;
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
