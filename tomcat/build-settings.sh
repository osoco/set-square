defineEnvVar TOMCAT_MAJOR_VERSION \
             "The major version of Tomcat" \
             "8";
defineEnvVar TOMCAT_VERSION \
             "The version of the Apache Tomcat server" \
             "8.0.24" \
             "curl -s -k http://apache.mirrors.pair.com/tomcat/tomcat-8/ | grep folder.gif | tail -n 1 | cut -d '>' -f 3 | cut -d '/' -f 1 | sed 's_^v__g'";
defineEnvVar APR_VERSION \
             "The version of Apache Portable Runtime" \
             "1.5.2";
defineEnvVar TOMCAT_FOLDER \
             "The Tomcat folder" \
             'apache-tomcat-${TOMCAT_VERSION}';
defineEnvVar TOMCAT_FILE \
             "The Tomcat file" \
             '${TOMCAT_FOLDER}.tar.gz';
defineEnvVar TOMCAT_DOWNLOAD_URL \
             "The url to download Tomcat" \
             'http://apache.mirrors.pair.com/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}';
defineEnvVar TOMCAT_USER \
             "The system user for Tomcat" \
             "tomcat";
defineEnvVar TOMCAT_GROUP \
             "The system group for Tomcat" \
             "tomcat";
defineEnvVar TOMCAT_HOME \
             "The home folder for Tomcat user" \
             "/opt/tomcat";
defineEnvVar APR_FOLDER \
             "The APR folder" \
             'apr-${APR_VERSION}';
defineEnvVar APR_FILE \
             "The APR file" \
             '${APR_FOLDER}.tar.gz';
defineEnvVar APR_DOWNLOAD_URL \
             "The url to download APR" \
             'http://www.us.apache.org/dist//apr/${APR_FILE}';
defineEnvVar TOMCAT_NATIVE_VERSION \
             "The version of Tomcat Native" \
             "1.1.33";
defineEnvVar TOMCAT_NATIVE_FOLDER \
             "The Tomcat Native folder" \
             'tomcat-native-${TOMCAT_NATIVE_VERSION}-src';
defineEnvVar TOMCAT_NATIVE_FILE \
             "The Tomcat Native file" \
             '${TOMCAT_NATIVE_FOLDER}.tar.gz';
defineEnvVar TOMCAT_NATIVE_DOWNLOAD_URL \
             "The url to download Tomcat Native" \
             'http://www.us.apache.org/dist/tomcat/tomcat-connectors/native/${TOMCAT_NATIVE_VERSION}/source/${TOMCAT_NATIVE_FILE}';
