#defineEnvVar LOGGLY_TOKEN "The loggly.com API token" "token"
defineEnvVar JAVA_VERSION \
             "The Java version" \
             "8";
defineEnvVar JCE_VERSION \
             "The JCE version" \
             '${JAVA_VERSION}';
defineEnvVar JCE_DOWNLOAD_URL \
             "The url to download the JCE" \
             'http://download.oracle.com/otn-pub/java/jce/${JCE_VERSION}/jce_policy-${JCE_VERSION}.zip';
