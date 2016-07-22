#!/bin/bash

if [ ! $(which jq) ]; then
    echo "jq not installed, please install jq to run this script"
    echo "or run using the Dockerfile in the same path as this script"
    echo "exiting"
    exit 1
fi

if [ ! $1 ]; then
    read -p "Enter in your Slack webhook URL: " SLACK_WEBHOOK
fi

if [ ! $2 ]; then
    read -p "Enter in the Slack channel that you want to send alerts to (e.g. #general): " SLACK_CHANNEL
fi

echo "Health check registered in the Consul API"
echo "======================================="
echo 'curl -s http://localhost:8500/v1/health/service/nginx-demo | jq .'
curl -s http://localhost:8500/v1/health/service/nginx-demo | jq .
echo ""

echo "Add in Slack integration with KV values"
echo "======================================="
echo 'curl -s -X PUT -d "true" http://localhost:8500/v1/kv/consul-alerts/config/notifiers/slack/enabled'
curl -s -X PUT -d "true" http://localhost:8500/v1/kv/consul-alerts/config/notifiers/slack/enabled; echo ""
echo "curl -s -X PUT -d "${SLACK_WEBHOOK}" http://localhost:8500/v1/kv/consul-alerts/config/notifiers/slack/url"
curl -s -X PUT -d "${SLACK_WEBHOOK}" http://localhost:8500/v1/kv/consul-alerts/config/notifiers/slack/url; echo ""
echo "curl -s -X PUT -d "${SLACK_CHANNEL}" http://localhost:8500/v1/kv/consul-alerts/config/notifiers/slack/channel"
curl -s -X PUT -d "${SLACK_CHANNEL}" http://localhost:8500/v1/kv/consul-alerts/config/notifiers/slack/channel; echo ""
echo ""

echo "Decrease notification send time"
echo "======================================="
echo 'curl -s -X PUT -d "20" http://localhost:8500/v1/kv/consul-alerts/config/checks/change-threshold'
curl -s -X PUT -d "20" http://localhost:8500/v1/kv/consul-alerts/config/checks/change-threshold; echo ""
echo ""

echo "Values in Consul KV store"
echo "======================================="
curl -s http://localhost:8500/v1/kv/consul-alerts/config/notifiers/slack/?recurse | jq .

echo ""
curl -s http://localhost:8500/v1/kv/consul-alerts/config/notifiers/slack/enabled?raw; echo ""
curl -s http://localhost:8500/v1/kv/consul-alerts/config/notifiers/slack/url?raw; echo ""
curl -s http://localhost:8500/v1/kv/consul-alerts/config/notifiers/slack/channel?raw; echo ""

