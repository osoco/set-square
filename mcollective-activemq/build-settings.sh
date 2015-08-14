defineEnvVar MCOLLECTIVE_ACTIVEMQ_PORT "The ActiveMQ port" "61613";
defineEnvVar MCOLLECTIVE_ACTIVEMQ_CLIENT_PASSWORD "The password for the ActiveMQ client" "secret" "${RANDOM_PASSWORD}";
defineEnvVar MCOLLECTIVE_ACTIVEMQ_SERVER_PASSWORD "The password for the ActiveMQ server" "secret" "${RANDOM_PASSWORD}";
defineEnvVar MCOLLECTIVE_ACTIVEMQ_PRE_SHARED_KEY "The pre-shared key for ActiveMQ" "secret" "${RANDOM_PASSWORD}";
