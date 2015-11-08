FROM ${NAMESPACE}/sdkman:${TAG}
MAINTAINER ${MAINTAINER}

USER developer

RUN cd /home/developer && \
    source /home/developer/.sdkman/bin/sdkman-init.sh && \
    sdk install gradle ${GRADLE_VERSION}