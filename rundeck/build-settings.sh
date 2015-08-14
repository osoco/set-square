defineEnvVar RUNDECK_VERSION "The Rundeck version" "2.5.2-1-GA" "wget -o /dev/null -O- http://dl.bintray.com/rundeck/rundeck-deb/ | grep deb | tail -n 1 | sed 's <.\?pre>  g' | cut -d '>' -f 2 | cut -d '<' -f 1 | sed 's ^rundeck-  g' | sed 's_\.deb$__g'";
defineEnvVar RUNDECK_ADMIN_USER "The Rundeck admin user" "admin";
defineEnvVar RUNDECK_ADMIN_PASSWORD "The Rundeck admin password" "secret" "${RANDOM_PASSWORD}";
