# LINE Harness

LINE公式アカウントのCRM・マーケティングオートメーションを実現するOSSツール。
Cloudflare Workers + D1で動作し、全機能をAPI経由で操作可能。AI-First設計。

## 技術スタック

pnpmモノレポ（Node.js 20+）。

| パッケージ | 技術 | 概要 |
|-----------|------|------|
| apps/worker | Cloudflare Workers + Hono | REST API + Webhook |
| apps/web | Next.js 15 + React 19 + Tailwind CSS 4 | 管理画面 |
| apps/liff | Vite + vanilla TS | LINEミニアプリ |
| packages/db | D1スキーマ | 39テーブル |
| packages/line-sdk | LINE Messaging API | 型付きラッパー |
| packages/sdk | TypeScript | npm公開用SDK |
| packages/mcp-server | MCP Server | Claude Code連携（19ツール） |
| packages/shared | TypeScript | 共有型定義 |

## ディレクトリ構成

```
line-harness/
├── apps/
│   ├── worker/        # Cloudflare Workers API
│   ├── web/           # Next.js 管理画面
│   └── liff/          # LINEミニアプリ
├── packages/
│   ├── db/            # D1スキーマ（39テーブル）
│   ├── sdk/           # TypeScript SDK
│   ├── line-sdk/      # LINE Messaging APIラッパー
│   ├── mcp-server/    # MCPサーバー（19ツール）
│   └── shared/        # 共有型定義
├── docs/
│   ├── wiki/          # 25ページのwiki
│   ├── strategy/      # 営業戦略・ココナラ出品
│   └── clients/       # クライアント案件ドキュメント
└── scripts/
```

## 機能一覧

### 配信

- ステップ配信（delay_minutes制御、条件分岐）
- 一斉配信（全員/タグ/セグメント）
- リマインダー（日付ベースのカウントダウン）
- 予約配信
- テンプレート管理（text/flex/image）
- テンプレート変数（`{{name}}`, `{{uid}}`, `{{auth_url:CHANNEL_ID}}`）

### CRM

- 友だち管理（自動登録、プロフィール同期、カスタムメタデータ）
- タグ付け/セグメント
- リードスコアリング（イベント駆動）
- オペレーターチャット
- ブロック・退会検知

### マーケティング

- リッチメニュー（個別紐付け）
- トラッキングリンク（クリック計測、自動タグ付け）
- フォーム（LIFF）
- Google Calendar連携（予約管理）
- アフィリエイト追跡

### 自動化

- IF-THENルール（7種トリガー × 6種アクション）
- 自動応答（キーワードマッチ）
- Webhook IN/OUT（Stripe, Slack等）
- 通知ルール
- イベントバス

### 安全性

- BAN検知（アカウントヘルスモニタリング）
- アカウント移行（BAN時ワンクリック切替）
- ステルス配信（ジッター、バッチ間隔ランダム化）
- マルチアカウント（1 Workerで複数LINE公式アカウント管理）
- UUID統合

## セットアップ

### ローカル開発

```bash
pnpm install
cp .env.example .env  # 環境変数設定
pnpm dev:worker       # localhost:8787
pnpm dev:web          # localhost:3001
```

### Cloudflare Workersデプロイ

```bash
pnpm deploy:worker
```

### 環境変数

| 変数名 | 用途 |
|--------|------|
| LINE_CHANNEL_SECRET | Messaging APIチャネルシークレット |
| LINE_CHANNEL_ACCESS_TOKEN | Messaging APIアクセストークン |
| API_KEY | Worker API認証キー |
| LINE_CHANNEL_ID | Messaging APIチャネルID |
| LIFF_URL | LIFFアプリURL |
| LINE_LOGIN_CHANNEL_ID | LINE LoginチャネルID |
| LINE_LOGIN_CHANNEL_SECRET | LINE Loginチャネルシークレット |
| WORKER_URL | デプロイ先WorkerのURL |

## デプロイ状況

| 項目 | 値 |
|------|-----|
| Worker URL | https://line-crm-worker.ryo-m-code.workers.dev |
| D1 | line-crm (`734a6682-b446-4706-8348-556fded7a5b1`) |
| Cron | `*/5 * * * *` |
| CI/CD | GitHub Actions自動デプロイ（mainブランチ push時） |
| テストアカウント | @514vdecm |
| E2Eテスト | 完了（友だち追加→ステップ配信の一連フロー検証済み） |

## 実装進捗

| ラウンド | ステータス | 完了日 |
|---------|-----------|--------|
| Round 1 (MVP) | 完了 | 2026-03-21 |
| Round 2 (拡張) | 完了 | 2026-03-21 |
| Round 3 (フル機能) | 完了 | 2026-03-22 |
| Round 3.5 (追加機能) | 完了 | 2026-03-22 |
| Round 4 | 予定 | メール/SMS連携、Instagram DM連携、LTV予測等 |

## ドキュメント

- `docs/wiki/` — 25ページのwiki
- `docs/strategy/` — 営業戦略・ココナラ出品関連
- `docs/clients/` — クライアント案件ドキュメント

## 関連案件

- ひらリアス（初案件）: `docs/clients/hilarious-beauty/`

## ライセンス

MIT
