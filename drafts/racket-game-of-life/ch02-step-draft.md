---
title: "第2章　規則から次の世代を作る"
---

この章の仕事は、盤面を受け取って新しい盤面を返す `next-generation` を作ることです。一度に全部を書かず、セルの判定・近傍の集計・候補の選別に分けます。[全コード](life-draft.rkt)で同じ名前の定義をたどってください。

## 2.1 1セルの規則を試す

```racket
;; next-alive?: Boolean Number -> Boolean
;; n は0〜8の整数
(define (next-alive? alive-now? n)
  (cond
    [alive-now? (or (= n 2) (= n 3))]
    [else (= n 3)]))

(check-expect (next-alive? #true 2) #true)
(check-expect (next-alive? #false 2) #false)
(check-expect (next-alive? #false 3) #true)
(check-expect (next-alive? #true 4) #false)
```

同じ「近傍2」でも、現在の生死で結果が違います。入力を二つに分ける理由です。練習：近傍0、3、8の生セルの答えを予想し、テストを追加してください。

## 2.2 周囲だけを数える

`shift-cell` は座標をずらし、`cell-neighbors` は8方向の座標をリストにします。中央自身は含めません。

```text
(-1,-1) (0,-1) (1,-1)
(-1, 0)   中央   (1, 0)
(-1, 1) (0, 1) (1, 1)
```

近傍のリストを先頭と残りに分け、生きているときだけ1を足します。

```racket
(define (count-alive-in neighbors live)
  (cond
    [(empty? neighbors) 0]
    [(member-posn? (first neighbors) live)
     (+ 1 (count-alive-in (rest neighbors) live))]
    [else (count-alive-in (rest neighbors) live)]))

(define (count-neighbors cell live)
  (count-alive-in (cell-neighbors cell) live))

(check-expect (count-neighbors (make-posn 2 2) blinker-h) 2)
(check-expect (count-neighbors (make-posn 2 1) blinker-h) 3)
```

第1章は「見つかるか」、ここは「何個あるか」ですが、空と残りに分ける考え方は共通です。

## 2.3 死んでいるセルも候補に入れる

生きているセルだけを調べると、新しく生まれるセルを見逃します。調べる候補は「現在の生セルと、その周囲8マス」です。それ以外は生きた近傍が0個なので誕生しません。

全コードでは `add-unique` が重複を避けて座標を加え、`union-list` が二つのリストをまとめます。`fold-add-neighbors` は生セルを一つずつ読み、集めた候補 `acc` にその近傍を足していきます。`acc` は途中結果を受け渡す引数です。最初に生セル自身を入れ、`candidate-cells` で候補がそろいます。

候補を選別する本体は次です。

```racket
(define (filter-next candidates live)
  (cond
    [(empty? candidates) empty]
    [(next-alive? (member-posn? (first candidates) live)
                  (count-neighbors (first candidates) live))
     (cons (first candidates)
           (filter-next (rest candidates) live))]
    [else (filter-next (rest candidates) live)]))

(define (next-generation cells)
  (filter-next (candidate-cells cells) cells))
```

`cons` は残りの結果の先頭にセルを一つ加えます。再帰で変わるのは候補の残りだけで、判定に使う `live` は毎回同じです。これで、更新途中のセルを参照してしまう誤りを避けられます。

練習：候補を生セルだけにしたら、ブリンカーのどの誕生を見逃すでしょうか。紙で予想してから、全コードの `candidate-cells` を一時的に変更してテストの失敗を確認し、元に戻してください。
