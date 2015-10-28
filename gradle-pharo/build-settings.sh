defineEnvVar PHARO_VERSION "The Pharo version" "4.0";
defineEnvVar PHARO_VERSION_ZEROCONF "The Pharo version, as expected by the Zeroconf script in get.pharo.org" '$(echo ${PHARO_VERSION} | tr -d '.')';
