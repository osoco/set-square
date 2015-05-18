# Environment
function defineEnv() {
  
  export AUTHOR_DEFAULT="<rydnr@acm-sl.org>";
  export AUTHOR_DESCRIPTION="The author of the image(s) to build";
  if    [ "${AUTHOR+1}" != "1" ] \
     || [ "x${AUTHOR}" == "x" ]; then
    export AUTHOR="${AUTHOR_DEFAULT}";
  fi

  export NAMESPACE_DEFAULT="acmsl";
  export NAMESPACE_DESCRIPTION="The docker registry's namespace";
  if    [ "${NAMESPACE+1}" != "1" ] \
     || [ "x${NAMESPACE}" == "x" ]; then
    export NAMESPACE="${NAMESPACE_DEFAULT}";
  fi

  export DATE_DEFAULT="$(date '+%Y%m')";
  export DATE_DESCRIPTION="The date used to tag images";
  if    [ "${DATE+1}" != "1" ] \
     || [ "x${DATE}" == "x" ]; then
    export DATE="${DATE_DEFAULT}";
  fi

  export TOMCAT_VERSION_DEFAULT="$(curl -s -k http://apache.mirrors.pair.com/tomcat/tomcat-8/ | grep folder.gif | tail -n 1 | cut -d '>' -f 3 | cut -d '/' -f 1 | sed 's ^v  g')";
  export TOMCAT_VERSION_DESCRIPTION="The version of the Apache Tomcat server";
  if    [ "${TOMCAT_VERSION+1}" != "1" ] \
     || [ "x${TOMCAT_VERSION}" == "x" ]; then
    export TOMCAT_VERSION="${TOMCAT_VERSION_DEFAULT}";
  fi
  
  export JAVA_VERSION_DEFAULT="8";
  export JAVA_VERSION_DESCRIPTION="The version of the JDK";
  if    [ "${JAVA_VERSION+1}" != "1" ] \
     || [ "x${JAVA_VERSION}" == "x" ]; then
    export JAVA_VERSION="${JAVA_VERSION_DEFAULT}";
  fi
  
  export MARIADB_ROOT_PASSWORD_DEFAULT="secret";
  export MARIADB_ROOT_PASSWORD_DESCRIPTION="The default password for the root user in MySQL databases";
  if    [ "${MARIADB_ROOT_PASSWORD+1}" != "1" ] \
     || [ "x${MARIADB_ROOT_PASSWORD}" == "x" ]; then
    export MARIADB_ROOT_PASSWORD="${MARIADB_ROOT_PASSWORD_DEFAULT}";
  fi

  export MARIADB_ADMIN_USER_DEFAULT="admin";
  export MARIADB_ADMIN_USER_DESCRIPTION="The name of the admin user in MySQL databases";
  if    [ "${MARIADB_ADMIN_USER+1}" != "1" ] \
     || [ "x${MARIADB_ADMIN_USER}" == "x" ]; then
    export MARIADB_ADMIN_USER="${MARIADB_ADMIN_USER_DEFAULT}";
  fi

  export MARIADB_ADMIN_PASSWORD_DEFAULT="secret";
  export MARIADB_ADMIN_PASSWORD_DESCRIPTION="The default password for the admin user in MySQL databases";
  if    [ "${MARIADB_ADMIN_PASSWORD+1}" != "1" ] \
     || [ "x${MARIADB_ADMIN_PASSWORD}" == "x" ]; then
    export MARIADB_ADMIN_PASSWORD="${MARIADB_ADMIN_PASSWORD_DEFAULT}";
  fi

  export GETBOO_VERSION_DEFAULT="1.04";
  export GETBOO_VERSION_DESCRIPTION="The version of Getboo";
  if    [ "${GETBOO_VERSION+1}" != "1" ] \
     || [ "x${GETBOO_VERSION}" == "x" ]; then
    export GETBOO_VERSION="${GETBOO_VERSION_DEFAULT}";
  fi
  
  export GETBOO_DB_NAME_DEFAULT="bm";
  export GETBOO_DB_NAME_DESCRIPTION="The database name for getboo schema";
  if    [ "${GETBOO_DB_NAME+1}" != "1" ] \
     || [ "x${GETBOO_DB_NAME}" == "x" ]; then
    export GETBOO_DB_NAME="${GETBOO_DB_NAME_DEFAULT}";
  fi
  
  export GETBOO_DB_USERNAME_DEFAULT="bm";
  export GETBOO_DB_USERNAME_DESCRIPTION="The name for getboo user in MySQL";
  if    [ "${GETBOO_DB_USERNAME+1}" != "1" ] \
     || [ "x${GETBOO_DB_USERNAME}" == "x" ]; then
    export GETBOO_DB_USERNAME="${GETBOO_DB_USERNAME_DEFAULT}";
  fi
  
  export GETBOO_DB_PASSWORD_DEFAULT="secret";
  export GETBOO_DB_PASSWORD_DESCRIPTION="The password for getboo user in MySQL";
  if    [ "${GETBOO_DB_PASSWORD+1}" != "1" ] \
     || [ "x${GETBOO_DB_PASSWORD}" == "x" ]; then
    export GETBOO_DB_PASSWORD="${GETBOO_DB_PASSWORD_DEFAULT}";
  fi
  
  export GETBOO_DB_TABLE_PREFIX_DEFAULT="";
  export GETBOO_DB_TABLE_PREFIX_DESCRIPTION="The prefix used for all tables in getboo database";
  if    [ "${GETBOO_DB_TABLE_PREFIX+1}" != "1" ] \
     || [ "x${GETBOO_DB_TABLE_PREFIX}" == "x" ]; then
    export GETBOO_DB_TABLE_PREFIX="${GETBOO_DB_TABLE_PREFIX_DEFAULT}";
  fi
  
  export GETBOO_DOMAIN_DEFAULT="bm.acm-sl.org";
  export GETBOO_DOMAIN_DESCRIPTION="The domain getboo will be serving";
  if    [ "${GETBOO_DOMAIN+1}" != "1" ] \
     || [ "x${GETBOO_DOMAIN}" == "x" ]; then
    export GETBOO_DOMAIN="${GETBOO_DOMAIN_DEFAULT}";
  fi

  export GETBOO_ADMIN_USERNAME_DEFAULT="bmadmin";
  export GETBOO_ADMIN_USERNAME_DESCRIPTION="The admin username in Getboo";
  if    [ "${GETBOO_ADMIN_USERNAME+1}" != "1" ] \
     || [ "x${GETBOO_ADMIN_USERNAME}" == "x" ]; then
    export GETBOO_ADMIN_USERNAME="${GETBOO_ADMIN_USERNAME_DEFAULT}";
  fi

  export GETBOO_ADMIN_PASSWORD_DEFAULT="secret";
  export GETBOO_ADMIN_PASSWORD_DESCRIPTION="The admin password in Getboo";
  if    [ "${GETBOO_ADMIN_PASSWORD+1}" != "1" ] \
     || [ "x${GETBOO_ADMIN_PASSWORD}" == "x" ]; then
    export GETBOO_ADMIN_PASSWORD="${GETBOO_ADMIN_PASSWORD_DEFAULT}";
  fi

  export GETBOO_ADMIN_EMAIL_DEFAULT="admin-getboo@${GETBOO_DOMAIN}";
  export GETBOO_ADMIN_EMAIL_DESCRIPTION="The admin email in Getboo";
  if    [ "${GETBOO_ADMIN_EMAIL+1}" != "1" ] \
     || [ "x${GETBOO_ADMIN_EMAIL}" == "x" ]; then
    export GETBOO_ADMIN_EMAIL="${GETBOO_ADMIN_EMAIL_DEFAULT}";
  fi

  export GETBOO_DEFAULT_LANGUAGE_DEFAULT="en_US";
  export GETBOO_DEFAULT_LANGUAGE_DESCRIPTION="The default language in Getboo";
  if    [ "${GETBOO_DEFAULT_LANGUAGE+1}" != "1" ] \
     || [ "x${GETBOO_DEFAULT_LANGUAGE}" == "x" ]; then
    export GETBOO_DEFAULT_LANGUAGE="${GETBOO_DEFAULT_LANGUAGE_DEFAULT}";
  fi

  export HTTPS_DOMAIN_DEFAULT="${GETBOO_DOMAIN}";
  export HTTPS_DOMAIN_DESCRIPTION="The https domain";
  if    [ "${HTTPS_DOMAIN+1}" != "1" ] \
     || [ "x${HTTPS_DOMAIN}" == "x" ]; then
    export HTTPS_DOMAIN="${HTTPS_DOMAIN_DEFAULT}";
  fi

  export ARTIFACTORY_VERSION_DEFAULT="$(curl -s -k http://dl.bintray.com/jfrog/artifactory/ | grep zip | tail -n 1 | cut -d'"' -f 4 | cut -d '-' -f 2 | sed 's .zip  g')";
  export ARTIFACTORY_VERSION_DESCRIPTION="The version of Artifactory";
  if    [ "${ARTIFACTORY_VERSION+1}" != "1" ] \
     || [ "x${ARTIFACTORY_VERSION}" == "x" ]; then
    export ARTIFACTORY_VERSION="${ARTIFACTORY_VERSION_DEFAULT}";
  fi
  
  export MAVEN_VERSION_DEFAULT="$(curl -s -k https://www.eu.apache.org/dist/maven/maven-3/ | grep folder.gif | tail -n 1 | cut -d '>' -f 3 | cut -d '/' -f 1)";
  export MAVEN_VERSION_DESCRIPTION="The version of Maven";
  if    [ "${MAVEN_VERSION+1}" != "1" ] \
     || [ "x${MAVEN_VERSION}" == "x" ]; then
    export MAVEN_VERSION="${MAVEN_VERSION_DEFAULT}";
  fi

  export JENKINS_USER_DEFAULT="jenkins-admin";
  export JENKINS_USER_DESCRIPTION="The Jenkins user";
  if    [ "${JENKINS_USER+1}" != "1" ] \
     || [ "x${JENKINS_USER}" == "x" ]; then
    export JENKINS_USER="${JENKINS_USER_DEFAULT}";
  fi

  export JENKINS_PASSWORD_DEFAULT="secret";
  export JENKINS_PASSWORD_DESCRIPTION="The password for the jenkins user";
  if    [ "${JENKINS_PASSWORD+1}" != "1" ] \
     || [ "x${JENKINS_PASSWORD}" == "x" ]; then
    export JENKINS_PASSWORD="${JENKINS_PASSWORD_DEFAULT}";
  fi

  export JENKINS_ENCRYPTED_PASSWORD_DEFAULT="$(mvn --encrypt-password ${JENKINS_PASSWORD} 2> /dev/null)";
  export JENKINS_ENCRYPTED_PASSWORD_DESCRIPTION="The encrypted password for the jenkins user";
  if    [ "${JENKINS_ENCRYPTED_PASSWORD+1}" != "1" ] \
     || [ "x${JENKINS_ENCRYPTED_PASSWORD}" == "x" ]; then
    export JENKINS_ENCRYPTED_PASSWORD="${JENKINS_ENCRYPTED_PASSWORD_DEFAULT}";
  fi

  export RELEASE_ISSUE_REF_DEFAULT="";
  export RELEASE_ISSUE_REF_DESCRIPTION="Text referencing a 'Release issue', to be used in commits done by Jenkins while releasing artifacts. ex: 'Ref T10' for Phabricator, 'refs #33' for Trac or Redmine";
  if    [ "${RELEASE_ISSUE_REF+1}" != "1" ] \
     || [ "x${RELEASE_ISSUE_REF}" == "x" ]; then
    export RELEASE_ISSUE_REF="${RELEASE_ISSUE_REF_DEFAULT}";
  fi

  export ACTIVEMQ_PORT_DEFAULT="61613";
  export ACTIVEMQ_CLIENT_PASSWORD_DESCRIPTION="The ActiveMQ port";
  if    [ "${ACTIVEMQ_PORT+1}" != "1" ] \
     || [ "x${ACTIVEMQ_PORT}" == "x" ]; then
    export ACTIVEMQ_PORT="${ACTIVEMQ_PORT_DEFAULT}";
  fi

  export ACTIVEMQ_CLIENT_PASSWORD_DEFAULT="secret";
  export ACTIVEMQ_CLIENT_PASSWORD_DESCRIPTION="The password for the ActiveMQ client";
  if    [ "${ACTIVEMQ_CLIENT_PASSWORD+1}" != "1" ] \
     || [ "x${ACTIVEMQ_CLIENT_PASSWORD}" == "x" ]; then
    export ACTIVEMQ_CLIENT_PASSWORD="${ACTIVEMQ_CLIENT_PASSWORD_DEFAULT}";
  fi

  export ACTIVEMQ_SERVER_PASSWORD_DEFAULT="secret";
  export ACTIVEMQ_SERVER_PASSWORD_DESCRIPTION="The password for the ActiveMQ server";
  if    [ "${ACTIVEMQ_SERVER_PASSWORD+1}" != "1" ] \
     || [ "x${ACTIVEMQ_SERVER_PASSWORD}" == "x" ]; then
    export ACTIVEMQ_SERVER_PASSWORD="${ACTIVEMQ_SERVER_PASSWORD_DEFAULT}";
  fi

  export ACTIVEMQ_PRE_SHARED_KEY_DEFAULT="secret";
  export ACTIVEMQ_PRE_SHARED_KEY_DESCRIPTION="The pre-shared key for ActiveMQ";
  if    [ "${ACTIVEMQ_PRE_SHARED_KEY+1}" != "1" ] \
     || [ "x${ACTIVEMQ_PRE_SHARED_KEY}" == "x" ]; then
    export ACTIVEMQ_PRE_SHARED_KEY="${ACTIVEMQ_PRE_SHARED_KEY_DEFAULT}";
  fi

  export FIREFOX_SYNC_DOMAIN_DEFAULT="firefox-sync.acm-sl.org";
  export FIREFOX_SYNC_DOMAIN_DESCRIPTION="The secret string for the firefox sync server";
  if    [ "${FIREFOX_SYNC_DOMAIN+1}" != "1" ] \
     || [ "x${FIREFOX_SYNC_DOMAIN}" == "x" ]; then
    export FIREFOX_SYNC_DOMAIN="${FIREFOX_SYNC_DOMAIN_DEFAULT}";
  fi

  export FIREFOX_SYNC_SECRET_DEFAULT="$(head -c 20 /dev/urandom | sha1sum | awk '{print $1;}')";
  export FIREFOX_SYNC_SECRET_DESCRIPTION="The secret string for the firefox sync server";
  if    [ "${FIREFOX_SYNC_SECRET+1}" != "1" ] \
     || [ "x${FIREFOX_SYNC_SECRET}" == "x" ]; then
    export FIREFOX_SYNC_SECRET="${FIREFOX_SYNC_SECRET_DEFAULT}";
  fi

  export FIREFOX_SYNC_DB_NAME_DEFAULT="ffsync";
  export FIREFOX_SYNC_DB_NAME_DESCRIPTION="The Firefox Sync database";
  if    [ "${FIREFOX_SYNC_DB_NAME+1}" != "1" ] \
     || [ "x${FIREFOX_SYNC_DB_NAME}" == "x" ]; then
    export FIREFOX_SYNC_DB_NAME="${FIREFOX_SYNC_DB_NAME_DEFAULT}";
  fi

  export FIREFOX_SYNC_DB_USER_DEFAULT="ffsync";
  export FIREFOX_SYNC_DB_USER_DESCRIPTION="The username to connect to the firefox sync database";
  if    [ "${FIREFOX_SYNC_DB_USER+1}" != "1" ] \
     || [ "x${FIREFOX_SYNC_DB_USER}" == "x" ]; then
    export FIREFOX_SYNC_DB_USER="${FIREFOX_SYNC_DB_USER_DEFAULT}";
  fi

  export FIREFOX_SYNC_DB_PASSWORD_DEFAULT="secret";
  export FIREFOX_SYNC_DB_PASSWORD_DESCRIPTION="The password to connect to the firefox sync database";
  if    [ "${FIREFOX_SYNC_DB_PASSWORD+1}" != "1" ] \
     || [ "x${FIREFOX_SYNC_DB_PASSWORD}" == "x" ]; then
    export FIREFOX_SYNC_DB_PASSWORD="${FIREFOX_SYNC_DB_PASSWORD_DEFAULT}";
  fi

  export RABBITMQ_USER_DEFAULT="openbadges";
  export RABBITMQ_USER_DESCRIPTION="The RabbitMQ user";
  if    [ "${RABBITMQ_USER+1}" != "1" ] \
     || [ "x${RABBITMQ_USER}" == "x" ]; then
    export RABBITMQ_USER="${RABBITMQ_USER_DEFAULT}";
  fi

  export RABBITMQ_PASSWORD_DEFAULT="openbadges";
  export RABBITMQ_PASSWORD_DESCRIPTION="The password of the RabbitMQ user";
  if    [ "${RABBITMQ_PASSWORD+1}" != "1" ] \
     || [ "x${RABBITMQ_PASSWORD}" == "x" ]; then
    export RABBITMQ_PASSWORD="${RABBITMQ_PASSWORD_DEFAULT}";
  fi

  export RABBITMQ_EXCHANGE_DEFAULT="${NAMESPACE}";
  export RABBITMQ_EXCHANGE_DESCRIPTION="The RabbitMQ exchange";
  if    [ "${RABBITMQ_EXCHANGE+1}" != "1" ] \
     || [ "x${RABBITMQ_EXCHANGE}" == "x" ]; then
    export RABBITMQ_EXCHANGE="${RABBITMQ_EXCHANGE_DEFAULT}";
  fi

  export RABBITMQ_VIRTUALHOST_DEFAULT="${NAMESPACE}";
  export RABBITMQ_VIRTUALHOST_DESCRIPTION="The RabbitMQ virtual host";
  if    [ "${RABBITMQ_VIRTUALHOST+1}" != "1" ] \
     || [ "x${RABBITMQ_VIRTUALHOST}" == "x" ]; then
    export RABBITMQ_VIRTUALHOST="${RABBITMQ_VIRTUALHOST_DEFAULT}";
  fi

  export RABBITMQ_QUEUE_DEFAULT="commands#game-core";
  export RABBITMQ_QUEUE_DESCRIPTION="The queue in RabbitMQ";
  if    [ "${RABBITMQ_QUEUE+1}" != "1" ] \
     || [ "x${RABBITMQ_QUEUE}" == "x" ]; then
    export RABBITMQ_QUEUE="${RABBITMQ_QUEUE_DEFAULT}";
  fi

  export RABBITMQ_ROUTING_KEY_DEFAULT="#";
  export RABBITMQ_ROUTING_KEY_DESCRIPTION="The routing key in RabbitMQ";
  if    [ "${RABBITMQ_ROUTING_KEY+1}" != "1" ] \
     || [ "x${RABBITMQ_ROUTING_KEY}" == "x" ]; then
    export RABBITMQ_ROUTING_KEY="${RABBITMQ_ROUTING_KEY_DEFAULT}";
  fi

  export POSTGRESQL_VERSION_DEFAULT="9.3";
  export POSTGRESQL_VERSION_DESCRIPTION="The PostgreSQL version";
  if    [ "${POSTGRESQL_VERSION+1}" != "1" ] \
     || [ "x${POSTGRESQL_VERSION}" == "x" ]; then
    export POSTGRESQL_VERSION="${POSTGRESQL_VERSION_DEFAULT}";
  fi

  export POSTGRESQL_ROOT_USER_DEFAULT="docker";
  export POSTGRESQL_ROOT_USER_DESCRIPTION="The name of the admin user in PostgreSQL databases";
  if    [ "${POSTGRESQL_ROOT_USER+1}" != "1" ] \
     || [ "x${POSTGRESQL_ROOT_USER}" == "x" ]; then
    export POSTGRESQL_ROOT_USER="${POSTGRESQL_ROOT_USER_DEFAULT}";
  fi

  export POSTGRESQL_ROOT_PASSWORD_DEFAULT="secret";
  export POSTGRESQL_ROOT_PASSWORD_DESCRIPTION="The default password for the root user in PostgreSQL databases";
  if    [ "${POSTGRESQL_ROOT_PASSWORD+1}" != "1" ] \
     || [ "x${POSTGRESQL_ROOT_PASSWORD}" == "x" ]; then
    export POSTGRESQL_ROOT_PASSWORD="${POSTGRESQL_ROOT_PASSWORD_DEFAULT}";
  fi

  export MONGODB_VERSION_DEFAULT="3.0";
  export MONGODB_VERSION_DESCRIPTION="The MongoDB version";
  if    [ "${MONGODB_VERSION+1}" != "1" ] \
     || [ "x${MONGODB_VERSION}" == "x" ]; then
    export MONGODB_VERSION="${MONGODB_VERSION_DEFAULT}";
  fi

  export RUNDECK_VERSION_DEFAULT="$(wget -o /dev/null -O- http://dl.bintray.com/rundeck/rundeck-deb/ | grep deb | tail -n 1 | sed 's <.\?pre>  g' | cut -d '>' -f 2 | cut -d '<' -f 1 | sed 's ^rundeck-  g' | sed 's \.deb$  g')";
  export RUNDECK_VERSION_DESCRIPTION="The Rundeck version";
  if    [ "${RUNDECK_VERSION+1}" != "1" ] \
     || [ "x${RUNDECK_VERSION}" == "x" ]; then
    export RUNDECK_VERSION="${RUNDECK_VERSION_DEFAULT}";
  fi
  
  export RUNDECK_ADMIN_USER_DEFAULT="rundeck";
  export RUNDECK_ADMIN_USER_DESCRIPTION="The name of the admin user in Rundeck";
  if    [ "${RUNDECK_ADMIN_USER+1}" != "1" ] \
     || [ "x${RUNDECK_ADMIN_USER}" == "x" ]; then
    export RUNDECK_ADMIN_USER="${RUNDECK_ADMIN_USER_DEFAULT}";
  fi

  export RUNDECK_ADMIN_PASSWORD_DEFAULT="secret";
  export RUNDECK_ADMIN_PASSWORD_DESCRIPTION="The default password for the admin user in Rundeck";
  if    [ "${RUNDECK_ADMIN_PASSWORD+1}" != "1" ] \
     || [ "x${RUNDECK_ADMIN_PASSWORD}" == "x" ]; then
    export RUNDECK_ADMIN_PASSWORD="${RUNDECK_ADMIN_PASSWORD_DEFAULT}";
  fi

  ENV_VARIABLES=(\
    AUTHOR \
    NAMESPACE \
    MARIADB_ROOT_PASSWORD \
    MARIADB_ADMIN_USER \
    MARIADB_ADMIN_PASSWORD \
    GETBOO_VERSION \
    GETBOO_DB_NAME \
    GETBOO_DB_USERNAME \
    GETBOO_DB_PASSWORD \
    GETBOO_DB_TABLE_PREFIX \
    GETBOO_DOMAIN \
    GETBOO_ADMIN_USERNAME \
    GETBOO_ADMIN_PASSWORD \
    GETBOO_ADMIN_EMAIL \
    GETBOO_DEFAULT_LANGUAGE \
    HTTPS_DOMAIN \
    JAVA_VERSION \
    TOMCAT_VERSION \
    ARTIFACTORY_VERSION \
    MAVEN_VERSION \
    JENKINS_USER \
    JENKINS_PASSWORD \
    JENKINS_ENCRYPTED_PASSWORD \
    RELEASE_ISSUE_REF \
    ACTIVEMQ_PORT \
    ACTIVEMQ_CLIENT_PASSWORD \
    ACTIVEMQ_SERVER_PASSWORD \
    ACTIVEMQ_PRE_SHARED_KEY \
    FIREFOX_SYNC_DOMAIN \
    FIREFOX_SYNC_SECRET \
    FIREFOX_SYNC_DB_NAME \
    FIREFOX_SYNC_DB_USER \
    FIREFOX_SYNC_DB_PASSWORD \
    RABBITMQ_USER \
    RABBITMQ_PASSWORD \
    RABBITMQ_VIRTUALHOST \
    RABBITMQ_EXCHANGES \
    RABBITMQ_QUEUE \
    RABBITMQ_ROUTING_KEY \
    POSTGRESQL_VERSION \
    POSTGRESQL_ROOT_USER \
    POSTGRESQL_ROOT_PASSWORD \
    MONGODB_VERSION \
    RUNDECK_VERSION \
    RUNDECK_ADMIN_USER \
    RUNDECK_ADMIN_PASSWORD \
   );
 
  export ENV_VARIABLES;
}
