FROM ${NAMESPACE}/java:${TAG}
MAINTAINER ${MAINTAINER}

COPY liquibase.sh /usr/local/bin/liquibase
ENTRYPOINT [ "/usr/local/bin/liquibase" ]

RUN mkdir /opt/liquibase-${LIQUIBASE_VERSION} && \
    cd /opt/liquibase-${LIQUIBASE_VERSION} && \
    wget ${LIQUIBASE_URL} && \
    tar xvf ${LIQUIBASE_ARTIFACT} -C /opt/liquibase-${LIQUIBASE_VERSION} && \
    rm -f /opt/${LIQUIBASE_ARTIFACT} && \
    chmod +x /usr/local/bin/liquibase

# Run with
# docker run --link [db-container]:db ${NAMESPACE}/${IMAGE}:${TAG}
