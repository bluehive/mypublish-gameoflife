# mypublish-gameoflife

**『Racketで学ぶ生命のゲーム』**（副題: 関数型プログラミング入門とコンウェイのライフゲーム）の執筆リポジトリ。

- **コード・執筆**: [Grok 4.5](https://x.ai) 協業
- **公開**: [Zenn](https://zenn.dev) 本 → 最終確認後に EPUB / Kindle
- **マスター Issue**: [my-grok-task-2026#27](https://github.com/bluehive/my-grok-task-2026/issues/27)
- **ライセンス**: [MIT](./LICENSE)

## 正本

| パス | 役割 |
|------|------|
| `books/racket-game-of-life/*.md` | **原稿の正本**（Zenn book 章） |
| `books/racket-game-of-life/config.yaml` | 本メタ・章順・`published` |
| `code/*.rkt` | 章付属コード + rackunit |
| `notes/racket-game-of-life/outline.md` | 目次・Phase1・#28–#30 リンク |

EPUB は正本から生成します（`mise run book:combine` → `book:epub`）。

## フォルダ構成

```
mypublish-gameoflife/
├── articles/                         # Zenn 単発記事（任意）
├── books/racket-game-of-life/        # Zenn 本 = 正本
├── drafts/racket-game-of-life/       # 作業用ドラフトコピー
├── manuscript/racket-game-of-life/   # EPUB 結合結果
├── notes/racket-game-of-life/        # 目次・移行メモ
├── code/                             # Racket ソース
├── scripts/racket-game-of-life/      # combine / build / verify
├── assets/epub/                      # EPUB CSS（japanism 流用）
├── output/                           # ビルド成果
└── mise.toml                         # ツール + タスク（wt:* 含む）
```

雛形: [mypublish-japanism](https://github.com/bluehive/mypublish-japanism)

## 開発フロー（Zenn → EPUB）

```
目次 → 各章ドラフト (md) → ユーザー承認
  → books/ 更新 & config chapters 追加 → git push
  → Zenn GitHub 連携で同期
  → フィードバックは PR をユーザー承認して改定
  → 最終確認後に EPUB 生成
```

初回: 本は `published: true` / **chapters は序章 (`intro`) のみ**（#27 Q3）。

### セットアップ

```bash
cd ~/my-project/mypublish-gameoflife
mise trust mise.toml   # 初回
mise install           # node 等
npm install            # zenn-cli
```

Zenn と GitHub の連携は [ダッシュボード](https://zenn.dev/dashboard) で **ユーザーが** 本リポジトリを登録してください。

### よく使うタスク

```bash
mise run zenn:preview    # localhost でプレビュー
mise run test:racket     # raco test code/
mise run book:combine    # books → manuscript/.../book.md
mise run book:epub       # 横書き EPUB + verify
mise run wt:setup        # 実験 worktree（ユーザー実行）
mise run wt:grok         # worktree で Grok
mise run wt:clean        # 固定 worktree 削除
```

## 7月末の成功定義（#27 / #33）

1. 序章＋第1章ドラフト
2. 第4章（GoL ルール + rackunit）
3. 第5章骨格（描画・パターン）

関連: [#28](https://github.com/bluehive/my-grok-task-2026/issues/28) [#29](https://github.com/bluehive/my-grok-task-2026/issues/29) [#30](https://github.com/bluehive/my-grok-task-2026/issues/30)

## 移行元

- 旧正本: `draft-publish-books-2026/racket-game-of-life.md`（移行後は削除予定）
- コード: `code/ch01-basics.rkt`（18 tests）

---

*Init: 2026-07-23 / Issue #27 承認実装 / Grok 4.5*
