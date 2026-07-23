---
title: "第2章　再帰——Racketの核心"
---

> **この章のゴール**  
> 再帰と `cond` でリストを処理し、`map` / `filter` / `foldl` を「読んで書ける」ようにする。  
> ライフゲームの近傍・候補集合につながる筋肉をつける。  
> **付属コード**: `code/ch02-recursion.rkt`（`#lang htdp/asl` + `check-expect`）  
> **状態**: ドラフト（[Issue #2](https://github.com/bluehive/mypublish-gameoflife/issues/2) / plan P-05）

#### 2.1 単純再帰の形

再帰の基本形は次の二つに分かれる。

1. **終了条件**（これ以上壊さない）  
2. **より小さい同じ問題**への呼び出し  

```racket
(define (factorial n)
  (cond
    [(<= n 1) 1]
    [else (* n (factorial (- n 1)))]))

(factorial 5)  ; => 120
```

フィボナッチ（素朴版・教育用。効率は後でアキュムレータへ）:

```racket
(define (fib n)
  (cond
    [(= n 0) 0]
    [(= n 1) 1]
    [else (+ (fib (- n 1)) (fib (- n 2)))]))
```

デザインレシピでは、まず**例**を `check-expect` に書いてから本体を埋める。

**P2-1** `factorial` で 0 と 6 を試し、手計算と一致するか見よ。  
**P2-2** `fib 7` を手計算し、REPL と照合せよ。

#### 2.2 `cond` とパターンマッチ的思考

`if` が二股なら、`cond` は多股。上から順に最初の真の枝が選ばれる。

```racket
(define (neighbor-label n)
  (cond
    [(< n 0) "invalid"]
    [(= n 0) "empty"]
    [(= n 1) "lonely"]
    [(or (= n 2) (= n 3)) "stable-or-birth"]
    [else "overcrowd"]))
```

ライフの B3/S23 も、本質は「近傍数に応じた表」である（第1・4章の `next-alive?`）。

**P2-3** `neighbor-label` に 2, 3, 8 を渡し、文字列を確認せよ。

#### 2.3 末尾再帰とアキュムレータ

素朴な長さ:

```racket
(define (my-length/naive xs)
  (if (empty? xs)
      0
      (+ 1 (my-length/naive (rest xs)))))
```

アキュムレータ版（末尾で「答えの途中」を持ち回る）:

```racket
(define (my-length/acc xs acc)
  (cond
    [(empty? xs) acc]
    [else (my-length/acc (rest xs) (add1 acc))]))

(define (my-length xs)
  (my-length/acc xs 0))
```

`local` でループを閉じ込める書き方もよく使う（付属コードの `sum-list`）。

- 第3章・第4章の「候補セルを集める」「世代を n 回進める」も、同じ骨格になりやすい  
- ASL では `let` / `let*` / `letrec` / `local` が使える（詳細は [Advanced Student](https://docs.racket-lang.org/htdp-langs/advanced.html)）

**P2-4** `sum-list` を自分で書き直し、`(list 5 5 5)` が 15 になることを `check-expect` せよ。

#### 2.4 高階関数 `map`, `filter`, `foldl`

| 関数 | イメージ | ライフでの例 |
|------|----------|--------------|
| `map` | 各要素を変換 | セル → その x 座標 |
| `filter` | 条件で残す | 偶数 x のセルだけ |
| `foldl` | 左から畳み込み | 数の合計 |

```racket
(define (xs-of cells)
  (map posn-x cells))

(define (even-x-cells cells)
  (filter (lambda (c) (even? (posn-x c))) cells))

(define (sum-nums nums)
  (foldl + 0 nums))
```

近傍 8 マスは、第1章と同じく **`map` + デルタリスト**:

```racket
(define (cell-neighbors cell)
  (map (lambda (d) (shift-cell cell d)) neighbor-deltas))
```

第4章の `count-neighbors` は `filter` + `length`（または `foldl`）で書ける。

**P2-5** `xs-of` にグライダー断片の posn リストを渡し、x の列を確認せよ。  
**P2-6** `cell-neighbors` の結果が常に 8 個であることを `check-expect` せよ。

#### 2.5 再帰で所属判定 — `member?` の素朴版

```racket
(define (my-member? x xs)
  (cond
    [(empty? xs) false]
    [(equal? x (first xs)) true]
    [else (my-member? x (rest xs))]))
```

ASL 組み込みの `member?` と同じ役割。第4章の `alive-in?` はこれを集合演算の入口にしている。

**P2-7** `my-member?` と `member?` が同じ結果になる例を2つ書け。

#### まとめ

| 道具 | 役割 |
|------|------|
| 単純再帰 | 構造を一つずつ剥がす |
| `cond` | 多肢の規則表 |
| アキュムレータ | 末尾で効率よく畳む |
| `map` / `filter` / `foldl` | リスト変換の定番 |
| `posn` + 再帰/高階 | 盤面操作の下地（第3–4章へ） |

次章ではグリッド表現を深め、第4章で `next-generation` に接続する。

> **実験メモ**  
> Issue #2 / plan P-05。Zenn `chapters` への追加はユーザー承認後。
