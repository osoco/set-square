defineEnvVar PLONE3_VERSION "The Plone3 version" "3.1.7";
defineEnvVar PLONE3_MAJOR_VERSION "The Plone3 major version" "1";
defineEnvVar PLONE3_FOLDER \
             "The Plone3 Unified Installer" \
             "Plone-3.1.7ex-UnifiedInstaller";
defineEnvVar PLONE3_FILE \
             "The Plone3 file" \
             '${PLONE3_FOLDER}.tgz';
defineEnvVar PLONE3_DOWNLOAD_URL \
             "The url to download Plone3" \
             'https://launchpad.net/plone/3.${PLONE3_MAJOR_VERSION}/${PLONE3_VERSION}/+download/${PLONE3_FILE}';
defineEnvVar PLONE3_HOME \
             "The home directory of the Plone installation" \
             '/opt/${PLONE3_FOLDER}';
