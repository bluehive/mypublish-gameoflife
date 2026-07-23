---
title: "第3章　データ構造——グリッドを表現する"
---

> **この章のゴール**  
> ライフ盤を「データ定義」として表し、テンプレートと `check-expect` で安全に扱えるようにする。  
> **参照**: 第1–2章、[htdp_templates](https://howtocode.pages.dev/htdp_templates)  
> **付属コード**: `code/ch03-grid.rkt`（`#lang htdp/bsl`）  
> **Issue**: [#3](https://github.com/bluehive/mypublish-gameoflife/issues/3)

#### 3.1 なぜ「グリッド」をデータで決めるか

画面の升目そのものをいきなり描く前に、**プログラムが扱う値の形**を決めます。第2章のデザインレシピと同じです。

- 形が決まれば、関数の `cond` の枝や使う部品（`first` / `rest` / フィールド）もほぼ決まる  
- ライフゲームでは「どこが生きているか」が中心なので、その表し方を選ぶ  

本章では次の2通りを紹介します。本線は **A** です。

**A. 生存セルだけを並べる（スパース）**

- データ: `ListOfPosn`（第1–2章と同じ）  
- 生きている座標だけをリストに入れる。死は「リストに無い」で表す  
- 空の盤面は `empty`  

**B. 升目を全部持つ（密グリッド）**

- データ: 行のリスト。各行は 0/1 のリスト  
- すべてのマスを書くので、小さな例の説明には分かりやすい  

どちらも「正しさ」は `check-expect` で固定します。

#### 3.2 データ定義 A: `ListOfPosn`（本線）

第2章の復習です。

```racket
;; ListOfPosn is one of:
;;  - empty
;;  - (cons Posn ListOfPosn)
;; interp. 今生きているセルの座標だけを並べたリスト
;;         （死んでいるマスはリストに載せない）

(define WORLD0 empty)
(define WORLD-BLOCK
  (list (make-posn 1 1) (make-posn 1 2)
        (make-posn 2 1) (make-posn 2 2)))
```

**テンプレート（スタブ付き）**

まだ「何をする関数か」が決まっていないときの骨組みです。BSL では `...` をプレースホルダとして書けます（第2章参照）。

```racket
;; この型を処理する関数の共通の骨
;; 署名コメント: ListOfPosn -> Any
;; （BSL の (: …) では Posn という型名が使えないことがある。完成コードではコメント署名を使う）
(define (world-temp w)
  (cond
    [(empty? w) (...)]
    [else
     (... (first w)
          (world-temp (rest w)))]))
```

完成例（所属判定）は第1–2章の `alive?` と同じです。

```racket
;; (: …) の代わりにコメント署名（Posn は BSL シグネチャ形式に無い）
;; alive?: ListOfPosn Posn -> Boolean
(define (alive? cells cell)
  (cond
    [(empty? cells) false]
    [(equal? (first cells) cell) true]
    [else (alive? (rest cells) cell)]))

(check-expect (alive? WORLD-BLOCK (make-posn 1 1)) true)
(check-expect (alive? WORLD-BLOCK (make-posn 0 0)) false)
```

#### 3.3 データ定義 B: 密グリッド（理解用）

小さな盤を全部書きたいときの形です。

```racket
;; CellValue is 0 or 1
;; interp. 0 = 死, 1 = 生

;; Row is ListOf CellValue
;; Grid is ListOf Row
;; interp. 上から下へ行、左から右へ列

(define TINY-GRID
  (list (list 0 1 0)
        (list 0 0 1)
        (list 1 1 1)))
```

行 `r`・列 `c` の値を取る（BSL では `list-ref` が使えます）。

```racket
;; grid-ref: Grid Number Number -> Number
;; (grid-ref g r c) は g の r 行 c 列の 0 または 1
;; スタブ例: (define (grid-ref g r c) 0)

(: grid-ref (Any Number Number -> Number))
(define (grid-ref g r c)
  (list-ref (list-ref g r) c))

(check-expect (grid-ref TINY-GRID 0 1) 1)
(check-expect (grid-ref TINY-GRID 2 0) 1)
(check-expect (grid-ref TINY-GRID 0 0) 0)
```

#### 3.4 密グリッドと `ListOfPosn` の行き来（考え方）

同じ図形を2通りで表せると、第4章の「生存リスト」が何を意味するかがはっきりします。

- 密 → スパース: 各マスを見て 1 ならその座標をリストに `cons` する（二重の再帰／ループのイメージ）  
- スパース → 密: 各座標に 1 を置き、それ以外は 0  

付属コード `code/ch03-grid.rkt` では、小さな例で `grid-ref` とブロックの `ListOfPosn` を `check-expect` します。完全な相互変換は発展課題でも構いません。

#### 3.5 不変データ（世代を進める準備）

ライフでは「今の盤」をその場で書き換えるより、**次の盤を新しく作って返す**方が安全です。

- 入力の `ListOfPosn` は残したまま  
- `next-generation`（第4章）は新しいリストを返す  
- だからテストで「1世代前」と「1世代後」を同時に比較できる  

これは第2章の「`cons` は新しいリストを作る」と同じ発想です。

#### 3.6 まとめと第4章への橋

- 本線のデータは **`ListOfPosn`（生存だけ）**  
- 密グリッドは説明用・小さな例用  
- データ定義 → テンプレート（`...`）→ `check-expect` → 本体、の順（第1–2章と同じ）  
- 次章で「近傍を数える」「次世代を返す」を、このデータに対して書く  

```bash
racket code/ch03-grid.rkt
```
