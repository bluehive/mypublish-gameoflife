---
title: "序章　なぜRacketか——ゲームで学ぶ関数型"
---

> **この章のゴール**  
> なぜ Racket（BSL）から学ぶかを理解し、DrRacket で式を評価できる状態になる。  
> **スタイル参照**: [howtocode introduction](https://howtocode.pages.dev/introduction) / [installation](https://howtocode.pages.dev/installation) / [expressions](https://howtocode.pages.dev/expressions)  
> **言語**: Beginning Student（`#lang htdp/bsl`）— ユーザー方針 2026-07-23

#### 0.1 なぜ「他の人気言語」から始めないか

プログラミングの難しさは、変数・ループ・条件といった部品そのものより、**部品をどう組み合わせて目的を達するか**にあります。作文にたとえれば、つづりより「論旨のつなぎ」です。

Java や Python などで最初に覚えることが多いのは次のような**言語ごとの作法**です。

- セミコロンをどこに打つか
- 中括弧・インデントがスコープにどう効くか
- クラスや修飾子、`main` の書き方

これらは後から慣れますが、**論理そのものから注意を奪いやすい**、という指摘があります（howtocode: *I'm not here to waste your time on the nuances of language syntax rules*）。

#### 0.2 Racket と「ほぼ一つの構文規則」

本では **Racket** を使います。教育用に絞ると、式の形はだいたい次の一形です。

```racket
(演算子 引数1 引数2 …)
(+ 1 2)    ; => 3
```

起源は LISP 系です。括弧が多いと感じる人もいますが、HTML/JSON/JS が別文法になる世界と対照すると、「同じ形で木を書く」ことの単純さが見えてきます（詳細は howtocode introduction の parentheses 節）。

本の後半では、**コンウェイのライフゲーム**を題材に、式・リスト・再帰を積み上げます。ゲーム産業での Racket 利用例（howtocode が触れる Naughty Dog 等）は興味付けに留め、本線は「書いて試して直す」練習です。

#### 0.3 環境構築（Beginning Student）

1. [Racket をダウンロード](https://download.racket-lang.org/)してインストールする  
2. DrRacket を起動する  
3. 推奨設定（howtocode installation）:
   - `Edit → Preferences → … → Show line numbers`
   - （任意）`View → Use Horizontal Layout`
4. **言語レベル**: 左下（または Language メニュー）で **Beginning Student** を選ぶ  
   本リポジトリのファイル先頭は次でも同じです。

```racket
#lang htdp/bsl
```

5. 定義ウィンドウに式を書き **Run**。下の相互作用ウィンドウが REPL になる。

付録 D（README の付録表）で Windows 11 向けを厚くする予定です。

#### 0.4 式と評価規則

コメント:

```racket
; 一行コメント
#| 複数行コメント |#
```

式の形:

```racket
(+ 2 4)   ; => 6
```

- 引数の区切りは**スペース**（カンマではない）
- 引数自身が式でもよい。評価はおおむね**左から右、内側から外側**へ値に落とす

```racket
(+ 2 4 (* 5 5) (- (+ 3 3) 2) 1)
; (* 5 5) => 25, (+ 3 3) => 6, (- 6 2) => 4
; 最終的に (+ 2 4 25 4 1) => 36
```

エラーの典型:

- `((+ 3 4))` … 外側の括弧に演算子がない  
- `(3 (+ 1 6))` … `3` は演算子ではない  

**開き括弧の直後は常に演算子（または特殊フォーム）**、と覚える。

非正確数: `(sqrt 2)` や `pi` は `#i…` と表示されることがある（メモリ上の近似）。

練習（howtocode Exercise 0 の精神）: 直角三角形の斜辺  
`√(3²+4²)` を BSL の式で書け → `(sqrt (+ (* 3 3) (* 4 4)))`

#### 0.5 この本で作るもの（ライフゲーム）

コンウェイのライフゲーム（B3/S23）:

- 死セルは近傍ちょうど 3 で誕生  
- 生セルは近傍 2 または 3 で生存  
- それ以外は死  

短い規則で、静止物・振動子・グライダーなどが見えるので、**テスト（`check-expect`）と目視の両方**で学習フィードバックが得られます。

進め方の予告:

1. 第1章 — 構文チート（式・define・cond・関数・struct）  
2. 第2章 — 再帰と **HtDP テンプレート**  
3. 第3–5章 — グリッド・ルール・表示  

#### 0.6 デザインレシピ（最短）

howtocode / HtDP の精神を一行にすると:

| 段階 | やること |
|------|----------|
| データ | 何を表すか（記述・解釈・例・テンプレ） |
| 関数 | 署名・目的・stub・例（`check-expect`）・テンプレ・本体・見直し |

詳細は第2章と [htdp_templates](https://howtocode.pages.dev/htdp_templates) を参照。

> 参考文献: [howtocode.pages.dev](https://howtocode.pages.dev/)（構成と教え方を参照。文章は日本語で再執筆）
