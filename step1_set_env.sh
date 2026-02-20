#!/bin/bash

export IBM_API_KEY="your_ibm_api_key_here"
export INSTANCE_ID="your_instance_id_here"
export AGENT_ID="your_agent_id_here"
# Liveの場合はembedコードから取得して設定、DraftはそのままにするとStep2で自動取得
export ENVIRONMENT_ID=""
export SLACK_BOT_TOKEN="xoxb-your-bot-token-here"

export BASE_URL="https://api.us-south.watson-orchestrate.cloud.ibm.com/instances/${INSTANCE_ID}/v1/orchestrate"

echo "=== Step1: 環境変数の確認 ==="
echo "IBM_API_KEY    : ${IBM_API_KEY:0:10}..."
echo "INSTANCE_ID    : ${INSTANCE_ID}"
echo "AGENT_ID       : ${AGENT_ID}"
echo "ENVIRONMENT_ID : ${ENVIRONMENT_ID:-（未設定 → Step2で自動取得）}"
echo "SLACK_BOT_TOKEN: ${SLACK_BOT_TOKEN:0:15}..."
