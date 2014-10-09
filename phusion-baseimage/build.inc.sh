# Environment
function defineEnv() {
  
  echo "defining env"
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

  export TOMCAT_VERSION_DEFAULT="8.0.12";
  export TOMCAT_VERSION_DESCRIPTION="The version of the Apache Tomcat server";
  if    [ "${TOMCAT_VERSION+1}" != "1" ] \
     || [ "x${TOMCAT_VERSION}" == "x" ]; then
    export TOMCAT_VERSION="${TOMCAT_VERSION_DEFAULT}";
  fi
  
  export MYSQL_ROOT_PASSWORD_DEFAULT="secret";
  export MYSQL_ROOT_PASSWORD_DESCRIPTION="The default password for the root user in MySQL databases";
  if    [ "${MYSQL_ROOT_PASSWORD+1}" != "1" ] \
     || [ "x${MYSQL_ROOT_PASSWORD}" == "x" ]; then
    export MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD_DEFAULT}";
  fi

  export MYSQL_ADMIN_USER_DEFAULT="admin";
  export MYSQL_ADMIN_USER_DESCRIPTION="The name of the admin user in MySQL databases";
  if    [ "${MYSQL_ADMIN_USER+1}" != "1" ] \
     || [ "x${MYSQL_ADMIN_USER}" == "x" ]; then
    export MYSQL_ADMIN_USER="${MYSQL_ADMIN_USER_DEFAULT}";
  fi

  export MYSQL_ADMIN_PASSWORD_DEFAULT="secret";
  export MYSQL_ADMIN_PASSWORD_DESCRIPTION="The default password for the admin user in MySQL databases";
  if    [ "${MYSQL_ADMIN_PASSWORD+1}" != "1" ] \
     || [ "x${MYSQL_ADMIN_PASSWORD}" == "x" ]; then
    export MYSQL_ADMIN_PASSWORD="${MYSQL_ADMIN_PASSWORD_DEFAULT}";
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

  export HTTPS_DOMAIN_DEFAULT="${GETBOO_DOMAIN}";
  export HTTPS_DOMAIN_DESCRIPTION="The https domain";
  if    [ "${HTTPS_DOMAIN+1}" != "1" ] \
     || [ "x${HTTPS_DOMAIN}" == "x" ]; then
    export HTTPS_DOMAIN="${HTTPS_DOMAIN_DEFAULT}";
  fi

  export ARTIFACTORY_VERSION_DEFAULT="3.4.0";
  export ARTIFACTORY_VERSION_DESCRIPTION="The version of Artifactory";
  if    [ "${ARTIFACTORY_VERSION+1}" != "1" ] \
     || [ "x${ARTIFACTORY_VERSION}" == "x" ]; then
    export ARTIFACTORY_VERSION="${ARTIFACTORY_VERSION_DEFAULT}";
  fi
  
  export MAVEN_VERSION_DEFAULT="3.2.3";
  export MAVEN_VERSION_DESCRIPTION="The version of Maven";
  if    [ "${MAVEN_VERSION+1}" != "1" ] \
     || [ "x${MAVEN_VERSION}" == "x" ]; then
    export MAVEN_VERSION="${MAVEN_VERSION_DEFAULT}";
  fi

  export JENKINS_PASSWORD_DEFAULT="secret";
  export JENKINS_PASSWORD_DESCRIPTION="The password for the jenkins user";
  if    [ "${JENKINS_PASSWORD+1}" != "1" ] \
     || [ "x${JENKINS_PASSWORD}" == "x" ]; then
    export JENKINS_PASSWORD="${JENKINS_PASSWORD_DEFAULT}";
  fi

  export RELEASE_ISSUE_REF_DEFAULT="";
  export RELEASE_ISSUE_REF_DESCRIPTION="Text referencing a 'Release issue', to be used in commits done by Jenkins while releasing artifacts. ex: 'Ref T10' for Phabricator, 'refs #33' for Trac or Redmine";
  if    [ "${RELEASE_ISSUE_REF+1}" != "1" ] \
     || [ "x${RELEASE_ISSUE_REF}" == "x" ]; then
    export RELEASE_ISSUE_REF="${RELEASE_ISSUE_REF_DEFAULT}";
  fi

  ENV_VARIABLES=(\
    AUTHOR \
    NAMESPACE \
    MYSQL_ROOT_PASSWORD \
    MYSQL_ADMIN_USER \
    MYSQL_ADMIN_PASSWORD \
    GETBOO_DB_NAME \
    GETBOO_DB_USERNAME \
    GETBOO_DB_PASSWORD \
    GETBOO_DB_TABLE_PREFIX \
    GETBOO_DOMAIN \
    HTTPS_DOMAIN \
    TOMCAT_VERSION \
    ARTIFACTORY_VERSION \
    MAVEN_VERSION \
    JENKINS_PASSWORD \
    RELEASE_ISSUE_REF \
   );
 
  export ENV_VARIABLES;
}
