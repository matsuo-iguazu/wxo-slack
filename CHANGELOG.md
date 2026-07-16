# 変更履歴

## 2026-07-16

### AWS MCSP 認証を V2 エンドポイントに更新

- AWS 版のトークン取得エンドポイントを MCSP V1（サンセット済み）から V2 に変更
  - 変更前: `iam.platform.saas.ibm.com/siusermgr/api/1.0/apikeys/token`
  - 変更後: `account-iam.platform.saas.ibm.com/api/2.0/apikeys/token`
- IBM Cloud 側（`iam.cloud.ibm.com`）は変更なし

---

## 2026-06-29

### AWS版 watsonx Orchestrate に対応

- `IBM_API_KEY` を `WXO_API_KEY` にリネーム（IBM Cloud / AWS 共通の変数名へ）
- `check.sh` に認証方式の自動判定を追加
  - `INSTANCE_URL` のドメインが `watson-orchestrate.cloud.ibm.com` の場合 → IBM Cloud IAM 認証
  - それ以外（`dl.watson-orchestrate.ibm.com` など）の場合 → AWS MCSP 認証（`iam.platform.saas.ibm.com`）
- `.env.sample` に IBM Cloud / AWS 両方の INSTANCE_URL 例を追記
- README を IBM Cloud / AWS 両環境向けに更新

---

## 2026-02-27

### ファイル構成をリネームし操作フローを簡略化（Close #1）

- `step1_set_env.sh` → `.env`（設定ファイル、実行不要）
- `step2_get_ids.sh` → `check.sh`（設定確認・デバッグ用）
- `step3_patch_bot_token.sh` → `register.sh`（bot_access_token 登録）
- `.env` の変数構成を `INSTANCE_URL` ベースに変更（`INSTANCE_ID` + `REGION` を統合）
- `.env.sample` を追加、`.env` を `.gitignore` に追加
- README を全面改訂

---

## 2026-02-21

### Initial commit

- wxO Slack チャンネルの `bot_access_token` を API で手動登録するスクリプトを公開
