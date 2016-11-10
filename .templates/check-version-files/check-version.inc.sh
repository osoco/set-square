_aux="$(basename ${SCRIPT_NAME} .sh)";
_aux="$(basename ${_aux} .inc)";
_name="${_aux#check-version-}";
defineEnvVar LOCAL_VERSION_SCRIPT "The script to check the local version" "/usr/local/bin/local-version-${_name}.sh";
defineEnvVar REMOTE_VERSION_SCRIPT "The script to check the remote version" "/usr/local/bin/local-version-${_name}.sh";
