#!/bin/bash
source ./.env

echo "=== 設定確認 ==="
echo "IBM_API_KEY    : ${IBM_API_KEY:0:10}..."
echo "INSTANCE_URL   : ${INSTANCE_URL}"
echo "AGENT_ID       : ${AGENT_ID}"
echo "ENVIRONMENT_ID : ${ENVIRONMENT_ID:-（未設定 → 自動取得）}"
echo "SLACK_BOT_TOKEN: ${SLACK_BOT_TOKEN:0:15}..."

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
echo "--- Environment ID（Draftのみ自動取得） ---"
if [ -z "${ENVIRONMENT_ID}" ]; then
  export ENVIRONMENT_ID=$(curl -s --request GET \
    --url "${BASE_URL}/agents/${AGENT_ID}" \
    --header "Authorization: Bearer ${TOKEN}" \
    | python3 -c "import sys,json; data=json.load(sys.stdin); print(next(e['id'] for e in data['environments'] if e['name']=='draft'))")
  echo "ENVIRONMENT_ID: ${ENVIRONMENT_ID} （自動取得）"
else
  echo "ENVIRONMENT_ID: ${ENVIRONMENT_ID} （.envで設定済み）"
fi

echo ""
echo "--- Slack Channel ID ---"
export CHANNEL_ID=$(curl -s --request GET \
  --url "${BASE_URL}/agents/${AGENT_ID}/environments/${ENVIRONMENT_ID}/channels/slack" \
  --header "Authorization: Bearer ${TOKEN}" \
  | python3 -c "import sys,json; data=json.load(sys.stdin); print(data['channels'][0]['id'])")
echo "CHANNEL_ID: ${CHANNEL_ID}"

echo ""
echo "=== 確認完了 ==="
