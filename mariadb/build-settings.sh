defineEnvVar MARIADB_ROOT_PASSWORD "The password for the root user" "secret" "${RANDOM_PASSWORD}";
defineEnvVar MARIADB_ADMIN_USER "The admin user" "admin";
defineEnvVar MARIADB_ADMIN_PASSWORD "The password for the admin user" "secret" "${RANDOM_PASSWORD}";
