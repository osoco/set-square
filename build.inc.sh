defineEnvVar AUTHOR_FIRSTNAME "The firstname of the author" "John";
defineEnvVar AUTHOR_LASTNAME "The lastname of the author" "Smith";
defineEnvVar AUTHOR "The author of the image(s) to build" '${AUTHOR_FIRSTNAME} ${AUTHOR_LASTNAME}';
defineEnvVar DOMAIN "The domain" "example.com";
defineEnvVar AUTHOR_EMAIL "The author's email" 'me@${DOMAIN}';
defineEnvVar NAMESPACE "The docker registry's namespace" "example";
defineEnvVar DATE "The date format used to tag images" "$(date '+%Y%m')";
defineEnvVar TIME "A timestamp" "$(date)";
defineEnvVar RANDOM_PASSWORD \
             "A random password" \
             "secret" \
             'head -c 20 /dev/urandom | sha1sum | cut -d' ' -f1';
defineEnvVar REGISTRY "The registry to push Docker images to" "tutum.co";
defineEnvVar REGISTRY_NAMESPACE \
             "The namespace under the registry where the image is to be uploaded" \
             '${NAMESPACE}';
defineEnvVar INCLUDES_FOLDER \
             "The folder where 'include' files are located" \
             "./.templates";
defineEnvVar COPYRIGHT_PREAMBLE_FILE \
             "The file with the copyright preamble" \
             'copyright-preamble.gpl3';
defineEnvVar LICENSE_FILE \
             "The file with the license details" \
             'LICENSE.gpl3';
defineEnvVar PUSH_TO_DOCKERHUB "Whether to push to Docker HUB" 'false';
defineEnvVar BUILDER "The builder of the image" '${AUTHOR}';
defineEnvVar SETSQUARE_FLAVOR "The flavor of set-square" "";
#
