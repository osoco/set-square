defineEnvVar TOMCAT_MAJOR_VERSION \
             "The major version of Tomcat" \
             "8";

defineEnvVar TOMCAT_VERSION \
             "The version of the Apache Tomcat server" \
             "8.0.24" \
             "curl -s -k http://apache.mirrors.pair.com/tomcat/tomcat-8/ | grep folder.gif | tail -n 1 | cut -d '>' -f 3 | cut -d '/' -f 1 | sed 's_^v__g'";

defineEnvVar TOMCAT_FOLDER \
             "The Tomcat folder" \
             'apache-tomcat-${TOMCAT_VERSION}';

defineEnvVar TOMCAT_FILE \
             "The Tomcat file" \
             '${TOMCAT_FOLDER}.tar.gz';

defineEnvVar TOMCAT_DOWNLOAD_URL \
             "The url to download Tomcat" \
             'http://apache.mirrors.pair.com/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}';

