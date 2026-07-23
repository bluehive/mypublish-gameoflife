---
title: "第4章　ライフゲームのルールとセルオートマトン"
---

> **この章のゴール**  
> B3/S23 を関数にし、`count-neighbors` と `next-generation` で盤を進める。  
> 有名パターンを **テンプレート＋`check-expect`** で仕様として固定する。  
> **付属コード**: `code/ch04-life-rules.rkt`（`#lang htdp/bsl`）  
> **Issue**: [#3](https://github.com/bluehive/mypublish-gameoflife/issues/3) / [#2](https://github.com/bluehive/mypublish-gameoflife/issues/2)

#### 4.1 ルール（B3/S23）と1セルの次状態

ライフゲームでは、各マスが「生」か「死」かを持ち、**全員がいっせいに**次の状態へ進みます。見るのは自分と、周囲 **8 マス**の生存数だけです（序章の図を思い出してください）。

規則の名前 **B3/S23** の意味:

- **B3（Birth 3）**: 死んでいるマスは、近傍がちょうど 3 なら次は生（誕生）  
- **S23（Survive 2 or 3）**: 生きているマスは、近傍が 2 または 3 なら次も生（生存）  
- それ以外は次は死（過疎または過密）  

デザインレシピどおり、まず関数の約束と例を書きます。

```racket
;; 近傍の生存数が 2 または 3 なら、生きているセルは生き残る
(: survives? (Number -> Boolean))
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

(: births? (Number -> Boolean))
(define (births? neighbors)
  (= neighbors 3))

;; currently-alive? が今の生死、neighbors が近傍の生存数
(: next-alive? (Boolean Number -> Boolean))
(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

(check-expect (survives? 2) true)
(check-expect (survives? 1) false)
(check-expect (births? 3) true)
(check-expect (next-alive? true 2) true)
(check-expect (next-alive? false 3) true)
(check-expect (next-alive? true 0) false)
```

スタブの段階では、例えば次のように仮置きできます（BSL の `...` は第2章参照）。

```racket
(: next-alive? (Boolean Number -> Boolean))
(define (next-alive? currently-alive? neighbors)
  (... currently-alive? neighbors))
```

**P4-1** 中央だけ生・周囲がすべて死のとき、次世代の中央はどうなるか。  
**P4-2** 中央が死・周囲ちょうど 3 生のとき、中央はどうなるか。

#### 4.2 盤面データと近傍

第3章の本線どおり、盤は **生存セルの `ListOfPosn`** です。

```racket
;; ブロック（2×2 の静止物）
(define block
  (list (make-posn 1 1) (make-posn 1 2)
        (make-posn 2 1) (make-posn 2 2)))
```

8 近傍は第1章と同じく、ずらした座標を `list` で並べます（BSL に `map` は無い）。

```racket
;; shift-cell: Posn Number Number -> Posn
(define (shift-cell cell dx dy)
  (make-posn (+ (posn-x cell) dx)
             (+ (posn-y cell) dy)))

;; cell-neighbors: Posn -> ListOfPosn
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

「リストの中にいるか」と「近傍のうち何個が生きているか」も、第2章のリストテンプレートです。

```racket
;; member-posn?: Posn ListOfPosn -> Boolean
(define (member-posn? cell cells)
  (cond
    [(empty? cells) false]
    [(equal? cell (first cells)) true]
    [else (member-posn? cell (rest cells))]))

;; スタブ例:
;; (define (count-neighbors cell live) 0)

;; count-neighbors: Posn ListOfPosn -> Number
(define (count-neighbors cell live)
  (count-alive-in (cell-neighbors cell) live))

;; count-alive-in は「近傍リストのうち live に含まれる個数」
```

`count-alive-in` の本体は付属コードにあります。リストを先頭から見て、生きていれば 1 を足す再帰です。

**P4-3** `block` の `(make-posn 1 1)` の近傍数を手計算し、コードと照合せよ（期待: 3）。

#### 4.3 次世代 `next-generation`（テンプレート駆動）

無限に広い盤を全部調べる必要はありません。次に生まれうるマスは、**今生きているマスの隣**にしかありません。

手順:

1. 候補 = 今の生存 ∪ 各生存の 8 近傍（重複は除く）  
2. 各候補について `next-alive?` が true なら、次世代のリストに残す  

BSL では `filter` / `local` が使えないので、付属コードでは `candidate-cells` と `filter-next` を**構造的再帰**で書いています。

```racket
;; 完成形のイメージ（詳細は code/ch04-life-rules.rkt）
;; next-generation: ListOfPosn -> ListOfPosn
(define (next-generation cells)
  (filter-next (candidate-cells cells) cells))
```

スタブ:

```racket
;; next-generation: ListOfPosn -> ListOfPosn
(define (next-generation cells)
  (... cells))
```

比較のために、座標の順序をそろえる `sort-cells` と `same-world?` も付属コードにあります（テスト用）。

**P4-4** 空リストを `next-generation` に渡すとどうなるか。  
**P4-5** 1 セルだけの世界は何世代で消えるか。

#### 4.4 境界（固定とトーラス）

- **固定境界**: 盤の外は「いない」＝近傍に数えない（スパース表現の自然な姿）  
- **トーラス**: 左右・上下がつながる。座標を `modulo` で折り返す  

付属コードの `next-generation/torus` が周期境界版です。グライダーを長く観察するときは、固定＋広い座標の方が分かりやすいことが多いです。

#### 4.5 パターンテスト = テンプレート ＋ `check-expect`

第2章の「例を仕様にする」を、ライフの有名形に適用します。

- **静止物（ブロック）**: 何世代進めても `same-world?` が true  
- **振動子（ブリンカー）**: 2 世代で戻る  
- **宇宙船（グライダー）**: 4 世代で形が戻り、位置が (1,1) ずれる  

```racket
(check-expect (same-world? (next-generation block) block) true)
(check-expect (same-world? (step-n blinker-h 2) blinker-h) true)
(check-expect (same-world? (step-n glider 4) (place glider 1 1)) true)
```

これが「テンプレートで書いた関数が、見た目のパターンと一致している」ことの機械的な保証です。付属コードにはビーコンやトーラス上のブリンカーなども載っています。

**P4-6** ビーコンが周期 2 であることを、自分で `check-expect` を1本足して確かめよ。

#### 4.6 まとめ

- ルールは `next-alive?` に閉じ込める  
- 盤は `ListOfPosn`、近傍は 8 個の `list`、個数はリスト再帰  
- 次世代は候補を作ってから `next-alive?` で残す  
- **パターン ＋ `check-expect`** が第4章の仕様書  

```bash
racket code/ch04-life-rules.rkt
```
