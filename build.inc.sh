defineEnvVar AUTHOR "The author of the image(s) to build" "me";
defineEnvVar DOMAIN "The domain" "example.com";
defineEnvVar AUTHOR_EMAIL "The author's email" 'me@${DOMAIN}';
defineEnvVar NAMESPACE "The docker registry's namespace" "example";
defineEnvVar DATE "The date format used to tag images" "$(date '+%Y%m')";
defineEnvVar TIME "A timestamp" "$(date)";
defineEnvVar REGISTRY "The registry to push Docker images to" "tutum.co";
defineEnvVar REGISTRY_NAMESPACE \
             "The namespace under the registry where the image is to be uploaded" \
             '${NAMESPACE}';
defineEnvVar ROOT_IMAGE_VERSION "The root image version" "0.9.21";
defineEnvVar ROOT_IMAGE_64BIT "The default root image for 64 bits" "phusion/baseimage"
defineEnvVar RANDOM_PASSWORD \
             "A random password" \
             "secret" \
             'head -c 20 /dev/urandom | sha1sum | cut -d' ' -f1';
defineEnvVar ROOT_IMAGE_32BIT "The default root image for 32 bits" "${ROOT_IMAGE_64BIT_DEFAULT}32";
defineEnvVar BASE_IMAGE_64BIT "The base image for 64 bits" '${NAMESPACE}/base';
defineEnvVar BASE_IMAGE_32BIT "The base image for 32 bits" '${BASE_IMAGE_64BIT_DEFAULT%%64}32';
defineEnvVar SMTP_HOST \
             "The SMTP host to send emails, including monit's" \
             'mail.${DOMAIN}';
defineEnvVar LDAP_HOST \
             "The LDAP host to authorize and/or authenticate users" \
             'ldap.${DOMAIN}';
defineEnvVar SSHPORTS_FILE \
             "The file with the SSH port mappings" \
             "sshports.txt";
defineEnvVar INCLUDES_FOLDER \
             "The folder where 'include' files are located" \
             "./.templates";
defineEnvVar COPYRIGHT_PREAMBLE_FILE \
             "The file with the copyright preamble" \
             'copyright-preamble.txt';
defineEnvVar LICENSE_FILE \
             "The file with the license details" \
             'LICENSE';
defineEnvVar BUILDER "The builder of the image" '${AUTHOR}';
defineEnvVar HOST_VOLUMES_ROOT_FOLDER "The root folder for host volumes" "/var/lib/docker/data";
defineEnvVar DEVELOPMENT_USER_ID "The user id used when developing code (to match host user id)" "$(id -u)";
defineEnvVar DOCKER_OPTS "Generic Docker options" "";
defineEnvVar DOCKER_TAG_OPTS "Docker tag options" "";
defineEnvVar DOCKER_BUILD "The docker build command" 'docker ${DOCKER_OPTS} build';
defineEnvVar DOCKER_BUILD_OPTS "Docker build options" "--rm=true";
defineEnvVar CONTAINER_TERM_WIDTH "The terminal width" "$(tput cols 2> /dev/null)";

defineEnvVar APTGET_INSTALL \
             "Installs a program via apt-get" \
             '/usr/local/bin/aptget-install.sh -vv ';
defineEnvVar APTGET_CLEANUP \
             "The cleanup commands after an apt-get so that the resulting image size is optimal" \
             '/usr/local/bin/aptget-cleanup.sh -v';
defineEnvVar SERVICE "The service file inside the repository folder (not in the image)" "service";
