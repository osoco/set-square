defineEnvVar GHOST_VERSION "The version of Ghost" "0.7.1";
defineEnvVar GHOST_ARTIFACT "The Ghost artifact" 'ghost-${GHOST_VERSION}.zip';
defineEnvVar GHOST_URL "The url to download Ghost" 'https://ghost.org/zip/${GHOST_ARTIFACT}';
defineEnvVar GHOST_DOMAIN "The domain for the Ghost application" 'ghost.${NAMESPACE}.com';
