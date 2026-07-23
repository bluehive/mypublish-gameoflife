---
title: "第1章　Racketの基礎——式と関数"
---

> **この章のゴール**  
> BSL の基本構文をチートシートとして一通り触れ、小さな関数と `check-expect` が書ける。  
> **参照**: [howtocode cheatsheet](https://howtocode.pages.dev/cheatsheet) / [htdp_templates](https://howtocode.pages.dev/htdp_templates)  
> **付属コード**: `code/ch01-basics.rkt`（`#lang htdp/bsl`）

#### 1.1 基本データ型

```racket
123
"yayy"
#true
#false
;; true / false とも書ける（BSL）
```

#### 1.2 式（前置記法）

```racket
;; 規則: (演算子 引数 …)
(+ 2 4)
(+ 2 4 (* 3 6 (+ 1 1)))
```

序章の評価規則を復習しながら、相互作用ウィンドウで試す。

#### 1.3 定数 `define`

```racket
(define WIDTH 30)
(define HEIGHT 20)
(define CELL-SIZE 15)

(define BOARD-PIXEL-WIDTH (* WIDTH CELL-SIZE))
;; => 450
```

**なぜ「引数ゼロの関数」ではなく定数か（BSL）**

他の言語では「引数なしの関数」で幅を計算したくなります。

```racket
;; Beginning Student ではこれはエラーになる
;; (define (board-pixel-width) (* WIDTH CELL-SIZE))
```

BSL（Beginning Student）では、`(define (名前 引数…) …)` の形に**少なくとも1つの引数**が必要です。引数が無い「手続き呼び出し」は、この言語レベルでは教えません。

代わりに次のどちらかにします。

1. **定数**にする（値が決まっているとき）— 上の `BOARD-PIXEL-WIDTH`  
2. **引数を取る関数**にする（入力で結果が変わるとき）— 例: `(define (scale n) (* n CELL-SIZE))`

ライフ盤のピクセル幅は `WIDTH` と `CELL-SIZE` から一意に決まるので、本章では定数で十分です。

#### 1.4 `if` と `cond`

```racket
(if (string=? "hi" "bye") "yarr" "meow")  ; => "meow"

(define ran-num 3)
(cond
  [(< ran-num 3) "<3"]
  [(= ran-num 3) "equal"]  ; => "equal"
  [else "other"])
```

ライフ規則の1セル分（応用）:

```racket
;; 生きているセルは、近傍が 2 または 3 なら生き残る
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

;; 死んでいるセルは、近傍がちょうど 3 なら誕生する
(define (births? neighbors)
  (= neighbors 3))

;; 今の生死と近傍数から、次の瞬間生きているか
(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))
```

#### 1.5 関数

ここでは「**名前を付けた計算**」の書き方を説明します。  
`(define (関数名 引数…) 本体)` は、「引数を受け取って本体の式を評価し、その値を返す」という意味です。

```racket
;; square-of: 数 x を受け取り、x の2乗を返す
(define (square-of x)
  (* x x))

;; greet: 文字列 name を受け取り、挨拶文を返す
(define (greet name)
  (string-append "Hello, " name "!"))
```

- `square-of` の本体 `(* x x)` … 掛け算の式そのものが返り値  
- `greet` の本体 `string-append` … 文字列を連結した新しい文字列が返り値  

**例を先に書く**とは、実装の細部を詰める前に、「入力がこうなら出力はこう」を先に固定することです。BSL ではそれを `check-expect` で書きます。

```racket
(check-expect (square-of 8) 64)
(check-expect (greet "Racket") "Hello, Racket!")
```

意味: 「`(square-of 8)` を評価した結果は `64` であってほしい」。Run すると自動で照合されます。

**デザインレシピ**（HtDP / howtocode）は、関数を書くときの短い手順書です。本章では次の5つを使います（詳細とデータ別の型紙は **1.10**）。

1. **データ** — 何を表すか（数、文字列、posn、リスト…）  
2. **署名・目的** — 関数名・引数・返り値を一文で  
3. **例** — `check-expect` で入出力を2つ以上  
4. **本体** — 実装する  
5. **試し・見直し** — Run してテストが通るか確認  

「例を先に」は手順 3 を、手順 4 より前にやる、という習慣です。

#### 1.6 構造体 `define-struct` と `posn`

**構造体**は、「いくつかの値をひとまとめにしたデータ」です。  
`define-struct` で型名とフィールド名を宣言すると、作る関数・取り出す関数・判定関数が自動で用意されます。

ライフゲームでは、例えば「座標つきのセル」を自分で構造体にできます（教育用の一歩。本線の盤面はあとで `posn` のリストでも表します）。

```racket
;; Cell は x, y（整数座標）と alive?（生死）を持つ
(define-struct cell (x y alive?))
;; interp. 盤上の1マス。alive? が true なら生きている

(define C1 (make-cell 3 2 true))   ; (3,2) に生きているセル
(define C2 (make-cell 0 0 false))  ; (0,0) は死

(cell-x C1)       ; => 3
(cell-y C1)       ; => 2
(cell-alive? C1)  ; => true
(cell? C1)        ; => true
(cell? 321)       ; => false
```

**`posn`** は BSL に最初からある「平面上の点」用の構造体です（自分で `define-struct` しなくてよい）。  
第4章の本線では、生存セルだけを `make-posn` のリストで持つ書き方が中心になります（死セルはリストに載せない）。

- `make-posn` … x と y から点を**作る**  
- `posn-x` / `posn-y` … 点から座標を**取り出す**  
- `posn?` … それが posn かどうか  

```racket
;; x=3, y=2 の点（生存セルの座標の一例）
(define SAMPLE-CELL (make-posn 3 2))
(posn-x SAMPLE-CELL)  ; => 3
(posn-y SAMPLE-CELL)  ; => 2
```

`make-posn` の第1引数が横方向、第2引数が縦方向、と決めて本では一貫して使います。  
`cell` 構造体は「生死もフィールドに持つ」練習、`posn` は「生きている座標だけ集める」本線、と役割を分けて覚えてください。

#### 1.7 リスト（`cons` / `first` / `rest` / `empty`）

リストは「0個以上の値を順番に並べたもの」です。BSL では次が基本操作です。

- `empty` — 空のリスト（要素なし）  
- `(cons 先頭 残りリスト)` — 先頭に1つ足した**新しい**リスト  
- `(first リスト)` — 先頭の要素  
- `(rest リスト)` — 先頭を除いた残り  
- `(empty? リスト)` — 空なら true  
- `(list a b c)` — `cons` を重ねた糖衣（読み書き用）  

```racket
;; 生存セル3個のリスト（posn が3つ）
(define SAMPLE-CELLS
  (list (make-posn 3 2)
        (make-posn 4 3)
        (make-posn 2 4)))
;; 上はだいたい次と同じ意味:
;; (cons (make-posn 3 2)
;;       (cons (make-posn 4 3)
;;             (cons (make-posn 2 4) empty)))

;; リストの長さ: 空なら 0、そうでなければ 1 + 残りの長さ
(define (my-length xs)
  (cond
    [(empty? xs) 0]
    [else (+ 1 (my-length (rest xs)))]))
```

**所属判定**とは、「このセルは、生存リストの中にいるか？」を true/false で答えることです。

**再帰**とは、関数の定義の中で**自分自身を呼び出す**書き方です。リストのように「空」か「先頭+残り」かに分かれるデータでは、残りに対して同じ問題を解けば全体が解けます。

```racket
;; alive?: リスト cells の中に cell があるか
(define (alive? cells cell)
  (cond
    [(empty? cells) false]                      ; もう候補がない → いない
    [(equal? (first cells) cell) true]          ; 先頭が探しているセル → いる
    [else (alive? (rest cells) cell)]))         ; ★再帰: 残りだけで同じ判定
```

`else` 枝の `(alive? (rest cells) cell)` が再帰呼び出しです。リストが1つずつ短くなり、いつか `empty` に至って止まります。

#### 1.8 近傍8マス（第4章への橋）

**`map`（高階関数）** は、「リストの各要素に同じ関数をかけて、結果のリストを作る」ための関数です（例: Intermediate 以降でよく使う）。BSL には `map` が無いので、同じことをするときは **8 個をその場で `list` に並べる**か、自分で再帰を書きます。

ここでは8近傍を省略せずに書きます（付属コードと同じ）。

```racket
;; cell を (dx, dy) だけずらした新しい posn
(define (shift-cell cell dx dy)
  (make-posn (+ (posn-x cell) dx)
             (+ (posn-y cell) dy)))

;; cell の周囲8マス（自分自身は含まない）
(define (cell-neighbors cell)
  (list (shift-cell cell -1 -1)
        (shift-cell cell  0 -1)
        (shift-cell cell  1 -1)
        (shift-cell cell -1  0)
        (shift-cell cell  1  0)
        (shift-cell cell -1  1)
        (shift-cell cell  0  1)
        (shift-cell cell  1  1)))
```

#### 1.9 付属コードの `check-expect` と実行

テストは **`code/ch01-basics.rkt` の末尾**にまとまっています（本文の断片ではなく、ファイル全体を Run する想定）。  
ここまでの本文に沿った例だけを挙げます（`average` など本文未出の関数は載せません）。

```racket
;; 1.3 定数
(check-expect BOARD-PIXEL-WIDTH 450)

;; 1.4 if / ライフ1セル
(check-expect (survives? 2) true)
(check-expect (survives? 1) false)
(check-expect (births? 3) true)
(check-expect (next-alive? true 2) true)
(check-expect (next-alive? false 3) true)
(check-expect (next-alive? true 0) false)

;; 1.5 関数
(check-expect (square-of 8) 64)
(check-expect (greet "Racket") "Hello, Racket!")

;; 1.6 構造体 cell と posn
(check-expect (cell-x C1) 3)
(check-expect (cell-alive? C1) true)
(check-expect (posn-x SAMPLE-CELL) 3)

;; 1.7 リスト・所属・再帰
(check-expect (my-length SAMPLE-CELLS) 3)
(check-expect (alive? SAMPLE-CELLS (make-posn 3 2)) true)
(check-expect (alive? SAMPLE-CELLS (make-posn 0 0)) false)

;; 1.8 近傍
(check-expect (my-length (cell-neighbors (make-posn 0 0))) 8)

(test)  ; CLI で結果を表示するための呼び出し
```

```bash
racket code/ch01-basics.rkt
```

DrRacket なら同ファイルを開いて Run。すべて通れば、1.1〜1.8 の核はクリアです。  
デザインレシピの考え方と、データ種別ごとの型紙は次節でまとめます。

#### 1.10 デザインレシピとデータパターン（howtocode 準拠）

1.5 で触れたデザインレシピを、もう少し丁寧に整理します。  
内容は [howtocode の htdp_templates](https://howtocode.pages.dev/htdp_templates) に沿った解説です（三角ロジック＝主張・根拠・事実の整理で読みます）。

##### 1.10.1 全体の設計思想

**事実（何が示されているか）**

プログラムが扱うデータの性質に応じて、次の4パターンについて、データ定義・関数のテンプレート（骨組み）・実装例が用意されています。

1. シンプルな基本データ（Simple Base Data）  
2. 列挙型（Enum）  
3. 範囲（Intervals）  
4. 共用体（Union / 異種データの混在）  

**論拠（なぜ先にデータとテンプレートか）**

- バグの多くは、「入力のすべての可能性を網羅しきれていないこと」や「向かない型への処理」から起きる。  
- HtDP のデザインレシピは、**データ構造が関数の構造を決める（データ駆動）**という原則に立つ。  
- 例: データが「信号の3色」なら、関数はだいたい **3枝の `cond`** になる。データが「真偽と数のどちらか」なら、**`boolean?` / `number?` などの型判定による分岐**になる。  
- データの形が決まれば関数の骨組みも機械的に導けるので、勘だけに頼らず、漏れの少ないプログラムを組み立てやすい。  

**主張（この節の結論）**

扱うデータの構造を正しく定義できれば、それに対応する関数の骨組み（テンプレート）はほぼ決まる。以下のパターンはその型紙である。

##### 1.10.2 パターン別の型紙

**パターン1: シンプルな基本データ**

- **意味**: 分解しない単一の値（数や文字列そのもの）をそのまま処理する。  
- **テンプレート**: `(define (関数名 引数) (... 引数))`  
- **例**:

```racket
; double: (Number -> Number)
; 与えられた数値を2倍にする
(check-expect (double 2) 4)
(define (double n)
  (* n 2))  ; テンプレートの「...」を具体的な計算に置き換える
```

本章の `square-of` や `greet` も、このパターンに近いです。

**パターン2: 列挙型（Enum）**

- **意味**: 取りうる値が、有限個の決まった候補だけである場合。  
- **テンプレート**: 候補の個数と同じ本数の `cond` 枝を用意する。  
- **例**: 信号 `"red"` / `"green"` / `"yellow"` なら、テンプレートの時点で枝は3本と決まる。

```racket
(define (traffic-light-next st)
  (cond
    [(string=? "red" st) "green"]
    [(string=? "green" st) "yellow"]
    [(string=? "yellow" st) "red"]))
```

本章の `survives?` のように真偽で切る場合も、「場合の数に合わせて枝を用意する」点では同じ考え方です。

**パターン3: 範囲（インターバル / Intervals）**

- **意味**: 情報が、ある範囲の数である場合。数学の区間を条件式で表す。  
- **判定のルール**:  
  - 角括弧 `[` `]`（境界を含む）→ 不等号に `=` を付ける（`>=` / `<=`）  
  - 丸括弧 `(` `)`（境界を含まない）→ `=` を付けない（`>` / `<`）  
- **例**:  
  - `[0, 100]`（0以上100以下）→ `(and (>= n 0) (<= n 100))`  
  - `(80, 100]`（80より大きく100以下）→ `(and (> num 80) (<= num 100))`  

近傍数 0〜8 のような整数も、「範囲や帯」として `cond` に落とす練習が第2章以降で出てきます。

**パターン4: 共用体（Union / 異種データの混在）**

- **意味**: 異なる型（例: Boolean と Number）が混ざりうる場合。  
- **テンプレート**: 各型の述語（`boolean?` / `number?` など）で `cond` 分岐する。  
- **例**: 有効な ID は「無しを表す `#false`」か「番号を表す Number」のどちらか。

```racket
(define (pull-over-id-check? x)
  (cond
    [(boolean? x) #false]  ; Boolean（#false）なら無効
    [(number? x)  #true])) ; Number（ID番号）なら有効
```

##### 1.10.3 手順の再掲

データの種類によらず、デザインレシピではだいたい次の順で進みます。

1. データ定義  
2. シグネチャと目的  
3. テスト（`check-expect`）  
4. テンプレート作成  
5. 実装  

1.5 の「例を先に」は、上の 3 を 5 より前にやる、という意味です。第2章ではリストの自己参照とテンプレートを中心に、この手順をさらに練習します。

#### 1.11 参考文献

- [howtocode — Syntax Cheat Sheet](https://howtocode.pages.dev/cheatsheet)  
- [howtocode — Templates](https://howtocode.pages.dev/htdp_templates)  
- [BSL ドキュメント](https://docs.racket-lang.org/htdp-langs/beginner.html)  
