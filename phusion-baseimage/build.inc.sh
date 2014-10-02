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

  export TOMCAT_VERSION_DEFAULT="8.0.12";
  export TOMCAT_VERSION_DESCRIPTION="The version of the Tomcat server";
  if    [ "${TOMCAT_VERSION+1}" != "1" ] \
     || [ "x${TOMCAT_VERSION}" == "x" ]; then
    export TOMCAT_VERSION="${TOMCAT_VERSION_DEFAULT}";
  fi
  
 ENV_VARIABLES=(\
    AUTHOR \
    NAMESPACE \
    TOMCAT_VERSION \
 );
 
  export ENV_VARIABLES;
}
