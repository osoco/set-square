defineEnvVar TTRSS_VIRTUAL_HOST "The virtual host of the tt-rss installation" "rss.acm-sl.org";
defineEnvVar TTRSS_DB_NAME "The database name" "ttrss";
defineEnvVar TTRSS_DB_USER "The database user" "ttrss";
defineEnvVar TTRSS_DB_PASSWORD "The database password" '${RANDOM_PASSWORD}';
