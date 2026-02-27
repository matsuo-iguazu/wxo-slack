#!/bin/bash
source ./check.sh

echo ""
echo "=== bot_access_tokenを登録します ==="
echo "CHANNEL_ID   : ${CHANNEL_ID}"
echo "SLACK_TEAM_ID: ${SLACK_TEAM_ID}"

curl -s --request PATCH \
  --url "${BASE_URL}/agents/${AGENT_ID}/environments/${ENVIRONMENT_ID}/channels/slack/${CHANNEL_ID}" \
  --header "Authorization: Bearer ${TOKEN}" \
  --header "Content-Type: application/json" \
  --data "{\"teams\": [{\"id\": \"${SLACK_TEAM_ID}\", \"bot_access_token\": \"${SLACK_BOT_TOKEN}\"}]}" \
  | python3 -m json.tool

echo ""
echo "=== 設定を確認します ==="
curl -s --request GET \
  --url "${BASE_URL}/agents/${AGENT_ID}/environments/${ENVIRONMENT_ID}/channels/slack/${CHANNEL_ID}" \
  --header "Authorization: Bearer ${TOKEN}" \
  | python3 -m json.tool

echo ""
echo "teamsにid(SLACK_TEAM_ID)が含まれていれば設定完了です。"
echo "Slackで @Bot名 にメンションして動作確認してください。"
