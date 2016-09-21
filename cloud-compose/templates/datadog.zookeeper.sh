# datadog.zookeeper.sh 
cat <<- 'EOF' > /etc/dd-agent/conf.d/zk.yaml
init_config:

instances:
    -   host: localhost
        port: 2181
        timeout: 3
EOF
# datadog.start
sh -c "sed 's/api_key:.*/api_key: {{DATADOG_API_KEY}}/' /etc/dd-agent/datadog.conf.example > /etc/dd-agent/datadog.conf"
service datadog-agent restart
