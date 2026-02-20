# watsonx Orchestrate Slackチャネル接続のためのOAuth Token設定手順

## 概要

watsonx Orchestrate（以下wxO）のエージェントをSlackチャンネルで利用する際、UIウィザードだけでは `bot_access_token` （Slack定義 `Bot User OAuth Token` ）が登録されないため、Slackからのメッセージに返答できません。本手順書ではAPIを使ってbot_access_tokenを手動登録する手順を説明します。

> **対象者：** wxOのSlackチャンネル設定ウィザードを完了したが、Slackでエージェントが返答しない方

---

## 前提条件

- IBM Cloudアカウントおよびwatsonx Orchestrateインスタンスへのアクセス権
- Slackワークスペースの管理者権限
- WSL2（Ubuntu）またはLinux/Mac環境（curl・python3が使えること）

---

## 事前準備：必要な情報の収集

以下を手元に用意してください。

| 項目 | 取得場所 |
|------|---------|
| IBM Cloud APIキー | IBM Cloud → 管理 → アクセス → APIキー |
| INSTANCE_ID | wxO UI  → 設定 → APIの詳細のサービス・インスタンスURL（例：`https://api.us-south.watson-orchestrate.cloud.ibm.com/instances/{INSTANCE_ID}`） |
| AGENT_ID | wxO UI → 対象エージェントの定義ページ → チャネル → 組み込みエージェント → Webサイトに埋め込む → サンプルembedコード内の `agentId` |
| ENVIRONMENT_ID | 同上の `agentEnvironmentId`（**Liveのみ**。Draftは不要） |
| Bot Token（xoxb-...） | api.slack.com → アプリ → OAuth & Permissions → Bot User OAuth Token |
---

## Step 1: 環境変数を設定する

`step1_set_env.sh` を編集し、取得した値を入力します。

```bash
vi step1_set_env.sh
```

- **Draftの場合：** `ENVIRONMENT_ID` は空のままにする（Step2で自動取得）
- **Liveの場合：** `ENVIRONMENT_ID` にembedコードの `agentEnvironmentId` を設定

編集後、実行します。

```bash
chmod +x step1_set_env.sh
source ./step1_set_env.sh
```

✅ **確認ポイント：** 各変数が正しく表示されること。

---

## Step 2: 各IDを自動取得する

```bash
chmod +x step2_get_ids.sh
source ./step2_get_ids.sh
```

以下が自動取得・表示されます。

| 項目 | 内容 |
|------|------|
| TOKEN | IBM Cloud認証トークン |
| SLACK_TEAM_ID | SlackワークスペースID |
| ENVIRONMENT_ID | Draft環境ID（Draftの場合のみ自動取得） |
| CHANNEL_ID | wxO上のSlackチャンネルID |

✅ **確認ポイント：** 4項目すべてが表示されること。

---

## Step 3: bot_access_tokenを登録する

```bash
chmod +x step3_patch_bot_token.sh
./step3_patch_bot_token.sh
```

✅ **確認ポイント-1：** レスポンスの `teams` 配列に `SLACK_TEAM_ID` が含まれていること。

✅ **確認ポイント-2：** Slackで `@Bot名 こんにちは` のようにメンションして返答が来ることを確認してください。

---

## トラブルシューティング

| 症状 | 確認ポイント |
|------|------------|
| `channels: []` と表示される | ウィザードでチャンネルが作成されていない |
| `Not Found` エラー | INSTANCE_ID / AGENT_ID が正しいか確認 |
| `Unauthorized` エラー | IBM_API_KEYが正しいか、またはTOKENの有効期限切れ（step2を再実行） |
| ENVIRONMENT_IDが取得できない | Draftの場合、エージェントにSlackチャネル定義が存在するか確認 |
| Slackで返答が来ない | Step3のPATCHが成功しているか確認 |
| LangFuseにエントリが来ない | bot_access_tokenが未登録の可能性あり（Step3を再実行） |

---

## 補足

2026年2月時点では、wxO UIのウィザードに `bot_access_token` の入力欄が存在しないため、本手順によるAPIでの手動登録が必要です。IBMのUIアップデートにより将来的に解消される可能性があります。
