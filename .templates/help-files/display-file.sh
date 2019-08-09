#!/bin/bash dry-wit
# mod: help/display-file
# api: public
# txt: Displays a file.

# fun: main
# api: public
# txt: Displays a file.
# txt: Returns 0/TRUE if the file exists and could be read; 1/FALSE otherwise.
# use: main
function main() {
  if fileExists "${FILE}"; then
    cat ${FILE};
  else
    exitWithErrorCode FILE_DOES_NOT_EXIST "${FILE}";
  fi
}

## Script metadata and CLI settings.
setScriptDescription "Displays a file";
addCommandLineParameter "file" "The file to display" MANDATORY SINGLE;

# Callback to check the file parameter.
function dw_check_file_cli_parameter() {
  if ! fileExists "${1}"; then
    exitWithErrorCode FILE_DOES_NOT_EXIST "${1}";
  fi
}

# Callback to parse the file parameter.
function dw_parse_file_cli_parameter() {
  export FILE="${1}";
}
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
