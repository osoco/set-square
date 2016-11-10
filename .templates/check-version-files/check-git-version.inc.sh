_aux="$(basename ${SCRIPT_NAME} .sh)";
_aux="$(basename ${_aux} .inc)";
_name="${_aux#check-version-}";
defineEnvVar REPOSITORY_NAME "The name of the repository" "${_name}";
defineEnvVar LOCAL_REPOSITORY "The local repository" '/opt/${REPOSITORY_NAME}';
