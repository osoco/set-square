defineEnvVar APTGET \
             "The 'apt-get' command" \
             "apt-get";
defineEnvVar APTGET_UPDATE \
             "The 'apt-get update' call" \
             "apt-get update -y";
defineEnvVar APTGET_INSTALL \
             "The 'apt-get install' call" \
             "apt-get install -y";
defineEnvVar INSTALLED_PACKAGES_FILE \
             "The file to annotate the explicitly-installed packages" \
             "/var/local/docker-installed-packages.txt";
defineEnvVar HOLD_PACKAGE \
             "The command to hold/pin a package so that it doesn't get removed" \
             "apt-mark hold";
defineEnvVar APT_CACHE_FOLDER \
             "The Ubuntu cache folder" \
             "/var/lib/apt/lists";
