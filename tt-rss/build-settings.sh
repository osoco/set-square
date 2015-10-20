defineEnvVar TTRSS_VIRTUAL_HOST "The virtual host of the tt-rss installation" "rss.acm-sl.org";
defineEnvVar TTRSS_DB_NAME "The database name" "ttrss";
defineEnvVar TTRSS_DB_USER "The database user" "ttrss";
defineEnvVar TTRSS_DB_PASSWORD "The database password" '${RANDOM_PASSWORD}';
defineEnvVar TTRSS_MYSQL_CHARSET "Connection charset for MySQL" "UTF8";
defineEnvVar TTRSS_FEED_CRYPT_KEY "The crypt key for password-protected feeds in the database. 24 characters" '${RANDOM_PASSWORD}';
defineEnvVar TTRSS_SINGLE_USER_MODE "Whether to run TTRSS in single-user mode" "false";
defineEnvVar TTRSS_SIMPLE_UPDATE_MODE "Enables fallbark update mode where tt-rss tries to update feeds in background while tt-rss is open in your browser" "false";
defineEnvVar TTRSS_AUTH_AUTO_CREATE "Allow authentication modules to auto-create users in tt-rss database when authenticated successfully" "true";
defineEnvVar TTRSS_AUTH_AUTO_LOGIN "Automatically login user on remote or other kind of externally supplied authentication, otherwise redirect to login form as normal. If set to true, users won't be able to set application language and settings profile" "true";
defineEnvVar TTRSS_FORCE_ARTICLE_PURGE "When this option is not 0, users' ability to control feed purging intervals is disabled and all articles (not starred), older than this number of days, are purged" 0;
defineEnvVar TTRSS_PUBSUBHUBBUB_HUB "URL to a PubSubHubbub-compatible hub server. If defined, \"Published articles\" generated feed would automatically become PUSH-enabled" '';
defineEnvVar TTRSS_PUBSUBHUBBUB_ENABLED "Enable client PubSubHubbub support in tt-rss. When disabled, tt-rss won't try to subscribe to PUSH feed updates" "false";
defineEnvVar TTRSS_ENABLE_REGISTRATION "Allow users to register themselves" "false";
defineEnvVar TTRSS_REG_NOTIFY_ADDRESS "Email address to send new user notifications to" '${TTRSS_DB_USER}@${TTRSS_VIRTUAL_HOST}';
defineEnvVar TTRSS_REG_MAX_USERS "Maximum amount of users which will be allowed to register on this system. 0 - no limit" 10;
defineEnvVar TTRSS_SESSION_COOKIE_LIFETIME "Lifetime of session cookies. 0 means cookie will be deleted when browser closes" 86400;
defineEnvVar TTRSS_SMTP_FROM_NAME "Name used when sending mails" "Tiny Tiny RSS";
defineEnvVar TTRSS_SMTP_FROM_ADDRESS "The email used to send emails" 'noreply@${TTRSS_VIRTUAL_HOST}';
defineEnvVar TTRSS_DIGEST_SUBJECT "Subject line for email digests" "[tt-rss] New headlines for last 24 hours";
defineEnvVar TTRSS_SMTP_SERVER "Hostname:port combination to send outgoing mail. Blank = use system MTA" '';
defineEnvVar TTRSS_SMTP_LOGIN "The login required to send emails through the SMTP server, if any" '';
defineEnvVar TTRSS_SMTP_PASSWORD "The password required to send emails" '';
defineEnvVar TTRSS_SMTP_SECURE "Used to select a secure SMTP connection. One of ssl, tls, or empty" '';
defineEnvVar TTRSS_CHECK_FOR_UPDATES "Check for updates automatically" "true";
defineEnvVar TTRSS_ENABLE_GZIP_OUTPUT "Selectively gzip output to improve wire performance" false;
defineEnvVar TTRSS_PLUGINS "Comma-separated list of plugins to load automatically for all users" "auth_internal, note";
defineEnvVar TTRSS_LOG_DESTINATION "Log destination to use. Possible values: sql (uses internal logging you can read in Preferences -> System), syslog - logs to system log. Setting this to blank uses PHP logging (usually to http server error.log)" "sql";






