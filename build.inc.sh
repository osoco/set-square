defineEnvVar AUTHOR "The author of the image(s) to build" "me";
defineEnvVar DOMAIN "The domain" "example.com";
defineEnvVar AUTHOR_EMAIL "The author's email" 'me@${DOMAIN}';
defineEnvVar NAMESPACE "The docker registry's namespace" "example";
defineEnvVar DATE "The date format used to tag images" "$(date '+%Y%m')";
defineEnvVar TIME "A timestamp" "$(date)";
defineEnvVar ROOT_IMAGE_VERSION "The root image version" "0.9.18";
defineEnvVar ROOT_IMAGE_64BIT "The default root image for 64 bits" "phusion/baseimage"
defineEnvVar RANDOM_PASSWORD \
             "A random password" \
             "secret" \
             'head -c 20 /dev/urandom | sha1sum | cut -d' ' -f1';
defineEnvVar ROOT_IMAGE_32BIT "The default root image for 32 bits" "${ROOT_IMAGE_64BIT_DEFAULT}32";
defineEnvVar BASE_IMAGE_64BIT "The base image for 64 bits" '${NAMESPACE}/base';
defineEnvVar BASE_IMAGE_32BIT "The base image for 32 bits" '${BASE_IMAGE_64BIT_DEFAULT%%64}32';
defineEnvVar REGISTRY "The registry to push Docker images to" "tutum.co";
defineEnvVar REGISTRY_NAMESPACE \
             "The namespace under the registry where the image is to be uploaded" \
             '${NAMESPACE}';
defineEnvVar JAVA_VERSION "The Java version" "8";
defineEnvVar APTGET_INSTALL \
             "Installs a program via apt-get" \
             '/usr/local/bin/aptget-install.sh -vv ';
defineEnvVar APTGET_CLEANUP \
             "The cleanup commands after an apt-get so that the resulting image size is optimal" \
             '/usr/local/bin/aptget-cleanup.sh -v ';
defineEnvVar SMTP_HOST \
             "The SMTP host to send emails, including monit's" \
             'mail.${DOMAIN}';
defineEnvVar LDAP_HOST \
             "The LDAP host to authorize and/or authenticate users" \
             'ldap.${DOMAIN}';
defineEnvVar BACKUP_HOST_SUFFIX \
             "The prefix of the backup host to send the backup files" \
             '-backup.${DOMAIN}';
defineEnvVar BACKUP_USER "The backup user" "backup";
defineEnvVar SSHPORTS_FILE \
             "The file with the SSH port mappings" \
             "sshports.txt";
defineEnvVar CUSTOM_BACKUP_SCRIPTS_FOLDER \
             "The folder with the custom backup scripts" \
             "/usr/local/bin";
defineEnvVar CUSTOM_BACKUP_SCRIPTS_PREFIX "The prefix of all custom backup scripts" "backup-";
defineEnvVar BACKUP_USER "The backup user" "backup";
defineEnvVar BACKUP_GROUP "The backup group" '${BACKUP_USER}';
defineEnvVar MONIT_HTTP_PORT \
             "The port used by Monit's webapp" \
             "2812";
defineEnvVar MONIT_HTTP_USER \
             "The user to login in monit's webapp" \
             "monit";
defineEnvVar MONIT_HTTP_PASSWORD \
             "The password to login in monit's webapp" \
             '${RANDOM_PASSWORD}' \
             "head -c 20 /dev/urandom | sha1sum | cut -d' ' -f1";
defineEnvVar MONIT_HTTP_TIMEOUT \
             "The timeout before alerting that monit's own http interface is down" \
             "15 seconds";
defineEnvVar MONIT_ALERT_EMAIL \
             "The email address to send alerts to" \
             '${AUTHOR_EMAIL}';
defineEnvVar INCLUDES_FOLDER \
             "The folder where 'include' files are located" \
             "./.templates";
defineEnvVar COPYRIGHT_PREAMBLE_FILE \
             "The file with the copyright preamble" \
             'copyright-preamble.txt';
defineEnvVar LICENSE_FILE \
             "The file with the license details" \
             'LICENSE';
defineEnvVar ENABLE_SSH "Whether to enable SSH by default" "false";
defineEnvVar ENABLE_MONIT "Whether to enable Monit" "true";
defineEnvVar ENABLE_SYSLOG "Whether to enable syslog" "true";
defineEnvVar ENABLE_CRON "Whether to enable cron" "true";
defineEnvVar ENABLE_RSNAPSHOT "Whether to enable rsnapshot" "true";
defineEnvVar ENABLE_LOCAL_SMTP "Whether to run a local SMTP server" "true";
defineEnvVar ENABLE_LOGSTASH \
             "Whether to enable logstash, if available for the specific image" \
             "true";
defineEnvVar BUILDER "The builder of the image" '${AUTHOR}';
defineEnvVar SSL_KEY_ALGORITHM "The algorithm of the SSL key" "rsa";
defineEnvVar SSL_KEY_LENGTH "The length of the SSL key" "2048";
defineEnvVar SSL_KEY_FOLDER "The folder storing the SSL key pairs" "/etc/ssl/private";
defineEnvVar SSL_KEY_PASSWORD "The key password" 'K8emqG04hZKlOUY3rET1ZBChtqFuERxyWAtyVtnVrP1MYMXhA8SPhdBJ';
defineEnvVar SSL_CERTIFICATE_ORGANIZATIONAL_UNIT "The organizational unit for the SSL certificate" "IT";
defineEnvVar SSL_CERTIFICATE_ORGANIZATION "The organization behind the SSL certificate" '${DOMAIN}';
defineEnvVar SSL_CERTIFICATE_LOCALITY "The locality information in the SSL certificate" "Madrid";
defineEnvVar SSL_CERTIFICATE_STATE "The state information in the SSL certificate" "Madrid";
defineEnvVar SSL_CERTIFICATE_COUNTRY "The country information in the SSL certificate" "ES";
defineEnvVar SSL_CERTIFICATE_EXPIRATION_DAYS "The number of days until the certificate expires" "3650";
defineEnvVar SSL_KEYSTORE_PASSWORD "The keystore password" 'nmGEQlbT2qnCrBsfQDGFkygj8exgEmTCvmc1KSQ8VebBh5';
defineEnvVar SSL_KEYSTORE_FOLDER "The folder storing the SSL keystore" '${SSL_KEY_FOLDER}';
defineEnvVar SSL_KEYSTORE_TYPE "The type of the keystore" "jks";
defineEnvVar SSL_JAVA_SIGN_ALGORITHM "The algorithm used to sign the SSL certificate" "SHA256withRSA";
defineEnvVar HOST_VOLUMES_ROOT_FOLDER "The root folder for host volumes" "/var/lib/docker/data";
defineEnvVar DEVELOPMENT_USER_ID "The user id used when developing code (to match host user id)" "$(id -u)";
