defineEnvVar SERVICE_USER "The service user" "setsquare";
defineEnvVar SERVICE_GROUP "The service group" "users";
defineEnvVar SERVICE_USER_HOME 'The home of ${SERVICE_USER} user' '/home/${SERVICE_USER}';
defineEnvVar SERVICE_USER_SHELL 'The shell of ${SERVICE_USER} user' '/bin/bash';
