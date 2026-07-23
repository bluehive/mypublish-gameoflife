# mypublish-gameoflife

**『Racketで学ぶ生命のゲーム』**（副題: 関数型プログラミング入門とコンウェイのライフゲーム）の執筆リポジトリ。

- **コード・執筆**: [Grok 4.5](https://x.ai) 協業
- **公開**: [Zenn](https://zenn.dev) 本 → 最終確認後に EPUB / Kindle
- **マスター Issue**: [my-grok-task-2026#27](https://github.com/bluehive/my-grok-task-2026/issues/27)
- **本リポジトリ Issue**: [#1](https://github.com/bluehive/mypublish-gameoflife/issues/1)（旧 ASL 実験）/ [#2](https://github.com/bluehive/mypublish-gameoflife/issues/2)（章ドラフト）
- **教材スタイル参照**: [howtocode.pages.dev](https://howtocode.pages.dev/)
- **作業計画・進捗（エージェント参照）**: [plan.md](./plan.md)
- **ライセンス**: [MIT](./LICENSE)

## この README の目次

- [本の目次](#本の目次)
- [付録（予定）](#付録予定)
- [言語方針: Beginning Student (BSL)](#言語方針-beginning-student-bsl)
- [正本](#正本)
- [フォルダ構成](#フォルダ構成)
- [開発フロー（Zenn → EPUB）](#開発フローzenn--epub)
- [セットアップ](#セットアップ)
- [よく使うタスク](#よく使うタスク)
- [ローカル CI（テスト / watch）](#ローカル-ciテスト--watch)
- [7月末の成功定義](#7月末の成功定義2733)
- [移行元](#移行元)
- [ユーザーフィードバック（記録）](#ユーザーフィードバック記録)

## 本の目次

**目次の正本は本 README のみ**（旧 `notes/.../outline.md` は廃止し統合）。
章本文の正本は `books/racket-game-of-life/`。

| 章 | タイトル | 原稿 | コード | 状態 |
|----|----------|------|--------|------|
| 序章 | なぜRacketか——ゲームで学ぶ関数型 | [intro.md](books/racket-game-of-life/intro.md) | — | howtocode 準拠ドラフト + BSL |
| 第1章 | Racketの基礎——式と関数 | [ch01-basics.md](books/racket-game-of-life/ch01-basics.md) | [ch01-basics.rkt](code/ch01-basics.rkt) | cheatsheet 準拠 + BSL |
| 第2章 | 再帰——Racketの核心 | [ch02-recursion.md](books/racket-game-of-life/ch02-recursion.md) | [ch02-recursion.rkt](code/ch02-recursion.rkt) | テンプレート駆動 + BSL |
| 第3章 | データ構造——グリッドを表現する | [ch03-grid.md](books/racket-game-of-life/ch03-grid.md) | — | 骨子 |
| 第4章 | ライフゲームのルールとセルオートマトン | [ch04-life-rules.md](books/racket-game-of-life/ch04-life-rules.md) | [ch04-life-rules.rkt](code/ch04-life-rules.rkt) | ドラフト + BSL |
| 第5章 | 描画と対話——盤面を見る | [ch05-display.md](books/racket-game-of-life/ch05-display.md) | [ch05-display.rkt](code/ch05-display.rkt) | 骨格 + BSL |
| 付録 | 環境・デバッグ・数表など | [下記](#付録予定) | — | 予定 |

Zenn 公開中の章は `books/racket-game-of-life/config.yaml` の `chapters` のみ（現状: `intro`）。

### 章の見取り図（短い）

0. **序章** — なぜ BSL / 式と評価 / 環境 / ライフゲームへ
1. **第1章** — cheatsheet（式・define・cond・関数・struct・リスト）
2. **第2章** — 再帰・HtDP テンプレート（構造的再帰）
3. **第3章** — グリッド表現（骨子）
4. **第4章** — B3/S23・`next-generation`・`check-expect`
5. **第5章** — ASCII 行リスト・パターンカタログ（骨格）
付録 **A–G** — ソース一覧・問題対応・CLI・環境・文献・デバッグ・三角関数表

## 付録（予定）

本編外の参照・手順・チートシート。本文ファイルは未分割（必要になったら `books/` または `notes/` に切り出す）。

| 記号 | 内容 | メモ |
|------|------|------|
| **A** | 完全ソースコード一覧 | GitHub [bluehive/my-racket](https://github.com/bluehive/my-racket) へのリンク中心 |
| **B** | `kyapon-knk-racket.org` 問題50問との対応表 | 本編問題との対応 |
| **C** | Racket コマンドライン入門 | `racket`, `raco` |
| **D** | 環境構築（Windows 11 のみ） | DrRacket 中心のインストール手順（#28 連携） |
| **E** | 参考文献・オンラインリソース | O'Reilly『Racket』、[quick](https://docs.racket-lang.org/quick/)、trace、テスト API |
| **F** | デバッグ方法 | 下記 F.1–F.5 |
| **G** | 三角関数チートシート | sin, cos, tan、加法定理（LaTeX）。高校レベル・可視化（#30）向け |

### 付録 F — デバッグ方法（詳細メモ）

- **F.1 プリントデバッグ** — 関数型寄りのスタイルでも、Racket は純粋関数型ではないので `printf` を差し込みやすい。例: `(begin (printf "x is currently ~v\n" x) x)`。参考: [debugging-in-racket](https://www.brinckerhoff.org/clements/2252-csc430/Files/debugging-in-racket.html)
- **F.2 Racket lang 拡張デバッグ** — `#lang debug` の `#R`（値報告+返却）、`#RR`（行番号）、`#RRR`（ファイル+行）。`#lang debug/no-output` も可。[AlexKnauth/debug](https://github.com/AlexKnauth/debug)
- **F.3 REPL でのデバッグ** — スタックトレースだけでなく REPL の対話探索。CL 流の考え方を Racket に適用: [CL debugging cookbook](https://lispcookbook.github.io/cl-cookbook/debugging.html)
- **F.4 trace** — 関数呼び出しの引数・戻り値の記録。ステップやブレークポイントの考え方を含む
- **F.5 その他** — `debug-repl`、インスペクト、ログ、ユニットテストとの組み合わせ、リモートデバッグのヒント

### 関連 Issue（章・付録の取り込み先）

| Issue | 取り込み先 | 内容 |
|-------|------------|------|
| [本repo#1](https://github.com/bluehive/mypublish-gameoflife/issues/1) | 履歴 | 当初 ASL 実験 → **BSL に転換**（ユーザー 0723） |
| [#28](https://github.com/bluehive/my-grok-task-2026/issues/28) | 第1–2章・付録D | HtDP Beginner / デザインレシピ |
| [#29](https://github.com/bluehive/my-grok-task-2026/issues/29) | 第4–5章 | Game of Life 実装・テスト |
| [#30](https://github.com/bluehive/my-grok-task-2026/issues/30) | 付録G 等 | 数学可視化メモ |

## 言語方針: Beginning Student (BSL)

本のサンプルコードの**第一言語**は、HtDP の **Beginning Student**（`#lang htdp/bsl`）です。

| 狙い | 内容 |
|------|------|
| 初学者向け | 構文を絞り、エラーが追いやすい（howtocode / DrRacket Beginning Student） |
| テスト | `check-expect` を仕様として書く。CLI は `test-engine` + `(test)` |
| テンプレート | 第2章以降は [htdp_templates](https://howtocode.pages.dev/htdp_templates) の Data/Function チェックリスト |
| 段階昇格 | 途中から Intermediate / Advanced へ上げる可能性あり（ユーザー判断） |

公式: [Beginning Student](https://docs.racket-lang.org/htdp-langs/beginner.html)  
教材スタイル: [howtocode.pages.dev](https://howtocode.pages.dev/)

- 座標: `make-posn` / `posn-x` / `posn-y`
- リスト処理: **構造的再帰**（BSL に `map`/`filter`/`lambda` は無い）
- 0 引数関数不可 → 定数 `define` を使う
- 旧 Issue #1 の ASL 第一方針は、本節で**置き換え**

## 正本

| パス | 役割 |
|------|------|
| `README.md`（本ファイル） | **目次・付録メモ・運用**の正本 |
| `books/racket-game-of-life/*.md` | **章原稿の正本**（Zenn book 章） |
| `books/racket-game-of-life/config.yaml` | 本メタ・章順・`published` |
| `code/*.rkt` | 章付属コード（`#lang htdp/bsl` + `check-expect`） |
| `notes/racket-game-of-life/` | 移行メモ等（目次は置かない） |

EPUB は章正本から生成します（`mise run book:combine` → `book:epub`）。

## フォルダ構成

```
mypublish-gameoflife/
├── articles/                         # Zenn 単発記事（任意）
├── books/racket-game-of-life/        # Zenn 本 = 章正本
├── drafts/racket-game-of-life/       # 作業用ドラフトコピー
├── manuscript/racket-game-of-life/   # EPUB 結合結果
├── notes/racket-game-of-life/        # 移行メモ等（outline は廃止）
├── code/                             # Racket ソース（ASL）
├── scripts/racket-game-of-life/      # combine / build / verify
├── assets/epub/                      # EPUB CSS（japanism 流用）
├── output/                           # ビルド成果
└── mise.toml                         # ツール + タスク（wt:* / ci:* 含む）
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
mise run test:racket     # code/*.rkt を racket 実行（BSL check-expect）
mise run ci:test         # ローカル CI 一発（test:racket と同じゲート）
mise run watch:test      # code/ 変更でテストを自動再実行
mise run book:combine    # books → manuscript/.../book.md
mise run book:epub       # 横書き EPUB + verify
mise run wt:setup        # 実験 worktree（ユーザー実行）
mise run wt:grok         # worktree で Grok
mise run wt:clean        # 固定 worktree 削除
```

単体:

```bash
racket code/ch01-basics.rkt
racket code/ch04-life-rules.rkt
racket code/ch05-display.rkt
```

## ローカル CI（テスト / watch）

| タスク | 用途 |
|--------|------|
| `mise run test:racket` | BSL ファイルを順に `racket` 実行（`check-expect`） |
| `mise run ci:test` | PR/マージ前の一発ゲート（`test:racket` に依存） |
| `mise run watch:test` | `code/**/*.rkt` を監視し、保存のたびに `test:racket` を再実行 |

```bash
# 一発
mise run ci:test

# 自動（別ターミナルで常駐）
mise run watch:test
# 同等: mise watch test:racket --clear
```

前提: `watchexec`（`mise watch` が利用。未導入なら `mise install` または `mise use -g watchexec@latest`）。

## 7月末の成功定義（#27 / #33）

1. 序章＋第1章ドラフト
2. 第4章（GoL ルール + テスト）— BSL `check-expect`
3. 第5章骨格（描画・パターン）— BSL 骨格

関連: [本repo#1](https://github.com/bluehive/mypublish-gameoflife/issues/1) [#28](https://github.com/bluehive/my-grok-task-2026/issues/28) [#29](https://github.com/bluehive/my-grok-task-2026/issues/29) [#30](https://github.com/bluehive/my-grok-task-2026/issues/30)

## 移行元

- 旧正本: `draft-publish-books-2026/racket-game-of-life.md`（移行後は削除予定）
- コード: `code/*.rkt`（`#lang htdp/bsl`）

---

*Init: 2026-07-23 / Issue #27 / #1→BSL 転換 / howtocode 準拠 / Grok 4.5*

## ユーザーフィードバック（記録）

### assert : user write 0723（取り込み済）

原文要旨:

- 序章・第1章を [howtocode](https://howtocode.pages.dev/) 準拠で書き直す  
- 言語は **BSL**（途中で Advanced へ上げる可能性あり）  
- 序章 ← introduction / installation / expressions  
- 第1章 ← cheatsheet  
- 第2章以降 ← htdp_templates  
- プランは `plan.md` §7、承認後に実行・commit・push・SE チェック  

**対応**: plan §7 承認後、本 README / `books/` / `code/` を BSL + howtocode 方針で更新（本コミット）。
