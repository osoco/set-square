defineEnvVar FIREFOX_SYNC_DOMAIN "The Firefox-Sync domain" "firefox-sync.example.com";
defineEnvVar FIREFOX_SYNC_SECRET "The secret string for the Firefox Sync server" "secret" "${RANDOM_PASSWORD}";
defineEnvVar FIREFOX_SYNC_DB_NAME "The Firefox-Sync database name" "firefoxsync";
defineEnvVar FIREFOX_SYNC_DB_USER "The username to connect to the Firefox Sync database" "firefoxsync";
defineEnvVar FIREFOX_SYNC_DB_PASSWORD "The password of the Firefox Sync database user" "secret" "${RANDOM_PASSWORD}";
