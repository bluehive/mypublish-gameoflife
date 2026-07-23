# mypublish-gameoflife

**『Racketで学ぶ生命のゲーム』**（副題: 関数型プログラミング入門とコンウェイのライフゲーム）の執筆リポジトリ。

- **コード・執筆**: [Grok 4.5](https://x.ai) 協業
- **公開**: [Zenn](https://zenn.dev) 本 → 最終確認後に EPUB / Kindle
- **マスター Issue**: [my-grok-task-2026#27](https://github.com/bluehive/my-grok-task-2026/issues/27)
- **本リポジトリ Issue**: [#1 Advanced Student (htdp/asl)](https://github.com/bluehive/mypublish-gameoflife/issues/1)（p0）
- **作業計画・進捗（エージェント参照）**: [plan.md](./plan.md)
- **ライセンス**: [MIT](./LICENSE)

## この README の目次

- [本の目次](#本の目次)
- [付録（予定）](#付録予定)
- [言語方針: Advanced Student](#言語方針-advanced-student-lang-htdpasl)
- [正本](#正本)
- [フォルダ構成](#フォルダ構成)
- [開発フロー（Zenn → EPUB）](#開発フローzenn--epub)
- [セットアップ](#セットアップ)
- [よく使うタスク](#よく使うタスク)
- [ローカル CI（テスト / watch）](#ローカル-ciテスト--watch)
- [7月末の成功定義](#7月末の成功定義2733)
- [移行元](#移行元)

## 本の目次

**目次の正本は本 README のみ**（旧 `notes/.../outline.md` は廃止し統合）。  
章本文の正本は `books/racket-game-of-life/`。

| 章 | タイトル | 原稿 | コード | 状態 |
|----|----------|------|--------|------|
| 序章 | なぜRacketか——ゲームで学ぶ関数型 | [intro.md](books/racket-game-of-life/intro.md) | — | 初稿 |
| 第1章 | Racketの基礎——式と関数 | [ch01-basics.md](books/racket-game-of-life/ch01-basics.md) | [ch01-basics.rkt](code/ch01-basics.rkt) | 初稿 + ASL |
| 第2章 | 再帰——Racketの核心 | [ch02-recursion.md](books/racket-game-of-life/ch02-recursion.md) | [ch02-recursion.rkt](code/ch02-recursion.rkt) | ドラフト + ASL |
| 第3章 | データ構造——グリッドを表現する | [ch03-grid.md](books/racket-game-of-life/ch03-grid.md) | — | 目次のみ |
| 第4章 | ライフゲームのルールとセルオートマトン | [ch04-life-rules.md](books/racket-game-of-life/ch04-life-rules.md) | [ch04-life-rules.rkt](code/ch04-life-rules.rkt) | ドラフト + ASL |
| 第5章 | 描画と対話——盤面を見る | [ch05-display.md](books/racket-game-of-life/ch05-display.md) | [ch05-display.rkt](code/ch05-display.rkt) | 骨格 + ASL |
| 付録 | 環境・デバッグ・数表など | [下記](#付録予定) | — | 予定 |

Zenn 公開中の章は `books/racket-game-of-life/config.yaml` の `chapters` のみ（現状: `intro`）。

### 章の見取り図（短い）

0. **序章** — なぜ Racket / なぜライフゲーム / 進め方  
1. **第1章** — 式・`define`・条件・リスト・`posn`・近傍の入口  
2. **第2章** — 再帰・高階関数・`map`/`filter`  

3. **第3章** — グリッド表現（予定）  
4. **第4章** — B3/S23・`next-generation`・`check-expect`  
5. **第5章** — ASCII 表示・パターンカタログ（骨格）  
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
| [本repo#1](https://github.com/bluehive/mypublish-gameoflife/issues/1) | 全体・ASL | Advanced Student / 目次統合 |
| [#28](https://github.com/bluehive/my-grok-task-2026/issues/28) | 第1–2章・付録D | HtDP Beginner / デザインレシピ |
| [#29](https://github.com/bluehive/my-grok-task-2026/issues/29) | 第4–5章 | Game of Life 実装・テスト |
| [#30](https://github.com/bluehive/my-grok-task-2026/issues/30) | 第1章 1.6・付録G | 数学可視化メモ |

## 言語方針: Advanced Student (`#lang htdp/asl`)

本のサンプルコードの**第一言語**は、HtDP の **Advanced Student Language**（`#lang htdp/asl`）です。

| 狙い | 内容 |
|------|------|
| テストしやすさ | `check-expect` が言語に組み込み。例と実装を同じファイルに書ける |
| エラーメッセージ | 学生向け言語レベルのため、素人にも読みやすい診断が出やすい |
| 教育との接続 | デザインレシピ・BSL→ASL の段階と整合（関連: my-grok-task-2026#28） |
| CLI でも検証 | ファイル末尾で `(require test-engine/racket-tests)` と `(test)` により `racket code/….rkt` で全テスト実行 |

公式: [Advanced Student](https://docs.racket-lang.org/htdp-langs/advanced.html)

- 座標は `make-posn` / `posn-x` / `posn-y`（ペアより HtDP 定番）
- 真偽は `true` / `false`（`#true` / `#false` も可）
- 本格 `#lang racket` + `rackunit` は発展・対照用に残す余地あり（現状の章コードは ASL）

## 正本

| パス | 役割 |
|------|------|
| `README.md`（本ファイル） | **目次・付録メモ・運用**の正本 |
| `books/racket-game-of-life/*.md` | **章原稿の正本**（Zenn book 章） |
| `books/racket-game-of-life/config.yaml` | 本メタ・章順・`published` |
| `code/*.rkt` | 章付属コード（`#lang htdp/asl` + `check-expect`） |
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
mise run test:racket     # code/*.rkt を racket 実行（ASL check-expect）
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
| `mise run test:racket` | ASL ファイルを順に `racket` 実行（`check-expect`） |
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
2. 第4章（GoL ルール + テスト）— ASL `check-expect` 実験済
3. 第5章骨格（描画・パターン）— ASL 骨格実験済

関連: [本repo#1](https://github.com/bluehive/mypublish-gameoflife/issues/1) [#28](https://github.com/bluehive/my-grok-task-2026/issues/28) [#29](https://github.com/bluehive/my-grok-task-2026/issues/29) [#30](https://github.com/bluehive/my-grok-task-2026/issues/30)

## 移行元

- 旧正本: `draft-publish-books-2026/racket-game-of-life.md`（移行後は削除予定）
- コード: `code/ch01-basics.rkt` ほか（`#lang htdp/asl`）

---

*Init: 2026-07-23 / Issue #27 承認実装 / Issue #1 ASL 実験 / Grok 4.5*
