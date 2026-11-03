---
title: "第1章　盤面をデータにする"
---

この章では、生きているセルを探す関数を作ります。式やリストの一般説明は[共通の基礎](README.md)を参照し、ここでは盤面に適用します。

## 1.1 何を保存するか

セルの位置は `(make-posn x y)` で表します。`posn` はBSLに用意された座標のデータで、`posn-x` と `posn-y` で成分を取り出せます。右に行くとx、下に行くとyが増えます。座標には負の整数も使えます。

盤面は**重複のない座標のリスト**とします。順序は生死に影響しません。リストにない座標は死です。

```racket
(define blinker-h
  (list (make-posn 1 2) (make-posn 2 2) (make-posn 3 2)))
```

空の盤面は `empty` です。行ごとの0/1の表も作れますが、本編ではこの座標リストだけで進めます。

## 1.2 「ここにいるか」を調べる

先に入力・出力と例を決めます。`member-posn?` は「座標と盤面を受け取り、その座標に生きたセルがあるかを真偽値で返す」関数です。

```racket
(check-expect (member-posn? (make-posn 2 2) blinker-h) #true)
(check-expect (member-posn? (make-posn 0 0) blinker-h) #false)
(check-expect (member-posn? (make-posn 2 2) empty) #false)
```

リストを先頭と残りに分けます。空なら見つかりません。先頭が探す座標なら成功。それ以外は残りを探します。

```racket
;; member-posn?: Posn ListOfPosn -> Boolean
(define (member-posn? cell cells)
  (cond
    [(empty? cells) #false]
    [(equal? cell (first cells)) #true]
    [else (member-posn? cell (rest cells))]))
```

`equal?` は座標の中身を比較します。`rest` でリストが短くなるので、再び自分を呼んでも最後は空になります。これがこの教材で使う再帰の基本です。空か調べてから `first` を使う順序も大切です。

## 1.3 手で追ってから試す

先頭にない座標を探す場合、先頭を一つずつ除いて、最後は `empty` に到達します。実行前に上の3例の枝を指で追い、Runで確認してください。

練習：リストの最後にある `(make-posn 3 2)` を探すテストを追加しましょう。成功するまで何回「残りを探す」枝を通りますか。

次章では、この関数で周囲8マスの生死を調べます。
