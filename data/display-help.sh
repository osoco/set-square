#!/bin/bash

_namespace="$(head -n 1 /Dockerfiles/Dockerfile | sed 's_^#\s\+__g' | cut -d'/' -f 1)";
_repo="$(head -n 1 /Dockerfiles/Dockerfile | sed 's_^#\s\+__g' | cut -d'/' -f 2 | cut -d':' -f 1)";
_tag="$(head -n 1 /Dockerfiles/Dockerfile | sed 's_^#\s\+__g' | cut -d'/' -f 2 | cut -d':' -f 2 | cut -d' ' -f 1)";

cat <<EOF
${_namespace}/${_repo}:${_tag}
(c) 2015-today Automated Computing Machinery S.L.
    Distributed under the terms of the GNU General Public License v3

EOF

[ -f /README ] && NAMESPACE="${_namespace}" REPO="${_repo}" TAG="${_tag}" envsubst '${NAMESPACE} ${REPO} ${TAG}' < /README

cat <<EOF

This image was generated with rydnr's script:
https://github.com/rydnr/dockerfile

The Dockerfiles used to build this image can be inspected.
This Dockerfile:
> docker run -it ${_namespace}/${_repo}:${_tag} Dockerfile
or 
> docker run -it ${_namespace}/${_repo}:${_tag} Dockerfile ${_namespace}-${_repo}.${_tag}
Its parents (in order):
EOF

for d in $(ls -t /Dockerfiles/* | grep -v -e '^/Dockerfiles/Dockerfile$' | grep -v -e "^/Dockerfiles/${_namespace}-${_repo}\.${_tag}$"); do
  echo "> docker run -it ${_namespace}/${_repo}:${_tag} Dockerfile $(basename $d)";
done
