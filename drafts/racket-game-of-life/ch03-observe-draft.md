---
title: "第3章　表示して確かめる"
---

計算結果は座標のリストです。並び順が異なっても同じ盤面なので、リスト同士をそのまま比べるとテストが失敗することがあります。全コードの `same-world?` は座標をx、次にyの順にそろえて比較します。

## 3.1 小さな既知の答えを使う

2×2のブロックは変化せず、ブリンカーは2世代で元に戻ります。

```racket
(check-expect (next-generation empty) empty)
(check-expect (same-world? (next-generation block) block) #true)
(check-expect
 (same-world? (next-generation blinker-h) blinker-v) #true)
(check-expect
 (same-world? (next-generation blinker-v) blinker-h) #true)
```

空の盤面・静止する配置・変化する配置を分けて確認すると、誕生と生存の取り違えを見つけやすくなります。失敗したら、全体を眺める前に `next-alive?`、`count-neighbors`、候補の順に小さな入力で調べましょう。

## 3.2 座標を文字の行にする

表示では生を `"#"`、死を `"."` に変えます。`char-at` は1マス、`row-from` は1行、`rows-from` は行のリストを作ります。全コードの `world->rows` がそれらをまとめます。

```racket
(check-expect
 (world->rows blinker-h 0 0 5 5)
 (list "....." "....." ".###." "....." "....."))
(check-expect
 (world->rows (next-generation blinker-h) 0 0 5 5)
 (list "....." "..#.." "..#.." "..#.." "....."))
```

引数の `0 0` は表示範囲の左上、`5 5` は幅と高さです。BSLでは結果が `cons` の連なりとして表示される場合もありますが、同じ行のリストです。この範囲の外にある生セルも、次世代の計算には含まれています。

## 3.3 自分の予想をテストにする

練習：生セルを一つだけ置きます。次世代が空になる理由を説明し、次のテストを追加してください。

```racket
(check-expect (next-generation (list (make-posn 0 0))) empty)
```

次に、自分で小さな配置を作り、紙で1世代を計算してからテストにしてください。観察した結果をそのまま正解として写すのではなく、規則から期待値を決めます。

ここまでで、データを決め、小さな関数をテストし、それらを組み合わせて盤面を更新できました。新しい題材でも「何を入力し、何を返すか」「小さな正解の例は何か」から始めてみましょう。
