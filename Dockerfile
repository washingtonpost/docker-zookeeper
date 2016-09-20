FROM alpine:3.4
RUN apk update && \
    apk upgrade && \
    apk add --update --no-cache \
            openjdk8 \
            bash \
            wget && \
     rm -rf /var/cache/apk/* 
ENV JAVA_HOME=/usr/lib/jvm/default-jvm \
    ZOOKEEPER_VERSION=3.4.9 \
    EXHIBITOR_VERSION=1.5.6

RUN wget http://apache.claz.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/zookeeper-${ZOOKEEPER_VERSION}.tar.gz \
    -O /tmp/zookeeper-${ZOOKEEPER_VERSION}.tar.gz && \
    mkdir /opt && \
    tar -xzf /tmp/zookeeper-${ZOOKEEPER_VERSION}.tar.gz -C /opt && \
    rm -f /tmp/zookeeper-${ZOOKEEPER_VERSION}.tar.gz && \
    ln -s /opt/zookeeper-${ZOOKEEPER_VERSION} /opt/zookeeper && \
    mkdir /opt/zookeeper/transactions /opt/zookeeper/snapshots

WORKDIR /opt/exhibitor
COPY exhibitor-${EXHIBITOR_VERSION}/exhibitor.sh ./exhibitor.sh
COPY exhibitor-${EXHIBITOR_VERSION}/exhibitor-standalone.jar ./exhibitor-standalone.jar
COPY exhibitor-${EXHIBITOR_VERSION}/web.xml ./web.xml

EXPOSE 8181

RUN chmod +x /opt/exhibitor/exhibitor.sh

CMD ["/opt/exhibitor/exhibitor.sh"]
