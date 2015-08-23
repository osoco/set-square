defineEnvVar GETBOO_VERSION "The getboo version" "1.04";
defineEnvVar GETBOO_DB_TABLE_PREFIX "The prefix for getboo tables" "";
defineEnvVar GETBOO_DB_NAME "The getboo database name" "getboo";
defineEnvVar GETBOO_DB_USERNAME "The getboo database user" "getboo";
defineEnvVar GETBOO_DB_PASSWORD "The password for the getboo database user" "secret" "${RANDOM_PASSWORD}";
defineEnvVar GETBOO_ADMIN_USERNAME "The getboo admin user" "admin";
defineEnvVar GETBOO_ADMIN_PASSWORD "The getboo admin password" "secret" "${RANDOM_PASSWORD}";
defineEnvVar GETBOO_DEFAULT_LANGUAGE "The default language for getboo" "en_US";
defineEnvVar GETBOO_DOMAIN "The getboo domain" "http://getboo.example.com";
defineEnvVar GETBOO_HTTPS_DOMAIN "The https domain" 'https://getboo.example.com';
defineEnvVar GETBOO_ADMIN_EMAIL "The admin email for getboo" 'admin-getboo@${GETBOO_DOMAIN}';
defineEnvVar GETBOO_FOLDER \
             "The GetBoo folder" \
             'getboo.${GETBOO_VERSION}';
defineEnvVar GETBOO_FILE \
             "The GetBoo artifact" \
             '${GETBOO_FOLDER}.zip';
defineEnvVar GETBOO_DOWNLOAD_URL \
             "The url to download GetBoo" \
             'http://downloads.sourceforge.net/project/getboo/getboo/${GETBOO_VERSION}/${GETBOO_FILE}';
defineEnvVar GETBOO_HOME \
             "The home folder for GetBoo" \
             "/usr/local/src";
defineEnvVar APACHE_USER \
             "The Apache user" \
             "www-data";
defineEnvVar APACHE_GROUP \
             "The Apache group" \
             "www-data";
