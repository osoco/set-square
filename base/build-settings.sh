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
defineEnvVar LOGSTASH_VERSION \
             "The version of logstash" \
             "1.5.3";
defineEnvVar LOGSTASH_FILE \
             "The final Logstash artifact" \
             'logstash_${LOGSTASH_VERSION}-1_all.deb';
defineEnvVar LOGSTASH_DOWNLOAD_URL \
             "The logstash download url" \
             'https://download.elastic.co/logstash/logstash/packages/debian/${LOGSTASH_FILE}';
