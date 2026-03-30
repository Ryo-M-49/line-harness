# LINE Harness セットアップログ

作成日: 2026-03-25

---

## 実施した作業一覧

### 1. 環境構築

| 作業 | 詳細 |
|------|------|
| リポジトリをclone | `git clone git@github.com:Ryo-M-49/line-harness.git` → `cc-company/` 配下に移動 |
| pnpmインストール | `npm install -g pnpm` → `pnpm install` |
| tsconfig.base.json修正 | `packages/tsconfig.base.json` がルートから参照できずビルドエラーになったので、ルートにコピー |
| パッケージビルド | `pnpm -r build` で `@line-crm/line-sdk` 等をビルド（Workerがimportするため必要） |

### 2. ローカル動作確認

| 作業 | 詳細 |
|------|------|
| ローカルD1作成 | `wrangler d1 execute line-crm --file=packages/db/schema.sql --local` でスキーマ投入（42テーブル） |
| `.dev.vars` 作成 | `apps/worker/.dev.vars` にダミーのAPIキー・LINE認証情報を記載（ローカル用） |
| Worker起動 | `pnpm dev:worker` → localhost で起動確認 |
| API動作テスト | curlでタグ作成、シナリオ作成、ステップ追加、ブロードキャスト、自動化ルール、スコアリングルール、テンプレートを一通り実行 |

### 3. 本番デプロイ

| 作業 | 詳細 |
|------|------|
| D1データベース作成 | `wrangler d1 create line-crm` → ID: `734a6682-b446-4706-8348-556fded7a5b1` |
| wrangler.toml更新 | `database_id` と `WORKER_URL` を本番値に書き換え |
| リモートD1にスキーマ投入 | `--remote` フラグで本番D1に42テーブル作成 |
| APIキー生成 | `openssl rand -hex 32` で生成 |
| シークレット設定（初回） | `wrangler secret put` でAPI_KEY + ダミーのLINE認証情報5つを設定 |
| Workerデプロイ | `apps/worker/` で `wrangler deploy` → `https://line-crm-worker.ryo-m-code.workers.dev` |
| 本番API動作確認 | curlでfriends/count、タグ作成が通ることを確認 |

### 4. GitHub連携

| 作業 | 詳細 |
|------|------|
| CLOUDFLARE_ACCOUNT_ID設定 | `gh secret set` でGitHub Secretsに追加 |
| CLOUDFLARE_API_TOKEN設定 | 手動でCloudflareダッシュボードからトークン作成 → `gh secret set` |
| コミット＆プッシュ | wrangler.toml + tsconfig.base.jsonの変更をmainにpush |
| 自動デプロイ | `.github/workflows/deploy-worker.yml` が設定済み。mainへのpush時に自動デプロイ |

### 5. LINE連携

| 作業 | 詳細 |
|------|------|
| LINE Developersでチャネル作成（手動） | Messaging API + LINE Login（IDはLINE Developers Console参照） |
| シークレット更新 | チャネル認証情報4つを `wrangler secret put` で本番に反映 |
| Webhook URL設定（手動） | LINE Developers Console で `https://line-crm-worker.ryo-m-code.workers.dev/webhook` を設定 |
| Webhook疎通確認 | LINE APIの `/v2/bot/channel/webhook/test` で200 OK確認 |
| Bot情報確認 | LINE Bot Info APIで `@514vdecm`（テストアカウント）が返ることを確認 |

### 6. E2Eテスト用データ投入

| 作業 | 詳細 |
|------|------|
| 本番にタグ作成 | 「新規」タグ |
| 本番にウェルカムシナリオ作成 | triggerType: `friend_add` |
| ステップ2つ追加 | Step 0: 即時あいさつ / Step 1: 1分後フォロー |
| E2Eテスト | 友だち追加 → Webhook受信 → 友だち自動登録 + 即時配信を確認 |

### 触っていないもの

- 管理画面（Next.js）のデプロイ
- LIFFアプリのデプロイ
- `.dev.vars` はgitignoreされているのでpushしていない

---

## 本番環境情報

| 項目 | 値 |
|------|-----|
| Worker URL | https://line-crm-worker.ryo-m-code.workers.dev |
| D1 Database ID | （.envまたはwrangler.toml参照） |
| API_KEY | （.env参照） |
| Cloudflare Account ID | （wrangler.toml参照） |
| LINE Bot ID | @514vdecm |
| Messaging API Channel ID | （LINE Developers Console参照） |
| LINE Login Channel ID | （LINE Developers Console参照） |
| GitHub | https://github.com/Ryo-M-49/line-harness |

---

## 運用代行時に毎回発生する作業 vs 初回のみの作業

### 初回のみ（済み）

以下はすべて完了済み。二度とやらない。

- pnpm / wrangler のインストール
- Cloudflare D1データベース作成 + スキーマ投入
- Worker本番デプロイ
- APIキー生成
- GitHub Actions連携（CLOUDFLARE_ACCOUNT_ID, CLOUDFLARE_API_TOKEN）
- 自分のテスト用LINEチャネル作成

### クライアント追加時に毎回発生する作業

新しいクライアントのLINE公式アカウントを運用するたびに必要な作業:

**1. クライアントのLINEチャネル情報を取得（5分）**
- クライアントがLINE Developers Consoleで Messaging API チャネルを作成
- Channel ID / Channel Secret / Channel Access Token を共有してもらう

**2. LINE HarnessにAPIで追加（1分）**
```bash
curl -X POST $WORKER_URL/api/line-accounts \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "channelId": "クライアントのChannel ID",
    "name": "○○美容室",
    "channelAccessToken": "クライアントのAccess Token",
    "channelSecret": "クライアントのChannel Secret"
  }'
```

**3. Webhook URL設定（1分）**
- クライアントのLINE Developers Console → Messaging API → Webhook URL に
  `https://line-crm-worker.ryo-m-code.workers.dev/webhook` を設定
- 署名検証で自動ルーティングされるため、全クライアント同じURL

**4. シナリオ・タグ等の構築（これが「構築代行」の本体）**
- タグ設計、ステップ配信シナリオ、自動化ルール、スコアリング等をAPIで設定
- ここがClaude Codeで自動化できる部分（= 従来30万〜250万円の作業）

### まとめ

| 作業 | 頻度 | 所要時間 |
|------|------|---------|
| インフラ構築 | 初回のみ（済み） | — |
| クライアントのアカウント追加 | クライアントごとに1回 | 5〜10分 |
| シナリオ・タグ等の構築 | クライアントごとに1回 | 1〜2時間（Claude Code使用） |
| 月次運用（配信・分析・改善） | 毎月 | 2〜3時間/アカウント（AI自動化前提） |
