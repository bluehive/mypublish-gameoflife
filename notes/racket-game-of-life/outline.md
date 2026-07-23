# 目次・ロードマップ — Racketで学ぶ生命のゲーム

> **正本リポジトリ**: [bluehive/mypublish-gameoflife](https://github.com/bluehive/mypublish-gameoflife)  
> **Zenn book slug**: `racket-game-of-life`  
> **原稿正本**: `books/racket-game-of-life/*.md`  
> **サンプル言語**: **Advanced Student** — `#lang htdp/asl`（[本repo#1](https://github.com/bluehive/mypublish-gameoflife/issues/1) p0）  
> **協業**: Grok 4.5 / Issue 駆動（my-grok-task-2026#27）  
> **移行元**: `draft-publish-books-2026/racket-game-of-life.md`

## 言語・テスト方針（#1）

| 項目 | 方針 |
|------|------|
| `#lang` | `htdp/asl`（Advanced Student） |
| テスト | `check-expect`（CLI は `test-engine/racket-tests` + `(test)`） |
| 座標 | `make-posn` |
| なぜ ASL か | テストが書きやすい・エラーが読みやすい・HtDP デザインレシピと接続 |
| 実行 | `racket code/ch0N-….rkt` または `mise run test:racket` |

## Phase 1 最短パス（#27 トリアージ）

1. **正本寄せ**: 執筆正本は本リポジトリの `books/racket-game-of-life/`（旧 draft から移行）
2. **章ドラフト Issue をロードマップ配下にリンク**
   - [本repo#1 ASL 実験](https://github.com/bluehive/mypublish-gameoflife/issues/1)（p0: 目次・ドラフト・コード・README）
   - [#28 HtDP Beginner 章](https://github.com/bluehive/my-grok-task-2026/issues/28)
   - [#29 Game of Life 章](https://github.com/bluehive/my-grok-task-2026/issues/29)
   - [#30 数学可視化章](https://github.com/bluehive/my-grok-task-2026/issues/30)
3. **7/31 までの章順を 3 本に絞る**（成功定義）
   - [x] 序章＋第1章ドラフト（ASL 化実験）
   - [x] 第4章（GoL ルール + `check-expect`）— 実験 worktree
   - [x] 第5章骨格（描画・パターン）— 同上
## 公開フロー（Zenn → EPUB）

```
目次更新 → 章ドラフト (md) → ユーザー承認
  → books/ 反映 & chapters 追加 → push → Zenn 同期
  → フィードバックは PR 承認で改定
  → 最終確認後 EPUB（mise run book:epub）
```

- 初回: 本 `published: true` / `chapters: [intro]` のみ（序章公開相当）
- 有料: なし（price: 0）/ ライセンス MIT / public repo

## 目次ドラフト（正本より）

### 序章　なぜRacketか——ゲームで学ぶ関数型

- 0.1 Racket とは（Scheme系・DrRacket） — 教育向きREPLとシンプルな文法で関数型思考を身につける。
- 0.2 ライフゲームを題材にする理由（状態・再帰・可視化） — 視覚的に楽しい題材で再帰・リスト処理・状態遷移を学べる。

### 第1章　Racketの基礎——式と関数

- 1.1 DrRacket の起動と REPL
- 1.2 四則演算と `define`（問題1–10）
- 1.3 `print` と文字列（問題11–15）
- 1.4 真偽値と条件分岐 `if`（問題16–20）
- 1.5 リストの基礎 `list`, `first`, `rest`（問題21–25） — モダンなリスト操作（car/cdrは古臭いため省略）
- 1.6 三角関数 — 計算方法とライフゲームとの関連（角度、距離、振動表現）。定義と公理をLaTeXで。山中俊治さんの解説エッセイ（円運動を真横から見ると単振動、音楽での重要性）をほぼそのまま追加して興味を深める。
- 1.7 ベクトル — 高校一年生レベル。位置・速度表現、加法、スカラー倍。ライフゲームのセル位置や移動に活用。
- 1.8 行列 — 高校一年生レベル。グリッド表現、変換、基本演算。データ構造やCA成長の数学的基礎。

### 第2章　再帰——Racketの核心

- 2.1 単純再帰の形（階乗・フィボナッチ）
- 2.2 `cond` とパターンマッチ的思考
- 2.3 末尾再帰と `let` / `let*` / `letrec`
- 2.4 高階関数 `map`, `filter`, `foldl`
- 2.5 ローカル変数と名前付き `let`

### 第3章　データ構造——グリッドを表現する

- 3.1 二次元リストとしての盤面
- 3.2 ベクター（`make-vector`）による高速化
- 3.3 構造体 `struct` でセルを定義
- 3.4 不変データと新世代の生成
- 3.5 モジュール分割の基本
- 3.6 Lists, Iteration, and Recursion — Racketガイドから: 事前定義リストループ（map, andmap, ormap, filter, foldl, for/list）。スクラッチからのリスト反復（first, rest, cons, empty, empty?, cons?）。末尾再帰（accumulatorパターンで効率化）。再帰 vs 反復の比較。ライフゲーム前の章として配置し、リスト処理の基礎を固める。https://docs.racket-lang.org/guide/Lists__Iteration__and_Recursion.html を解析・反映。

### 第4章　ライフゲームのルールとセルオートマトン

- 4.1 コンウェイのルール説明（B3/S23）
- 4.2 隣接セル数を数える関数 `count-neighbors`
- 4.3 次世代を計算する `next-generation`
- 4.4 境界の扱い（トーラス面 vs 固定境界）
- 4.5 ユニットテストの書き方（`rackunit`） — コードテストの歴史、テストの必要性、一般的なテスト思考（境界値・不変条件・回帰）、ライフゲーム特有のテスト項目（静止物・振動子・グライダー・無限成長・大規模グリッド性能・ランダム初期の安定性）。
- 4.6 セルオートマトンを作る
  - 4.6.1 Cellクラスを作る
  - 4.6.2 セルのサイズを変更する
  - 4.6.3 CAを成長させる
    - セルを行列内に置く
    - セルのリストを作る
    - CAを自動的に成長させる

### 第5章　描画と対話——盤面を見る

- 5.1 2htdp/image または ascii 表示
- 5.2 世代を進める REPL コマンド
- 5.3 有名パターン（グライダー・パルサー・ビーコン）
- 5.4 ファイルから初期配置を読み込む
- 5.5 GIF / 画像列のエクスポート（発展）

### 付録

- A. 完全ソースコード一覧（GitHub `https://github.com/bluehive/my-racket` リンク）
- B. `kyapon-knk-racket.org` 問題50問との対応表
- C. Racket コマンドライン入門（`racket`, `raco`）
- D. 環境構築（Windows 11 のみ） — DrRacket 中心のインストール手順
- E. 参考文献・オンラインリソース（O'Reilly『Racket』、https://docs.racket-lang.org/quick/ 、trace、rackunit API）
- F. デバッグ方法
  - F.1 プリントデバッグ（printf debugging） — 機能的スタイルでの変数値確認に便利。Racketは純粋関数型ではないので簡単に使用可能。`begin` やインラインで `printf` を挿入（例: `(begin (printf "x is currently ~v\n" x) x)` や式全体をラップ）。https://www.brinckerhoff.org/clements/2252-csc430/Files/debugging-in-racket.html を重点的に参照。
  - F.2 Racket lang 拡張デバッグ — `#lang debug` を使って `#R`（値報告+返却）、`#RR`（行番号付き）、`#RRR`（ファイル+行番号付き）で式をデバッグ。`#lang debug/no-output` も利用可。https://github.com/AlexKnauth/debug
  - F.3 REPL でのデバッグ — インタラクティブなデバッガの活用。スタックトレースだけでなく、REPLの強力な対話性を活かした探索方法。https://lispcookbook.github.io/cl-cookbook/debugging.html を参照し、Common Lisp の方法を Racket に適用した考え方を説明（ボリュームを確保）。
  - F.4 trace の使用方法 — Common Lisp の `trace` / `untrace` を参考に、Racket での関数呼び出しトレース、引数・戻り値の記録方法を解説。オプション（:break など）やステップ実行、ブレイクポイントの考え方も含む。
  - F.5 その他のデバッグツール — `debug-repl` マクロ、インスペクト、ログ、ユニットテストとの組み合わせ、リモートデバッグのヒント。参考URLを明記。
- G. 三角関数チートシート — sin, cos, tan, 加法定理（LaTeX形式）。高校レベルでライフゲームの視覚化やパターン計算に活用。サイン・コサイン・タンジェントと加法定理まで。

---

## 環境構築メモ（#28 / #29 / #30 反映）

| Issue | 取り込み先 | 内容 |
|-------|------------|------|
| #28 HtDP Beginner | 第1–2章・デザインレシピ、付録D 連携 | BSL / 署名 / 設計レシピ。詳細は `htdp-ja-translation` |
| #29 Game of Life | 第4–5章 | `lifeofgame-racket` / `my-racket/lifeofgame-racket.rkt` ベース、rackunit（block/blinker/glider） |
| #30 数学可視化 | 第1章 1.6・付録G | 三角関数・フーリエは本線外メモ可。`sankaku-racket` / GeometryofSquareWaves |

### ツール（mise）

- `mise run zenn:preview` — ローカル Zenn プレビュー
- `mise run test:racket` — `racket code/*.rkt`（ASL `check-expect`）
- `mise run book:combine` — books → manuscript/book.md
- `mise run book:epub` — 横書き EPUB + verify
- `mise run wt:setup` / `wt:grok` / `wt:clean` — git worktree 実験（**ユーザーが実行**）

参考: `~/my-project/htdp-ja-translation/mise.toml`

## 執筆ステータス

| 章 | 状態 | ファイル |
|----|------|----------|
| 序章 | 本文初稿 | books/.../intro.md |
| 第1章 | 本文初稿 + ASL code | books/.../ch01-basics.md, code/ch01-basics.rkt |
| 第2章 | 目次のみ | ch02-recursion.md |
| 第3章 | 目次のみ | ch03-grid.md |
| 第4章 | 本文ドラフト + ASL code（実験） | ch04-life-rules.md, code/ch04-life-rules.rkt |
| 第5章 | 骨格 + ASL code（実験） | ch05-display.md, code/ch05-display.rkt |

## 関連リポジトリ

- https://github.com/bluehive/my-grok-task-2026 (Issue #27 マスター)
- https://github.com/bluehive/draft-publish-books-2026 (旧企画・移行元)
- https://github.com/bluehive/mypublish-japanism (執筆フロー雛形)
- https://github.com/bluehive/my-racket (コード参照)
