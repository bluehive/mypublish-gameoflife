---
title: "第1章　Racketの基礎——式と関数"
---

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
