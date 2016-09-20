#!/bin/sh 

# Generates the default exhibitor config and launches exhibitor

PATH=${PATH}:${JAVA_HOME}/bin
MISSING_VAR_MESSAGE="must be set"
DEFAULT_AWS_REGION="us-east-1"
DEFAULT_SETTLING_PERIOD_MS=0
DEFAULT_CLUSTER_SIZE=5
DEFAULT_CONFIG_TYPE=s3
: ${HOSTNAME:?$MISSING_VAR_MESSAGE}
: ${CONFIG_TYPE:$DEFAULT_CONFIG_TYPE}
: ${CLUSTER_SIZE:$DEFAULT_CLUSTER_SIZE}
: ${AWS_REGION:=$DEFAULT_AWS_REGION}
: ${SETTLING_PERIOD_MS:=$DEFAULT_SETTLING_PERIOD_MS}

if [ "${CONFIG_TYPE}" = "s3" ]; then
: ${S3_BUCKET:?$MISSING_VAR_MESSAGE}
: ${S3_PREFIX:?$MISSING_VAR_MESSAGE}
fi


cat <<- EOF > /opt/exhibitor/defaults.conf
zookeeper-data-directory=/opt/zookeeper/snapshots
zookeeper-install-directory=/opt/zookeeper
zookeeper-log-directory=/opt/zookeeper/transactions
log-index-directory=/opt/zookeeper/transactions
cleanup-period-ms=300000
check-ms=30000
backup-period-ms=600000
client-port=2181
cleanup-max-files=20
backup-max-store-ms=21600000
connect-port=2888
election-port=3888
auto-manage-instances-settling-period-ms=${SETTLING_PERIOD_MS}
auto-manage-instances-fixed-ensemble-size=${CLUSTER_SIZE}
observer-threshold=$((${CLUSTER_SIZE} + 1))
zoo-cfg-extra=tickTime\=2000&initLimit\=10&syncLimit\=5&quorumListenOnAllIPs\=true
auto-manage-instances=1
EOF

if [ "${CONFIG_TYPE}" = "s3" ]; then
cat <<- EOF >> /opt/exhibitor/defaults.conf
backup-extra=throttle\=&bucket-name\=${S3_BUCKET}&key-prefix\=${S3_PREFIX}&max-retries\=4&retry-sleep-ms\=30000
EOF
fi


if [[ -n ${ZK_PASSWORD} ]]; then
	SECURITY="--security web.xml --realm Zookeeper:realm --remoteauth basic:zk"
	echo "zk: ${ZK_PASSWORD},zk" > realm
fi

if [ "${CONFIG_TYPE}" = "s3" ]; then
    exec 2>&1 java -jar /opt/exhibitor/exhibitor-standalone.jar \
    --port 8181 --defaultconfig /opt/exhibitor/defaults.conf \
    --configtype ${CONFIG_TYPE} --s3config ${S3_BUCKET}:${S3_PREFIX} \
    --s3region ${AWS_REGION} --s3backup true --hostname ${HOSTNAME} \
    ${SECURITY}
fi

if [ "${CONFIG_TYPE}" = "file" ]; then
  exec 2>&1 java -jar /opt/exhibitor/exhibitor-standalone.jar \
    --port 8181 --defaultconfig /opt/exhibitor/defaults.conf \
    --configtype ${CONFIG_TYPE} --hostname ${HOSTNAME} \
    ${SECURITY}
fi
