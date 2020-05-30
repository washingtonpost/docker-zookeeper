# datadog.zookeeper.sh 
cat <<- 'EOF' > /etc/dd-agent/conf.d/zk.yaml
init_config:

instances:
    -   host: localhost
        port: 2181
        timeout: 3
EOF
# datadog.start
{%- if DATADOG_API_KEY is defined %}
DATADOG_API_KEY="{{DATADOG_API_KEY}}"
{%- endif %}
sh -c "sed 's/api_key:.*/api_key: ${DATADOG_API_KEY}/' /etc/dd-agent/datadog.conf.example > /etc/dd-agent/datadog.conf"

sudo rm /opt/datadog-agent/agent/datadog-cert.pem && sudo service datadog-agent restart
