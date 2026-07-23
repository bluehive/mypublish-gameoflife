---
title: "第1章　Racketの基礎——式と関数"
---

> **この章のゴール**  
> BSL の基本構文をチートシートとして一通り触れ、小さな関数と `check-expect` が書ける。  
> **参照**: [howtocode cheatsheet](https://howtocode.pages.dev/cheatsheet)  
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

※ Beginning Student では **引数ゼロの関数定義ができない**。計算結果は定数にする。

#### 1.4 `if` と `cond`

```racket
(if (string=? "hi" "bye") "yarr" "meow")  ; => "meow"

(define ran-num 3)
(cond
  [(< ran-num 3) "<3"]
  [(= ran-num 3) "equal"]
  [else "other"])
```

ライフ規則の1セル分（応用）:

```racket
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

(define (births? neighbors)
  (= neighbors 3))

(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))
```

#### 1.5 関数

```racket
(define (square-of x)
  (* x x))

(define (greet name)
  (string-append "Hello, " name "!"))
```

必ず **例を先に** `check-expect` で書く（デザインレシピ）。

```racket
(check-expect (square-of 8) 64)
(check-expect (greet "Racket") "Hello, Racket!")
```

#### 1.6 構造体 `define-struct` と `posn`

```racket
(define-struct dog (name age))
(define d1 (make-dog "flipper" 5))
(dog-name d1)  ; => "flipper"
(dog? d1)      ; => true
```

2D 座標は BSL 組み込みの `make-posn` / `posn-x` / `posn-y` を使う。

```racket
(define SAMPLE-CELL (make-posn 3 2))
(posn-x SAMPLE-CELL)  ; => 3
```

#### 1.7 リスト（`cons` / `first` / `rest` / `empty`）

```racket
(define SAMPLE-CELLS
  (list (make-posn 3 2)
        (make-posn 4 3)
        (make-posn 2 4)))

(define (my-length xs)
  (cond
    [(empty? xs) 0]
    [else (+ 1 (my-length (rest xs)))]))
```

所属判定（再帰の予告）:

```racket
(define (alive? cells cell)
  (cond
    [(empty? cells) false]
    [(equal? (first cells) cell) true]
    [else (alive? (rest cells) cell)]))
```

#### 1.8 近傍8マス（第4章への橋）

BSL には `map` が無いので、8 個を `list` で明示する。

```racket
(define (cell-neighbors cell)
  (list (shift-cell cell -1 -1)
        … 
        (shift-cell cell 1 1)))
```

付属コードを Run し、すべての `check-expect` が通ることを確認する。

```bash
racket code/ch01-basics.rkt
```

> 参考文献: [Syntax Cheat Sheet](https://howtocode.pages.dev/cheatsheet) / [BSL ドキュメント](https://docs.racket-lang.org/htdp-langs/beginner.html)
