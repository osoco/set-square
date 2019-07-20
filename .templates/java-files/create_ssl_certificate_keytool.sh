#!/bin/bash dry-wit
# Copyright 2015-today Automated Computing Machinery S.L.
# Distributed under the terms of the GNU General Public License v3
# mod: java/create_ssl_certificate_keytool
# api: public
# txt: Creates a SSL certificate.
# txt: See http://www.eclipse.org/jetty/documentation/current/configuring-ssl.html

# fun: generateAndSignCertificate
# api: public
# txt: Generates and signs a new certificate.
# txt: See https://stackoverflow.com/questions/33827789/self-signed-certificate-dnsname-components-must-begin-with-a-letter
# txt: Returns 0/TRUE if the certificate is generated and signed successfully; 1/FALSE otherwise.
# use: if generateAndSignCertificate; then echo "New signed certificate: ${RESULT}"; fi
function generateAndSignCertificate() {
  local -i _rescode;

  keytool -keystore "${SSL_KEYSTORE_PATH}" \
          -alias "${SSL_CERTIFICATE_ALIAS}" \
          -genkey \
          -noprompt \
          -dname "${SSL_CERTIFICATE_DNAME}" \
          -keyalg "${SSL_KEY_ALGORITHM}" \
          -keypass "${SSL_KEY_PASSWORD}" \
          -storepass "${SSL_KEYSTORE_PASSWORD}" \
          -storetype "${SSL_KEYSTORE_TYPE}" \
          -keysize ${SSL_KEY_LENGTH} \
          -validity ${SSL_CERTIFICATE_EXPIRATION_DAYS} \
          -sigalg "${SSL_JAVA_SIGN_ALGORITHM}";
#          -ext "SAN=${SSL_SAN_EXTENSIONS}";
  _rescode=$?;
  if isFalse ${_rescode}; then
    echo keytool -keystore "${SSL_KEYSTORE_PATH}" \
            -alias "${SSL_CERTIFICATE_ALIAS}" \
            -genkey \
            -noprompt \
            -dname "${SSL_CERTIFICATE_DNAME}" \
            -keyalg "${SSL_KEY_ALGORITHM}" \
            -keypass "${SSL_KEY_PASSWORD}" \
            -storepass "${SSL_KEYSTORE_PASSWORD}" \
            -storetype "${SSL_KEYSTORE_TYPE}" \
            -keysize ${SSL_KEY_LENGTH} \
            -validity ${SSL_CERTIFICATE_EXPIRATION_DAYS} \
            -sigalg "${SSL_JAVA_SIGN_ALGORITHM}";
    #          -ext "SAN=${SSL_SAN_EXTENSIONS}";
  fi

  return ${_rescode};
}

## Main logic
## dry-wit hook
function main() {
  logInfo -n "Signing the SSL certificate";
  if generateAndSignCertificate; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
    exitWithErrorCode CANNOT_GENERATE_AND_SIGN_SSL_CERTIFICATE;
  fi

  logInfo -n "Fixing permissions of ${_dir}";
  if isTrue updateFolderPermissions "${SSL_KEYSTORE_FOLDER}" "${SERVICE_USER}" "${SERVICE_GROUP}"; then
    logInfoResult SUCCESS "done";
  else
    logInfoResult FAILURE "failed";
    exitWithErrorCode CANNOT_UPDATE_KEYSTORE_FOLDER_PERMISSIONS;
  fi
}
## Script metadata and CLI settings.
setScriptDescription "Creates a SSL certificate using Java keytool";

addError CANNOT_GENERATE_AND_SIGN_SSL_CERTIFICATE "Cannot generate and sign the SSL certificate";

defineEnvVar SSL_KEYSTORE_PATH MANDATORY "The path of the SSL keystore" "";
defineEnvVar SSL_CERTIFICATE_ALIAS MANDATORY "The alias of the SSL certificate" "";
defineEnvVar SSL_CERTIFICATE_DNAME MANDATORY "The DNAME of the SSL certificate" "";
defineEnvVar SSL_KEY_ALGORITHM MANDATORY "The algorithm of the SSL key" "";
defineEnvVar SSL_KEY_PASSWORD MANDATORY "The password of the SSL key" "";
defineEnvVar SSL_KEYSTORE_PASSWORD MANDATORY "The password of the SSL keystore" "";
defineEnvVar SSL_KEYSTORE_TYPE MANDATORY "The type of the SSL keystore" "";
defineEnvVar SSL_KEY_LENGTH MANDATORY "The length of the SSL key" "";
defineEnvVar SSL_CERTIFICATE_EXPIRATION_DAYS MANDATORY "The days until the SSL certificate expires" 365;
defineEnvVar SSL_JAVA_SIGN_ALGORITHM MANDATORY "The Java algorithm used for signing" "";
defineEnvVar SSL_SAN_EXTENSIONS OPTIONAL "The SAN extensions" "";

checkReq keytool;

addError CANNOT_SIGN_SSL_CERTIFICATE "Cannot sign the SSL certificate";
addError CANNOT_UPDATE_KEYSTORE_FOLDER_PERMISSIONS "Cannot update the permissions of ${SSL_KEYSTORE_FOLDER}";


# vim: syntax=sh ts=2 sw=2 sts=4 sr noet

