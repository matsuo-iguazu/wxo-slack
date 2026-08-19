# watsonx Orchestrate Slackチャネル接続のためのOAuth Token設定手順

## 概要

watsonx Orchestrate（以下wxO）のエージェントをSlackチャンネルで利用する際、UIウィザードだけでは `bot_access_token`（Slack定義 `Bot User OAuth Token`）が登録されないため、Slackからのメッセージに返答できません。本手順書ではAPIを使ってbot_access_tokenを手動登録する手順を説明します。

> **対象者：** wxOのSlackチャンネル設定ウィザードを完了したが、Slackでエージェントが返答しない方

> **【2026-08-19】** 本事象の根本原因と修正予定が判明しました。詳細は末尾の「補足」をご確認ください。

---

## 前提条件

- watsonx OrchestrateインスタンスへのAPIアクセス権（IBM Cloud / AWS どちらの環境にも対応）
- Slackワークスペースの管理者権限
- WSL2（Ubuntu）またはLinux/Mac環境（curl・python3が使えること）

---

## 事前準備：必要な情報の収集

以下を手元に用意してください。

| 項目 | 取得場所 |
|------|---------|
| wxO APIキー | **IBM Cloud：** 管理 → アクセス → APIキー<br>**AWS：** wxO UI → 設定 → APIの詳細 → Generate API key |
| サービス・インスタンスURL | wxO UI → 設定 → APIの詳細 → サービス・インスタンスURL<br>IBM Cloud 例：`https://api.us-south.watson-orchestrate.cloud.ibm.com/instances/{instance-id}`<br>AWS 例：`https://api.ap-southeast-1.dl.watson-orchestrate.ibm.com/instances/{instance-id}` |
| AGENT_ID | wxO UI → 対象エージェント → チャネル → 組み込みエージェント → Webサイトに埋め込む → サンプルembedコード内の `agentId` |
| ENVIRONMENT_ID | 同上の `agentEnvironmentId`（**Liveのみ**。Draftは不要） |
| Bot Token（xoxb-...） | api.slack.com → アプリ → OAuth & Permissions → Bot User OAuth Token |

---

## 操作手順

### 1. `.env` を作成して値を入力する

```bash
cp .env.sample .env
vi .env
```

ファイルのコメントに従い、各値を入力してください。

- `INSTANCE_URL`：wxO UIのサービス・インスタンスURLをそのままコピーして設定
- `ENVIRONMENT_ID`：Draftの場合は空のままにする（`register.sh` が自動取得）。Liveの場合は `agentEnvironmentId` を設定
- `BASE_URL`：編集不要（`INSTANCE_URL` から自動設定）

### 2. 設定を確認する

```bash
chmod +x check.sh
./check.sh
```

各IDが正しく取得・表示されることを確認します。

| 表示項目 | 内容 |
|----------|------|
| TOKEN | 認証トークン（IBM Cloud IAM / AWS MCSP を自動判定） |
| SLACK_TEAM_ID | SlackワークスペースID |
| ENVIRONMENT_ID | 環境ID（DraftはAPI経由で自動取得） |
| CHANNEL_ID | wxO上のSlackチャンネルID |

### 3. `register.sh` を実行して bot_access_token を登録する

```bash
chmod +x register.sh
./register.sh
```

✅ **確認ポイント-1：** レスポンスの `teams` 配列に `SLACK_TEAM_ID` が含まれていること。

✅ **確認ポイント-2：** Slackで `@Bot名 こんにちは` のようにメンションして返答が来ること。

---

## トラブルシューティング

| 症状 | 確認ポイント |
|------|------------|
| `channels: []` と表示される | ウィザードでチャンネルが作成されていない |
| `Not Found` エラー | `INSTANCE_URL` / `AGENT_ID` が正しいか確認 |
| `Unauthorized` エラー | `WXO_API_KEY` が正しいか、またはTOKENの有効期限切れ（`check.sh` を再実行） |
| ENVIRONMENT_IDが取得できない | Draftの場合、エージェントにSlackチャネル定義が存在するか確認 |
| Slackで返答が来ない | `register.sh` のPATCHが成功しているか確認 |
| `register.sh` 成功後もSlackで返答が来ない | api.slack.com → アプリ → Socket Mode が **無効** になっているか確認。有効になっているとイベントがwxOに届かない |
| LangFuseにエントリが来ない | bot_access_tokenが未登録の可能性あり（`register.sh` を再実行） |

---

## 補足

2026年2月時点では、wxO UIのウィザードに `bot_access_token` の入力欄が存在しないため、本手順によるAPIでの手動登録が必要です。

**【2026-08-19 追記】** IBMサポートより根本原因と修正予定の回答を得ました。

- **根本原因：** watsonx Orchestrate にログインしているユーザーのメールアドレスに**アンダースコア（_）が含まれる**場合、Slack チャネルの OAuth 設定後の処理にバグがあり、team 情報が登録されない事象（社内 Defect DT466907）
- **修正状況：** 修正コードは 2026-07-30 にマージ済み、**2026-08-28 予定の定期更新への適用が見込まれています**

8月28日以降のリリースが適用された環境では、ウィザードの再実行のみで設定が完了できる見込みです。それまでの間は本手順をご利用ください。
