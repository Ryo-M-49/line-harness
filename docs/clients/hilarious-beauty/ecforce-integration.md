# ECフォース連携調査

調査日: 2026-03-26
ステータス: 調査完了、クライアント側のオプション契約確認待ち

---

## 結論

技術的にはWebhook経由で定期購入ステータスの自動連携が可能。ただしオプション契約が必要。

## Webhook機能

ecforceにはWebhook機能があり、以下のイベントを外部に通知できる。

| カテゴリ | イベント | 用途 |
|---------|---------|------|
| 定期受注 | `subs_order_active` | 定期開始/有効化 |
| 定期受注 | `subs_order_suspend` | 定期停止 |
| 定期受注 | `subs_order_canceled` | 定期キャンセル |
| 受注 | `order_created` / `order_completed` | 単発注文の追跡 |
| 顧客 | `customer_member` / `customer_cancel` | 会員化/退会 |

ペイロードのカスタマイズ可能。HTTP形式で任意のエンドポイントに送信。

## API連携機能

- Customer API（顧客詳細）、Order API（受注詳細）、SubsOrder API（定期受注詳細）
- API仕様書はオプション契約前でも開示依頼可能（ecforce契約者に限る）

## LINE連携の既存手段（競合）

| ツール | 特徴 |
|--------|------|
| リピートライン | 定期顧客向けLINE CRM。解約抑止bot、LINE内での定期変更受付 |
| ECAI | ecforce APIと連携。定期ステータスでセグメント配信 |
| LOYCUS | ノーコードでecforce顧客情報を活用したLINE CRM |

## LINE Harnessとの連携構成案

```
ecforce Webhook → LINE Harness Worker → タグ自動付与 → リッチメニュー切替
```

### 既存友だちの紐付け

- 初回は定期購入者リストをもらって手動タグ付け
- 以降はWebhookで自動化
- LINE ID連携（LINE LoginでLINEアカウントとecforce会員を紐付け）も併用するとより正確

### 前提条件

- ecforce側のWebhookオプション契約が必要（費用不明）
- Webhook受信用の中間処理をLINE Harness Worker側に追加開発が必要

## Sources

- [Webhook通知のイベント一覧 - ecforce faq](https://support.ec-force.com/hc/ja/articles/4408392421785)
- [外部サービスAPI連携 - ecforce faq](https://support.ec-force.com/hc/ja/articles/900004860246)
- [LINE ID連携 - ecforce faq](https://support.ec-force.com/hc/ja/articles/900004858506)
- [ecforce連携 - リピートライン](https://www.repeat-line.jp/reason/api_index/api_ecforce/)
- [ecforceと連携するとできる事 - ECAI](https://help.ecai.jp/ecforce%E3%81%A8%E9%80%A3%E6%90%BA%E3%81%99%E3%82%8B%E3%81%A8%E3%81%A7%E3%81%8D%E3%82%8B%E4%BA%8B/)
