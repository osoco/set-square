defineEnvVar JENKINS_MAVEN_VERSION "The Maven version" "3.3.3" "curl -s -k https://www.eu.apache.org/dist/maven/maven-3/ | grep folder.gif | tail -n 1 | cut -d '>' -f 3 | cut -d '/' -f 1";
defineEnvVar JENKINS_USER "The Jenkins user" "jenkins";
defineEnvVar JENKINS_PASSWORD "The Jenkins password" "secret" "${RANDOM_PASSWORD}";
defineEnvVar JENKINS_ENCRYPTED_PASSWORD "The Jenkins password, encrypted" "secret" 'mvn --encrypt-password ${JENKINS_PASSWORD} 2> /dev/null';
defineEnvVar JENKINS_RELEASE_ISSUE_REF "Text referencing a 'Release issue', to be used in commits done by Jenkins while releasing artifacts. ex: 'Ref T10' for Phabricator, 'refs #33' for Trac or Redmine" "";
defineEnvVar JENKINS_DOWNLOAD_URL \
             "The url to download Jenkins" \
             "http://mirrors.jenkins-ci.org/war/latest/jenkins.war";
defineEnvVar TOMCAT_HOME \
             "The home directory of Tomcat" \
             "/opt/tomcat";
defineEnvVar JENKINS_HOME \
             "The home directory of Jenkins" \
             "/home/jenkins";
defineEnvVar TOMCAT_USER \
             "The Tomcat user" \
             "tomcat";
defineEnvVar TOMCAT_GROUP \
             "The Tomcat group" \
             "tomcat";
defineEnvVar JENKINS_GROUP \
             "The Jenkins group" \
             "jenkins";
defineEnvVar JENKINS_MAVEN_FOLDER \
             "The Maven folder" \
             'apache-maven-${JENKINS_MAVEN_VERSION}-bin';
defineEnvVar JENKINS_MAVEN_FILE \
             "The url to download Maven" \
             '${JENKINS_MAVEN_FOLDER}.tar.gz';
defineEnvVar JENKINS_MAVEN_DOWNLOAD_URL \
             "The url to download Maven" \
             'https://www.eu.apache.org/dist/maven/maven-3/${JENKINS_MAVEN_VERSION}/binaries/${JENKINS_MAVEN_FILE}';
