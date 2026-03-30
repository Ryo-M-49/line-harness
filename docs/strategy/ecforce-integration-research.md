# ECフォース（ecforce）連携調査

調査日: 2026-03-26
ステータス: completed
関連案件: ひらリアス 小谷さん

---

## 背景

ひらリアスはECフォースで定期購入カートを運用中。LINE公式アカウント（3,300人）との連携で、定期購入者と未購入者のリッチメニュー出し分けや、購入ステータスに応じた自動配信を実現したい。

---

## 調査結果

### Webhook機能

ecforceにはWebhook機能があり、以下のイベントを外部に通知できる。ただしオプション契約が必要。

| カテゴリ | イベント | 用途 |
|---------|---------|------|
| 定期受注 | `subs_order_active` | 定期開始/有効化 |
| 定期受注 | `subs_order_suspend` | 定期停止 |
| 定期受注 | `subs_order_canceled` | 定期キャンセル |
| 受注 | `order_created`, `order_updated`, `order_completed` | 単発注文の追跡 |
| 受注 | `order_shipped`, `order_delivered` | 配送ステータス |
| 受注 | `order_canceled` | 注文キャンセル |
| 顧客 | `customer_member` | 会員化 |
| 顧客 | `customer_cancel` | 退会 |

Webhookテンプレート管理でペイロードのカスタマイズも可能。HTTPリクエスト形式で任意のエンドポイントに送信。

### API連携機能

外部サービスAPI連携もオプション契約で利用可能。

- ショップ専用APIサーバが構築される
- Customer API（顧客詳細）、Order API（受注詳細）、SubsOrder API（定期受注詳細）
- API仕様書はオプション契約前でも開示依頼可能（ecforce契約者に限る）

### LINE連携の既存手段

ecforceには公式・サードパーティ含め複数のLINE連携手段がある。

**公式:**
- LINE ID連携機能（LINE LoginでLINEアカウントとecforce会員を紐付け）
- ecforce chat（チャットbot、シナリオエディタから外部API利用可能）

**サードパーティ（競合になりうる）:**

| ツール | 特徴 | 月額 |
|--------|------|------|
| リピートライン | 定期顧客向けLINE CRM。解約抑止bot、LINE内での定期変更受付 | 要問合せ |
| ECAI | ecforce APIと連携。定期商品コード・購入回数・継続ステータスでセグメント配信 | 要問合せ |
| LOYCUS | ノーコードでecforce顧客情報を活用したLINE CRM | 要問合せ |

---

## LINE Harnessとの連携構成案

```
ecforce Webhook → LINE Harness Worker（中間処理）→ タグ自動付与 → リッチメニュー切替/セグメント配信
```

### 実現可能なフロー

1. ecforce Webhookで定期購入イベントを検知
2. LINE Harness APIにリクエスト → 該当ユーザーに「定期購入者」タグを自動付与
3. タグに基づいてリッチメニューを自動切替
4. 解約Webhookで検知 → タグ変更 → メニュー自動切替
5. 定期購入者向けのセグメント配信が可能に

### 前提条件

- ecforce側でWebhookオプション契約が必要（小谷さんに確認依頼）
- LINE ID連携でecforce会員とLINEアカウントの紐付けが必要
- Webhook受信用の中間処理をLINE Harness Worker側に追加開発が必要

### リスク

- ecforceのオプション契約費用が不明（コスト増の可能性）
- LINE ID連携の実装にLINE Login設定が追加で必要
- 3,300人の既存友だちとecforce会員の紐付けをどうするか（新規友だちは自動、既存は手動 or 再連携フローが必要）

---

## 結論

技術的にはWebhook経由で定期購入ステータスの自動連携が可能。ただし初回構築に含めるにはリスクが高い（オプション契約の確認、中間サーバ開発、既存友だちの紐付け問題）。

フェーズ1（今回）は手動タグ管理で出し分けを実現し、フェーズ2でECフォース連携を別途提案する。

---

## Sources

- [Webhook通知のイベント一覧 - ecforce faq](https://support.ec-force.com/hc/ja/articles/4408392421785)
- [Webhook管理 - ecforce faq](https://support.ec-force.com/hc/ja/articles/900006268583)
- [外部サービスAPI連携 - ecforce faq](https://support.ec-force.com/hc/ja/articles/900004860246)
- [LINE ID連携 - ecforce faq](https://support.ec-force.com/hc/ja/articles/900004858506)
- [ecforce連携 - リピートライン](https://www.repeat-line.jp/reason/api_index/api_ecforce/)
- [ecforceと連携するとできる事 - ECAI](https://help.ecai.jp/ecforce%E3%81%A8%E9%80%A3%E6%90%BA%E3%81%99%E3%82%8B%E3%81%A8%E3%81%A7%E3%81%8D%E3%82%8B%E4%BA%8B/)
- [ecforce x LOYCUS](https://loycus.jp/function/ecforce-loycus/)
