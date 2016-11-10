defineEnvVar APTGET \
             "The 'apt-get' command" \
             "apt-get";
defineEnvVar APTGET_REMOVE \
             "The 'apt-get remove' call" \
             "apt-get remove --purge -y";
defineEnvVar APTGET_CLEAN \
             "The 'apt-get clean' call" \
             "apt-get clean";
defineEnvVar APTGET_AUTOREMOVE \
             "The 'apt-get autoremove' call" \
             "apt-get autoremove -y";
defineEnvVar INSTALLED_PACKAGES_FILE \
             "The file to annotate the explicitly-installed packages" \
             "/var/local/docker-installed-packages.txt";
