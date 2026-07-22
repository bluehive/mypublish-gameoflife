# Migrated full source

Migrated from `draft-publish-books-2026/racket-game-of-life.md` (commit lineage c0792ca / remote main).

---

# Racketで学ぶ生命のゲーム

> **副題案**: 関数型プログラミング入門とコンウェイのライフゲーム  
> **目標**: 2026年9月11日 Kindle出版  
> **参照**: `my-racket/kyapon-knk-racket.org`（基礎問題50問）、Racket公式ドキュメント（quick/trace/rackunit）、https://www.brinckerhoff.org/clements/2252-csc430/Files/debugging-in-racket.html 、https://lispcookbook.github.io/cl-cookbook/debugging.html 、https://github.com/AlexKnauth/debug 、https://docs.racket-lang.org/guide/Lists__Iteration__and_Recursion.html  
> **想定読者**: プログラミング初級～中級、Lisp/Scheme 系に興味がある人  
> **更新注記 (Issue #8)**: 序章から環境構築・GitHub取得節を削除（付録DへWindows11のみ移動）。第4章にユニットテスト充実＋セルオートマトン節を追加。第6〜8章削除によりスコープ絞り。  
> **更新注記 (Issue #9)**: 付録にデバッグ方法セクションを追加（プリントデバッグ重視、Racket #lang debug、REPL、CL trace参考）。付録案とステータス表更新。  
> **更新注記 (Issues #10-12)**: 第1章にリスト/イテレーション/再帰（tail recursion, Racket guideリンク）、三角関数計算（LaTeX定義、ゲーム関連、音楽/振動のエッセイ）、ベクトル/行列説明（高校1年生レベル）を追加。car/cdr省略。付録に三角関数チートシート追加。目次・ステータス更新。
> **その他　設計デザイン、ドメイン指向を、中心に据える。また、schemeは数式の表記に長ける　
---

## 目次ドラフト

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

## コード構成（予定）

```
racket-game-of-life/
├── ch01-basics.rkt
├── ch02-recursion.rkt
├── ch03-grid.rkt
├── ch04-life-rules-and-ca.rkt
├── ch05-display.rkt
├── tests/
│   └── life-test.rkt
└── patterns/
    ├── glider.txt
    └── pulsar.txt
```

---

## 執筆ステータス

| 章 | 状態 | ローカル素材 | メモ（1行要約） |
|----|------|-------------|-----------------|
| 序章 | **本文初稿 (2026-07-11)** | — | なぜRacketとライフゲームで学ぶかの動機付け |
| 第1章 | **本文初稿 (2026-07-11)** | `code/ch01-basics.rkt` | 基礎 + リスト + 生存判定 + 近傍 |
| 第2章 | 目次のみ | `my-racket` | 再帰の核心を問題駆動で |
| 第3章 | 目次のみ | 要コード実装 | グリッドと不変データ + リスト反復・末尾再帰 |
| 第4章 | 目次のみ → **7月必須** | `lifeofgame-racket.rkt` + rackunit | ルール実装＋テスト＋CA |
| 第5章 | 目次のみ → **7月必須（骨格）** | GUI版コード | 可視化と有名パターン |
| 付録A | 未着手 | my-racket GitHub | 完全ソースとパターン |
| 付録D | 目次のみ | Windows 11手順 | DrRacket中心 |
| 付録F (デバッグ方法) | 目次のみ | 参照URL群 | printf / #lang debug / REPL / trace |
| 付録G (三角関数チートシート) | 目次のみ | #30 と連携 | sin/cos/tan + 加法定理 |

**注**: 第6〜8章はスコープを絞るため削除。環境構築は付録D（Windows 11のみ）に移動。my-racketリポジトリのコードリンクを付録Aに明記。付録FはIssue #9で追加。#10-12でCh1/Ch3にリスト反復・三角関数・ベクトル/行列追加（car/cdr省略）、付録G追加。

**7月末の成功定義（#27/#33 既定値・2026-07-11 固定）**:
1. 序章＋第1章ドラフト
2. 第4章（GoLルール＋テスト）ドラフト
3. 第5章骨格（描画・パターン）ドラフト  
正本リポジトリ: `draft-publish-books-2026`（Issueにはパス参照）。マクロ/SICPは Phase2 以降。

---

## 本文ドラフト

### 序章　なぜRacketか——ゲームで学ぶ関数型

#### 0.1 この本でやること

この本は、**Racket** という教育向きのプログラミング言語で、**コンウェイのライフゲーム**（Conway's Game of Life）を一から作りながら、関数型プログラミングの考え方を身につける入門書です。

ゴールは次の三つです。

1. **式と関数**で考える習慣（代入で上書きするより、値を計算して返す）
2. **リストと再帰**で「まとまり」を扱う力
3. **デザインレシピ**（問題の言い換え → 例 → 実装 → テスト）で、小さな関数を積み上げる作法

ライフゲームはルールが短いのに、動かすとパターンが生まれ、止まったり、歩いたり、無限に増えたりします。画面が動くので「合っている／合っていない」が体感しやすく、学習のフィードバックが速いのが利点です。

#### 0.2 Racket とは

Racket は Scheme 系の Lisp 方言で、**DrRacket** という統合環境が最初から付いています。特徴は次のとおりです。

- **括弧と式**が中心。`(関数 引数 …)` という一形でほとんど書ける
- **教育用言語レベル**（Beginning Student など）から本格 `#lang racket` まで段階を踏める
- **画像・アニメーション**（`2htdp/image` / `2htdp/universe`）や GUI（`racket/gui`）が揃っている
- **テスト**（`rackunit`）やドキュメント生成が言語の一部として自然

「まず動く小さな式を REPL で試す → 関数にまとめる → テストする」という循環が、DrRacket だととてもやりやすいです。

本編では主に `#lang racket` を使います。HtDP（How to Design Programs）の **Beginning Student Language** の考え方は、第1〜2章相当でデザインレシピとして取り込みます（詳細は関連 Issue #28 と `htdp-ja-translation` を参照）。

#### 0.3 なぜライフゲームか

コンウェイのライフゲームは、二次元グリッド上のセルが次のルールで世代更新されるセルオートマトンです（B3/S23）。

- 死んでいるセルは、周囲の生存が **ちょうど3** なら誕生する
- 生きているセルは、周囲の生存が **2または3** なら生き残る
- それ以外は死ぬ（過疎・過密）

プログラミング学習の題材として優れている点:

| 観点 | 学べること |
|------|------------|
| 状態 | 「今の盤面」から「次の盤面」を**新しいデータ**として作る（破壊的更新に頼らない） |
| 再帰・反復 | 近傍8マス、候補セル集合、世代ループ |
| データ表現 | 座標の組、生存セルのリスト、（発展）二次元グリッドや `struct` |
| テスト | 静止物・振動子・グライダーなど、期待結果がはっきりしている |
| 可視化 | ASCII / 画像 / GUI で「見た目」が即フィードバック |

本リポジトリ周辺では、すでに純粋関数型のコア（生存セルを `(x . y)` のリストで表す）と `racket/gui` の表示を持つ実装があります（`my-racket/lifeofgame-racket.rkt`）。第4〜5章では、その設計を**読み解けるように書き直し**、テストとパターンを足していきます。

#### 0.4 この本の進め方（7月〜9月の位置づけ）

- **7月末までの成功定義（暫定固定）**: 次の **3本の章ドラフト** を埋める  
  1. 序章＋第1章（基礎・式・リストの入口）  
  2. 第4章（ライフゲームのルールと `rackunit`）  
  3. 第5章の骨格（描画・有名パターン）  
  ※ 数学可視化（三角関数・フーリエ）は #30 として並行メモ可。本線は GoL。
- **正本**: 常に本ファイル  
  `draft-publish-books-2026/racket-game-of-life.md`
- **コード正本の参照**: `my-racket/` および GitHub `bluehive/my-racket`（付録A）
- **Kindle 目標日**: 2026-09-11（全体統合・校正は Phase 3）

読み方の提案:

1. 序章で「何を作るか」をつかむ  
2. 第1〜2章で式・条件・リスト・再帰の筋肉をつける（問題駆動）  
3. 第3章で盤面データ、第4章でルールとテスト  
4. 第5章で動かして眺める  

環境構築の細部（Windows 11 + DrRacket）は **付録D** にまとめます。本編はできるだけ「書いた式がすぐ動く」話に集中します。

#### 0.5 関数型・デザインレシピ・ドメイン

本全体の軸は次の三つです。

1. **関数型・不変寄り**  
   盤面を「その場で書き換える」より、`next-generation` が新しい生存リストを返す形を基本にする（`.cursorrules` の方針とも一致）。
2. **デザインレシピ**  
   データ定義 → シグネチャと目的文 → 例 → 実装 → テスト、の短いループを各関数に付ける。
3. **ドメイン（ライフゲーム）を中心に**  
   抽象論だけ先に長くしない。必要な言語機能は「近傍を数える」「次世代を返す」「グライダーを置く」ために導入する。

Scheme/Racket は括弧の中に式がそのまま載るので、**数式やルールの転写**が素直です。たとえば近傍数 `n` に対する生存判定は、文章のルールとコードの距離が近く保てます。

#### 0.6 本章のまとめ

- Racket は教育と実験の両方に向いた Scheme 系言語で、DrRacket が強い  
- ライフゲームは状態・再帰・テスト・可視化を一度に練習できる  
- 7月は **序章＋基礎、ルール実装＋テスト、描画骨格** の3本を優先  
- 正本はこの Markdown。コードは `my-racket` と連携  

次章（第1章）では、DrRacket の REPL から始め、四則・`define`・条件・リストの基礎を、短い問題と一緒に進めます。

---

### 第1章　Racketの基礎——式と関数

> **この章のゴール**  
> DrRacket で式を試し、`define` / `if` / リストで「小さな関数」を書けるようになる。  
> ライフゲームの部品（生存判定・座標・近傍）を、すでに言葉にできる状態にする。  
> **付属コード**: `code/ch01-basics.rkt`（`rackunit` の自己チェック付き）

#### 1.1 DrRacket の起動と REPL

1. DrRacket を起動する（Windows 11 の手順は付録D）。
2. 定義ウィンドウの先頭に必ず書く:

```racket
#lang racket
```

3. **Run**（実行）すると、下の**相互作用ウィンドウ**が REPL になる。
4. そこに式を書いて Enter。結果がすぐ返る。

```racket
(+ 1 2 3)          ; => 6
(* 2 (+ 3 4))      ; => 14
```

ポイント:

- **前置記法**: 演算子も関数も、括弧の先頭に来る  
  `(関数 引数1 引数2 …)`
- 式は値を返す。副作用（画面表示など）は後から足す
- 迷ったら小さく試す。本のコードも、まず REPL に貼って確認してよい

**デザインレシピ（最短版）** — この章から毎回使う:

| 手順 | やること |
|------|----------|
| 1. データ | 何を表す？（数、真偽、座標の組、リスト…） |
| 2. 署名 | 関数名・引数・返り値を一文で |
| 3. 例 | 入出力を2〜3個書く |
| 4. 本体 | 実装する |
| 5. 試し | REPL または `rackunit` で確認 |

#### 1.2 四則演算と `define`

##### 数値と四則

```racket
(+ 10 3)    ; 13
(- 10 3)    ; 7
(* 10 3)    ; 30
(/ 10 4)    ; 2.5  （整数同士でも有理数・実数になり得る）
(quotient 10 4)  ; 2  整数除算
(remainder 10 4) ; 2  余り
```

##### 名前を付ける — `define`

```racket
(define width 30)
(define height 20)
(define cell-size 15)

(define (board-pixel-width)
  (* width cell-size))

(board-pixel-width)  ; => 450
```

- `(define 名前 値)` … 定数やデータの名前
- `(define (名前 引数…) 本体)` … 関数定義の糖衣構文  
  下と同じ意味:

```racket
(define square
  (lambda (x) (* x x)))
```

##### 練習問題（手を動かす）

**P1-1** `square` を定義し、`8` で `64` になることを確認せよ。  
**P1-2** 2数の平均 `average` を定義せよ（ヒント: `/` と `+`）。  
**P1-3** ライフ盤のピクセル高さ `board-pixel-height` を `height` と `cell-size` から定義せよ。

模範（抜粋）:

```racket
(define (square x) (* x x))
(define (average a b) (/ (+ a b) 2))
(define (board-pixel-height) (* height cell-size))
```

> Python 学習者向けメモ: `my-100-pon.rkt` には Python 風の「問題1〜」が並ぶが、本編は **Racket の自然な形**（`define`・式・リスト）で進める。出力は `print` より、まず**返り値**で考える。

#### 1.3 `printf` と文字列

デバッグや説明用に、文字列と表示を使う。

```racket
(string-append "Hello, " "Racket")  ; => "Hello, Racket"
(string-length "Racket")            ; => 6

(define (greet name)
  (string-append "Hello, " name "!"))

(greet "Racket")  ; => "Hello, Racket!"
```

画面に出す（副作用）:

```racket
(printf "cell (~a, ~a) alive? ~a\n" 3 2 #t)
```

- `~a` … 人間向け表示
- `~s` / `~v` … 読み戻し向き・デバッグ向き（付録Fでも再登場）

**P1-4** `greet` を自分の名前で試し、文字列が返ることを確認せよ（`printf` しなくてもよい）。  
**P1-5** `show-cell-label` のように、座標と生死を1行で出す関数を書け。

#### 1.4 真偽値と条件分岐 `if`

##### 真偽

```racket
#t   ; true
#f   ; false

(= 3 3)      ; #t
(< 2 5)      ; #t
(and #t #f)  ; #f
(or #t #f)   ; #t
(not #f)     ; #t
```

##### `if` は式である

```racket
(if 条件
    真のときの式
    偽のときの式)
```

どちらも**値を返す**。他言語の「文」としての if と違い、そのまま `define` の本体に置ける。

##### ライフゲームへの最初の橋渡し

ルールのうち「1セルの次状態」だけを切り出す:

```racket
;; 生きているセルは近傍 2 or 3 で生き残る
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

;; 死んでいるセルは近傍ちょうど 3 で誕生
(define (births? neighbors)
  (= neighbors 3))

(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))
```

試し:

```racket
(next-alive? #t 2)  ; #t  生存・近傍2 → 生き残る
(next-alive? #t 1)  ; #f  過疎
(next-alive? #f 3)  ; #t  誕生
(next-alive? #f 2)  ; #f
```

`cond` で書くと同じ構造が読みやすいこともある:

```racket
(define (next-alive?/cond currently-alive? neighbors)
  (cond
    [currently-alive? (or (= neighbors 2) (= neighbors 3))]
    [else (= neighbors 3)]))
```

**P1-6** `survives?` を、近傍が 0〜8 の表にして頭の中（または紙）で埋めよ。  
**P1-7** `next-alive?` と `next-alive?/cond` が同じ結果になる例を3つ REPL で確認せよ。

#### 1.5 リストの基礎 — `list`, `first`, `rest`

ライフゲームの盤面は、後の章で「生存セルのリスト」として表す。

```racket
(define sample-cells
  '((3 . 2) (4 . 3) (2 . 4) (3 . 4) (4 . 4)))
```

- `'…` は quote。リストやペアを**データとして**書く
- `(3 . 2)` は **ペア**（cons セル）。x と y の組に使う
- `first` / `rest` … 先頭と残り（古い教材の car/cdr の代わりに本編ではこちらを優先）

```racket
(first sample-cells)           ; => (3 . 2)
(rest sample-cells)            ; => ((4 . 3) …)
(empty? '())                   ; => #t
(cons '(1 . 1) sample-cells)   ; 先頭に足した**新しい**リスト
```

所属判定:

```racket
(define (alive? cells cell)
  (and (member cell cells) #t))

(alive? sample-cells '(4 . 4))  ; #t
(alive? sample-cells '(0 . 0))  ; #f
```

リストの長さ（再帰の予告）:

```racket
(define (my-length xs)
  (if (empty? xs)
      0
      (+ 1 (my-length (rest xs)))))
```

`map` / `filter` は第2章の主役だが、味見だけ:

```racket
(map car sample-cells)  ; 各セルの x 座標のリスト
(filter (lambda (c) (= (car c) 4)) sample-cells)
```

**P1-8** 自分の好きな3セルのリスト `my-cells` を作れ。  
**P1-9** `alive?` でその1セルが「いる／いない」を確認せよ。  
**P1-10** `my-length` で要素数を数え、手計算と一致するか見よ。

#### 1.6 三角関数 — 計算と「動き」の直感

ライフゲーム本体は整数グリッドだが、**アニメ・音楽・振動**の説明や、後の可視化（#30）のために三角関数を置いておく。

定義（弧度法）:

- $\sin\theta$, $\cos\theta$ … 単位円上の縦・横
- 度数 $d$ から弧度: $\theta = d \cdot \pi / 180$

```racket
(define (deg->rad deg)
  (* deg (/ pi 180)))

(define (unit-circle-point deg)
  (let ([t (deg->rad deg)])
    (list (cos t) (sin t))))

(unit-circle-point 0)   ; およそ (1 0)
(unit-circle-point 90)  ; およそ (0 1)
```

エッセイ的メモ（興味付け）:

- 円運動を真横から見ると、上下の動きは **単振動**（サイン波）に見える
- 音楽の音色や、画面上のなめらかな往復も同じ道具で書ける
- ライフゲームの「離散グリッド」と対比すると、連続と離散の両方が見える

詳細な公式表は **付録G**。ここでは「`sin`/`cos` が呼べる」「角度と座標がつながる」まででよい。

**P1-11** `unit-circle-point` で 0° と 180° を試し、x の符号が反転することを見よ。

#### 1.7 ベクトル — 位置とずらし

高校1年レベルの2Dベクトルを、ペア `(vx . vy)` で表す。

```racket
(define (v-add a b)
  (cons (+ (car a) (car b))
        (+ (cdr a) (cdr b))))

(define (v-scale k a)
  (cons (* k (car a))
        (* k (cdr a))))
```

セルの近傍8マスは「自分＋デルタ」:

```racket
(define neighbor-deltas
  '((-1 . -1) (0 . -1) (1 . -1)
    (-1 .  0)          (1 .  0)
    (-1 .  1) (0 .  1) (1 .  1)))

(define (shift-cell cell delta)
  (v-add cell delta))

(define (cell-neighbors cell)
  (map (lambda (d) (shift-cell cell d)) neighbor-deltas))

(cell-neighbors '(3 . 2))
;; => ((2 . 1) (3 . 1) (4 . 1) (2 . 2) (4 . 2) (2 . 3) (3 . 3) (4 . 3))
```

これは後の `count-neighbors` / `next-generation`（第4章）の土台そのもの。

**P1-12** `(cell-neighbors '(0 . 0))` の要素数が 8 であることを確認せよ。  
**P1-13** `v-scale` で `(2 . 3)` を 2 倍し、`(4 . 6)` になることを確認せよ。

#### 1.8 行列 — グリッドの見方

二次元リストを「行のリスト」と見ると、小さな盤面になる。

```racket
(define tiny-grid
  '((0 1 0)
    (0 0 1)
    (1 1 1)))

(define (grid-ref grid r c)
  (list-ref (list-ref grid r) c))

(grid-ref tiny-grid 0 1)  ; => 1
(grid-ref tiny-grid 2 2)  ; => 1
```

- 本編の主表現は **疎な生存リスト**（生きている座標だけ）
- 行列・二次元リストは「密な盤」「画像」「線形変換」の話で再登場（第3章）

**P1-14** `tiny-grid` の中央 `(1,1)` の値を `grid-ref` で読め。

#### 1.9 章末まとめと次章予告

この章で手に入れた部品:

| 部品 | ライフゲームでの意味 |
|------|----------------------|
| `define` / 関数 | ルールを名前付きの計算にする |
| `if` / 真偽 | 生存・誕生の分岐 |
| リストとペア | 盤面・座標 |
| `alive?` | そのマスにセルがいるか |
| `cell-neighbors` | 周囲8マス |
| ベクトル加減 | ずらし・移動 |

**次章（第2章）** では、再帰・`cond`・`let`・高階関数（`map`/`filter`/`foldl`）を中心に、「リストを舐めて集計する」力を鍛える。第4章の `next-generation` は、その延長線上にある。

**今すぐ試すなら**:

```text
draft-publish-books-2026/code/ch01-basics.rkt
```

を DrRacket で開き Run。`(module+ test)` が通れば、この章の核はクリア。

---

## 執筆ログ

| 日付 | 内容 |
|------|------|
| 2026-06-16 | Issues #8–#12 反映（目次改訂） |
| 2026-07-11 | 7月優先を確定。成功定義=3章ドラフト。**序章本文** を初稿化。正本は本ファイル。 |
| 2026-07-11 | **第1章本文** 初稿 + `code/ch01-basics.rkt`（rackunit 付き） |

---

*最終更新: 2026-07-11（第1章本文初稿 / Issues #27 #33 連携）*