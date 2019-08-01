#!/bin/bash dry-wit
# mod: help/display-help
# api: public
# txt: Displays how to use this Docker image.

# fun: retrieveNamespace
# api: public
# txt: Retrieves the namespace of the Docker image.
# txt: Returns 0/TRUE if the namespace could be retrieved; 1/FALSE otherwise.
# txt: The variable RESULT contains the namespace if the function succeeds.
# use: if retrieveNamespace; then echo "Namespace: ${RESULT}"; fi
function retrieveNamespace() {
  local -i _rescode;
  local _result="$(head -n 1 /Dockerfiles/Dockerfile | sed 's_^#\s\+__g' | cut -d'/' -f 1 2> /dev/null)";
  _rescode=$?;
  if isTrue ${_rescode}; then
    export RESULT="${_result}";
  fi
  return ${_rescode};
}

# fun: retrieveImageName
# api: public
# txt: Retrieves the name of the Docker image.
# txt: Returns 0/TRUE if the image name could be retrieved; 1/FALSE otherwise.
# txt: The variable RESULT contains the name if the function succeeds.
# use: if retrieveImageName; then echo "Image: ${RESULT}"; fi
function retrieveImageName() {
  local -i _rescode;
  local _result="$(head -n 1 /Dockerfiles/Dockerfile | sed 's_^#\s\+__g' | cut -d'/' -f 2 | cut -d':' -f 1 2> /dev/null)";
  _rescode=$?;
  if isTrue ${_rescode}; then
    export RESULT="${_result}";
  fi
  return ${_rescode};
}

# fun: retrieveImageTag
# api: public
# txt: Retrieves the tag of the Docker image.
# txt: Returns 0/TRUE if the image tag could be retrieved; 1/FALSE otherwise.
# txt: The variable RESULT contains the tag if the function succeeds.
# use: if retrieveImageTag; then echo "Tag: ${RESULT}"; fi
function retrieveImageTag() {
  local -i _rescode;
  local _result="$(head -n 1 /Dockerfiles/Dockerfile | sed 's_^#\s\+__g' | cut -d'/' -f 2 | cut -d':' -f 2 | cut -d' ' -f 1 2> /dev/null)";
  _rescode=$?;
  if isTrue ${_rescode}; then
    export RESULT="${_result}";
  fi
  return ${_rescode};
}

# fun: main
# api: public
# txt: Displays how to use this Docker image.
# txt: Returns 0/TRUE always.
# use: main
function main() {
  local _namespace;
  local _image;
  local _tag;
  local _parents;
  local -i _firstParent;

  if retrieveNamespace; then
    _namespace="${RESULT}";
  else
    exitWithErrorCode CANNOT_RETRIEVE_NAMESPACE;
  fi
  if retrieveImageName; then
    _image="${RESULT}";
  else
    exitWithErrorCode CANNOT_RETRIEVE_IMAGE_NAME;
  fi
  if retrieveImageTag; then
    _tag="${RESULT}";
  else
    exitWithErrorCode CANNOT_RETRIEVE_IMAGE_TAG;
  fi

  cat <<EOF
${_namespace}/${_image}:${_tag}
EOF
  cat /copyright.txt

  [ -f /README ] && NAMESPACE="${_namespace}" IMAGE="${_image}" TAG="${_tag}" envsubst '${NAMESPACE} ${IMAGE} ${TAG}' < /README

  _parents="$(ls -t /Dockerfiles/* | grep -v -e '^/Dockerfiles/Dockerfile$' | grep -v -e "^/Dockerfiles/${_namespace}-${_image}\.${_tag}$")";

  cat <<EOF
This image was generated with set-square:
https://github.com/rydnr/set-square

The Dockerfiles used to build this image can be inspected.
> docker run -it ${_namespace}/${_image}:${_tag} Dockerfile
EOF

  local _oldIFS="${IFS}";
  IFS="${DWIFS}";
  for d in ${_parents}; do
    IFS="${_oldIFS}";
    echo "> docker run -it ${_namespace}/${_image}:${_tag} Dockerfile $(basename $d)";
  done
  IFS="${_oldIFS}";
}

## Script metadata and CLI settings.
setScriptDescription "Displays how to use this Docker image";

addError CANNOT_RETRIEVE_NAMESPACE "Could not retrieve the namespace information from the Dockerfile";
addError CANNOT_RETRIEVE_IMAGE_NAME "Could not retrieve the image name from the Dockerfile";
addError CANNOT_RETRIEVE_IMAGE_TAG "Could not retrieve the image tag from the Dockerfile";
# vim: syntax=sh ts=2 sw=2 sts=4 sr noet
