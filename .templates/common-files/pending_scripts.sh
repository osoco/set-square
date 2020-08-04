#!/bin/bash dry-wit
# Copyright 2014-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3
# mod: pending_[type]_scripts.sh
# api: public
# txt: Detects pending scripts, and runs them.

# fun: main
# api: public
# txt: Detects pending scripts, and runs them.
# txt: Returns 0/TRUE always, but can exit in case of error.
# use: main
function main() {
  if find_pending_scripts; then
    local _scripts="${RESULT}";

    local _oldIFS="${IFS}";
    local _script;
    IFS="${DWIFS}";
    for _script in ${_scripts}; do
      IFS="${_oldIFS}";
      if run_script "${_script}"; then
        mark_script_as_done "${_script}";
      fi
    done;
    IFS="${_oldIFS}";
  fi
}

# fun: find_pending_scripts
# api: public
# txt: Retrieves the pending scripts.
# txt: Returns 0/TRUE if there're any script still pending; 1/FALSE otherwise.
# txt: If the function returns 0/TRUE, the variable RESULT contains the pending scripts.
# use: if find_pending_scripts; then
# use:   echo "Pending scripts: ${RESULT}";
# use: fi
function find_pending_scripts() {
  local _candidates="$(find "${PENDING_SCRIPTS_FOLDER}" -maxdepth 1 | grep -v -e "^${PENDING_SCRIPTS_FOLDER}$" | sort)";

  local _result="";
  local -i _rescode=${FALSE};

  local _oldIFS="${IFS}";
  local _candidate;
  IFS="${DWIFS}";
  for _candidate in ${_candidates}; do
    IFS="${_oldIFS}";
    if   isExecutable "${_candidate}" \
      && ! endsWith "${_candidate}" ".inc.sh" \
      && ! already_done "${_candidate}"; then
      _rescode=${TRUE};

      if isNotEmpty "${_result}"; then
        _result="${_result} ";
      fi
      _result="${_result}${_candidate}";
    fi
  done;
  IFS="${_oldIFS}";

  if isTrue ${_rescode}; then
    export RESULT="${_result}";
  fi

  return ${_rescode};
}

# fun: already_done script
# api: public
# txt: Checks whether given script is already done or not.
# opt: script: The script.
# txt: Returns 0/TRUE if the script is already done; 1/FALSE otherwise.
# use: if already_done /var/local/src/[type]/00-myuser.sh; then
# use:   echo "00-myuser.sh already applied";
# use: fi
function already_done() {
  local _script="${1}";
  checkNotEmpty script "${_script}" 1;

  local -i _rescode=${FALSE};

  local _basename="$(basename "${_script}")";
  if fileExists "${DONE_SCRIPTS_FOLDER}/${_basename}.done"; then
    _rescode=${TRUE};
  fi

  return ${_rescode};
}

# fun: mark_script_as_done script
# api: public
# txt: Marks given script as done.
# opt: script: The script.
# txt: Returns 0/TRUE if the script is marked as done successfully; 1/FALSE otherwise.
# use: if mark_script_as_done /var/local/src/[type]/00-myuser.sh; then
# use:   echo "00-myuser.sh annotated as done";
# use: fi
function mark_script_as_done() {
  local _script="${1}";
  checkNotEmpty script "${_script}" 1;

  local -i _rescode=${FALSE};

  local _basename="$(basename "${_script}")";
  touch "${DONE_SCRIPTS_FOLDER}/${_basename}.done" 2> /dev/null;

  if fileExists "${DONE_SCRIPTS_FOLDER}/${_basename}.done"; then
    _rescode=${TRUE};
  fi

  return ${_rescode};
}

# fun: run_script script
# api: public
# txt: Runs given script.
# opt: script: The script to run.
# txt: Returns the return code of the script itself.
# use: if run_script /var/local/src/[type]/00-myuser.sh; then
# use:   echo "00-myuser.sh returned 0";
# use: fi
function run_script() {
  local _script="${1}";
  checkNotEmpty script "${_script}" 1;

  "${_script}" -v;
}

# script metadata
setScriptDescription "Detects pending scripts, and runs them.";

DW.getScriptName;
# env: TYPE: The type of the scripts: rabbitmq, mongodb, etc. Defaults to basename ${0} .sh | sed 's/^.*_\(.*\)_.*$/\1/g'
defineEnvVar TYPE MANDATORY "The type of the scripts: rabbitmq, mongodb, etc." "$(basename ${RESULT} .sh | sed 's/^.*_\(.*\)_.*$/\1/g')";
# env: PENDING_SCRIPTS_FOLDER: The folder with the pending scripts.
defineEnvVar PENDING_SCRIPTS_FOLDER MANDATORY "The folder with the pending scripts" "/backup/${TYPE}/changesets";
# env: DONE_SCRIPTS_FOLDER: The folder with the scripts already executed.
defineEnvVar DONE_SCRIPTS_FOLDER MANDATORY "The folder with the scripts already executed" "/backup/${TYPE}/changesets";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
