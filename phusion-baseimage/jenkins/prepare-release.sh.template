#!/bin/bash

_group="$1"
if [ "x${_group}" == "x" ]; then
  echo "Group is mandatory";
  exit 1;
else
  shift;
fi
_artifact="$1"
if [ "x${_artifact}" == "x" ]; then
  echo "Artifact is mandatory";
  exit 1;
else
  shift;
fi
_version="$1"
if [ "x${_version}" == "x" ]; then
  echo "Version is mandatory";
  exit 1;
else
  shift;
fi
_repo="$1"
if [ "x${_repo}" == "x" ]; then
  echo "Repo is mandatory";
  exit 1;
else
  shift;
fi
cat <<EOF > release.properties
scm.commentPrefix=${RELEASE_ISSUE_REF}
pushChanges=true
dependency.${_group}\:${_artifact}.development=latest-SNAPSHOT
project.scm.${_group}\:${_artifact}.connection=scm\:git\:${_repo}
scm.tag=${_artifact}-${_version}
scm.tagBase=${_repo}
remoteTagging=true
exec.additionalArguments=
project.dev.${_group}\:${_artifact}=latest-SNAPSHOT
project.scm.${_group}\:${_artifact}.tag=HEAD
scm.url=scm\:git\:${_repo}
scm.tagNameFormat=@{project.artifactId}-@{project.version}
commitByProject=true
preparationGoals=clean verify
project.scm.${_group}\:${_artifact}.url=${_repo}
exec.snapshotReleasePluginAllowed=false
project.scm.${_group}\:${_artifact}.developerConnection=scm\:git\:${_repo}
dependency.${_group}\:${_artifact}.release=${_version}
project.rel.${_group}\:${_artifact}=${_version}
completedPhase=end-release
EOF
