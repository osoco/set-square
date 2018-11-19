defineEnvVar AUTHOR_FIRSTNAME MANDATORY "The firstname of the author" "John";
defineEnvVar AUTHOR_LASTNAME MANDATORY "The lastname of the author" "Smith";
defineEnvVar AUTHOR MANDATORY "The author of the image(s) to build" '${AUTHOR_FIRSTNAME} ${AUTHOR_LASTNAME}';
defineEnvVar DOMAIN MANDATORY "The domain" "example.com";
defineEnvVar AUTHOR_EMAIL MANDATORY "The author's email" 'me@${DOMAIN}';
defineEnvVar NAMESPACE MANDATORY "The docker registry's namespace" "example";
defineEnvVar DATE MANDATORY "The date format used to tag images" "$(date '+%Y%m')";
defineEnvVar TIME MANDATORY "A timestamp" "$(date)";
defineEnvVar RANDOM_PASSWORD \
             MANDATORY \
             "A random password" \
             "secret" \
             'head -c 20 /dev/urandom | sha1sum | cut -d' ' -f1';
defineEnvVar REGISTRY MANDATORY "The registry to push Docker images to" "tutum.co";
defineEnvVar REGISTRY_NAMESPACE \
             MANDATORY \
             "The namespace under the registry where the image is to be uploaded" \
             '${NAMESPACE}';
defineEnvVar INCLUDES_FOLDER \
             MANDATORY \
             "The folder where 'include' files are located" \
             "./.templates";
defineEnvVar COPYRIGHT_PREAMBLE_FILE \
             MANDATORY \
             "The file with the copyright preamble" \
             'copyright-preamble.gpl3';
defineEnvVar LICENSE_FILE \
             MANDATORY \
             "The file with the license details" \
             'LICENSE.gpl3';
defineEnvVar PUSH_TO_DOCKERHUB MANDATORY "Whether to push to Docker HUB" 'false';
defineEnvVar BUILDER MANDATORY "The builder of the image" '${AUTHOR}';
defineEnvVar SETSQUARE_FLAVOR MANDATORY "The flavor of set-square" "";
#
