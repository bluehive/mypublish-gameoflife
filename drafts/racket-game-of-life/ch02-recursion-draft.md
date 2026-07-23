---
title: "第2章　再帰——Racketの核心"
---

> **この章のゴール**  
> リストの**自己参照データ定義**と、対応する**関数テンプレート**で再帰を書く。  
> **参照**: [howtocode htdp_templates](https://howtocode.pages.dev/htdp_templates)  
> **付属コード**: `code/ch02-recursion.rkt`（`#lang htdp/bsl`）

#### 2.1 デザインレシピとテンプレート（章の定型）

howtocode のチェックリストを本でも使う。

**データ**

1. Data Description  
2. Interpretation  
3. Data Examples  
4. このデータを処理する **template**

**関数**

1. Signature, purpose, stub  
2. Examples（`check-expect`。リストなら長さ 2 以上も）  
3. Template（データから）  
4. Code body  
5. Test, review, refactor  

#### 2.2 データ定義: `ListOfNumber`

```racket
;; ListOfNumber is one of:
;;  - empty
;;  - (cons Number ListOfNumber)
;; interp. 数のリスト

(define LON0 empty)
(define LON2 (cons 4 (cons 6 empty)))
```

テンプレート（本文用・実行ファイルには完成関数のみ）:

```racket
(define (list-of-number-temp lon)
  (cond
    [(empty? lon) (...)]                      ; 基本ケース
    [else (... (first lon)
               (list-of-number-temp (rest lon)))]))  ; 自己参照
```

#### 2.3 単純再帰の例

```racket
(define (factorial n)
  (cond
    [(<= n 1) 1]
    [else (* n (factorial (- n 1)))]))

(define (my-length lon)
  (cond
    [(empty? lon) 0]
    [else (+ 1 (my-length (rest lon)))]))

(define (sum-list lon)
  (cond
    [(empty? lon) 0]
    [else (+ (first lon) (sum-list (rest lon)))]))
```

BSL には `map` / `filter` / `lambda` が無い。**同じ仕事はテンプレート再帰で書く**（Intermediate に上がったら高階を再導入してよい）。

#### 2.4 `cond` による区分（enum / interval）

```racket
(define (neighbor-label n)
  (cond
    [(= n 0) "empty"]
    [(= n 1) "lonely"]
    [(or (= n 2) (= n 3)) "stable-or-birth"]
    [else "overcrowd"]))
```

#### 2.5 `ListOfPosn` と近傍

```racket
;; ListOfPosn is one of: empty | (cons Posn ListOfPosn)

(define (xs-of cells)
  (cond
    [(empty? cells) empty]
    [else (cons (posn-x (first cells))
                (xs-of (rest cells)))]))
```

`cell-neighbors` は 8 近傍を `list` で返す（第1章と同型）。

#### 2.6 まとめ

| 概念 | 役割 |
|------|------|
| データ定義 | 場合分けの設計図 |
| テンプレート | 白紙を埋める骨組み |
| `check-expect` | 例＝仕様 |
| 構造的再帰 | BSL でのリスト処理の主戦力 |

第3章でグリッド、第4章で `next-generation` に接続する。
