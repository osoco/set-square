defineEnvVar JENKINS_MAVEN_VERSION "The Maven version" "3.3.3" "curl -s -k https://www.eu.apache.org/dist/maven/maven-3/ | grep folder.gif | tail -n 1 | cut -d '>' -f 3 | cut -d '/' -f 1";
defineEnvVar JENKINS_USER "The Jenkins user" "jenkins";
defineEnvVar JENKINS_PASSWORD "The Jenkins password" "secret" "${RANDOM_PASSWORD}";
defineEnvVar JENKINS_ENCRYPTED_PASSWORD "The Jenkins password, encrypted" "secret" 'mvn --encrypt-password ${JENKINS_PASSWORD} 2> /dev/null';
defineEnvVar JENKINS_RELEASE_ISSUE_REF "Text referencing a 'Release issue', to be used in commits done by Jenkins while releasing artifacts. ex: 'Ref T10' for Phabricator, 'refs #33' for Trac or Redmine" "";


