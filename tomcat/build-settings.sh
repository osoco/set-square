defineEnvVar \
  TOMCAT_VERSION "The version of the Apache Tomcat server" "8.0.24" \
  "curl -s -k http://apache.mirrors.pair.com/tomcat/tomcat-8/ | grep folder.gif | tail -n 1 | cut -d '>' -f 3 | cut -d '/' -f 1 | sed 's_^v__g'";


