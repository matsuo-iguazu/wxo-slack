#!/bin/bash
source ./step1_set_env.sh

echo ""
echo "=== Step2: 各IDを取得します ==="

echo ""
echo "--- IBM Token ---"
export TOKEN=$(curl -s -X POST \
  "https://iam.cloud.ibm.com/identity/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=${IBM_API_KEY}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
echo "TOKEN: ${TOKEN:0:20}..."

echo ""
echo "--- Slack Team ID ---"
export SLACK_TEAM_ID=$(curl -s --request GET \
  --url "https://slack.com/api/auth.test" \
  --header "Authorization: Bearer ${SLACK_BOT_TOKEN}" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['team_id'])")
echo "SLACK_TEAM_ID: ${SLACK_TEAM_ID}"

echo ""
echo "--- Environment ID（DraftのみStep2で自動取得） ---"
if [ -z "${ENVIRONMENT_ID}" ]; then
  export ENVIRONMENT_ID=$(curl -s --request GET \
    --url "${BASE_URL}/agents/${AGENT_ID}" \
    --header "Authorization: Bearer ${TOKEN}" \
    | python3 -c "import sys,json; data=json.load(sys.stdin); print(next(e['id'] for e in data['environments'] if e['name']=='draft'))")
  echo "ENVIRONMENT_ID: ${ENVIRONMENT_ID} （自動取得）"
else
  echo "ENVIRONMENT_ID: ${ENVIRONMENT_ID} （Step1で設定済み）"
fi

echo ""
echo "--- Slack Channel ID ---"
export CHANNEL_ID=$(curl -s --request GET \
  --url "${BASE_URL}/agents/${AGENT_ID}/environments/${ENVIRONMENT_ID}/channels/slack" \
  --header "Authorization: Bearer ${TOKEN}" \
  | python3 -c "import sys,json; data=json.load(sys.stdin); print(data['channels'][0]['id'])")
echo "CHANNEL_ID: ${CHANNEL_ID}"

echo ""
echo "=== Step2完了 ==="