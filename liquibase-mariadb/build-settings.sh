defineEnvVar MARIADB_JDBC_DRIVER_VERSION "The version of the JDBC driver for MariaDB" "1.2.3";
defineEnvVar MARIADB_JDBC_DRIVER_ARTIFACT "The name of the MariaDB JDBC driver artifact" 'mariadb-java-client-${MARIADB_JDBC_DRIVER_VERSION}.jar';
defineEnvVar MARIADB_JDBC_DRIVER_URL "The url of the MariaDB JDBC driver artifact" 'http://central.maven.org/maven2/org/mariadb/jdbc/mariadb-java-client/${MARIADB_JDBC_DRIVER_VERSION}/${MARIADB_JDBC_DRIVER_ARTIFACT}';
