defineEnvVar AUTHOR "The author of the image(s) to build" "me";
defineEnvVar AUTHOR_EMAIL "The author's email" "me@example.com";
defineEnvVar NAMESPACE "The docker registry's namespace" "example";
defineEnvVar STACK "The stack the image belongs to, if any";
defineEnvVar DATE "The date format used to tag images" "$(date '+%Y%m')";
defineEnvVar ROOT_IMAGE_VERSION "The root image version" "0.9.17";
defineEnvVar ROOT_IMAGE_64BIT "The default root image for 64 bits" "phusion/baseimage"
defineEnvVar RANDOM_PASSWORD "A random password" 'head -c 20 /dev/urandom | sha1sum | cut -d" " -f1';
defineEnvVar ROOT_IMAGE_32BIT "The default root image for 32 bits" "${ROOT_IMAGE_64BIT_DEFAULT}32";
defineEnvVar BASE_IMAGE_64BIT "The base image for 64 bits" '${NAMESPACE}/base';
defineEnvVar BASE_IMAGE_32BIT "The base image for 32 bits" '${BASE_IMAGE_64BIT_DEFAULT%%64}32';
defineEnvVar TUTUM_NAMESPACE "The tutum.co namespace" "example";
