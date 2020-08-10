#!/bin/bash dry-wit
# mod: help/display-dockerfile
# api: public
# txt: Displays a Dockerfile.

# fun: main
# api: public
# txt: Displays a Dockerfile.
# txt: Always returns 0/TRUE.
# use: main my-dockerfile
function main() {
  if isNotEmpty "${FILE}" && fileExists "/Dockerfiles/${FILE}"; then
    cat "/Dockerfiles/${FILE}";
  else
    cat /Dockerfiles/Dockerfile;
  fi
}

## Script metadata and CLI settings.
setScriptDescription "Displays a Dockerfile";
addCommandLineParameter "file" "The Dockerfile to display" OPTIONAL SINGLE "";

# Callback to parse the file parameter.
function dw_parse_file_cli_parameter() {
  export FILE="${1}";
}
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
