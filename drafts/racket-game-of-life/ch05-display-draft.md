---
title: "第5章　描画と対話——盤面を見る"
---

> **この章のゴール**  
> 第4章の盤を、目で見て分かる形にする。ASCII とパターンカタログを揃え、発展として **big-bang** に繋ぐ。  
> **付属コード**: `code/ch05-display.rkt`（`#lang htdp/bsl`）  
> **Issue**: [#3](https://github.com/bluehive/mypublish-gameoflife/issues/3)

#### 5.1 なぜ「表示」が必要か

`ListOfPosn` のままでは形が見えません。表示は次の役割を持ちます。

- ルール実装が合っているかの**目視チェック**（テストと併用）  
- ブリンカーやグライダーの動きを体感する  

本線の骨格は **ASCII（文字の升目）** です。画像やアニメは後半の発展です。

#### 5.2 ビューポートと行リスト

表示したい範囲を決めます。

- 原点 `(origin-x, origin-y)` … 画面左上に対応する座標  
- 幅・高さ … 文字数（マス数）  

生存していれば `"#"`、いなければ `"."` です。

```racket
;; 完成形は code/ch05-display.rkt の world->rows
;; world->rows: ListOfPosn Number Number Number Number -> ListOfString
;; スタブ: (define (world->rows cells ox oy w h) empty)
```

例（グライダーを左上付近に置いたイメージ）:

```text
.#..........
..#.........
###.........
............
```

BSL には `begin` が無いので、付属コードの自動テストは **純粋な `world->rows`** を中心にします。相互作用ウィンドウでは、返ってきた文字列のリストを目で確認してください。

**P5-1** `pattern-block` について `world->rows` を呼び、2×2 の `#` があることを確認せよ。

#### 5.3 世代を進めて見る

第4章の `next-generation` / `step-n` と組み合わせます。

```racket
(define w0 pattern-glider)
(define w1 (next-generation w0))
(world->rows w1 0 0 16 10)

(define w4 (step-n pattern-glider 4))
(check-expect (same-world? w4 (place pattern-glider 1 1)) true)
```

- 1 世代ずつ: `next-generation`  
- n 世代まとめて: `step-n`  
- 連続表示のアニメは、発展の big-bang（5.6）向き  

**P5-2** ブリンカーを 2 世代進めると元の形に戻ることを `same-world?` で確認せよ。

#### 5.4 有名パターン（カタログ）

第4章のパターンテストと**同じ識別子**を使います。カタログは「見た目の名前」と「コードの定数」を対応させる辞書です。

- **ブロック** `pattern-block` — 静止物。何世代でも同じ  
- **ブリンカー** `pattern-blinker` — 振動子。周期 2  
- **ビーコン** `pattern-beacon` — 振動子。周期 2  
- **トード** `pattern-toad` — 振動子。周期 2  
- **グライダー** `pattern-glider` — 宇宙船。4 世代で斜めに 1 マス  
- **パルサー** `pattern-pulsar` — 振動子。周期 3（48 セルの位相）  

平行移動:

```racket
;; place: ListOfPosn Number Number -> ListOfPosn
;; スタブ: (define (place cells dx dy) (...))
;; 完成形は付属コード。各 posn に dx, dy を足す
```

```racket
(place pattern-glider 5 3)
```

**P5-3** グライダーを `(place … 2 2)` してから 4 世代進め、さらに (1,1) ずれていることを `check-expect` せよ。  
**P5-4** `(step-n pattern-pulsar 3)` が元と同じになることを確認せよ。

#### 5.5 ファイルから読む（骨格）

簡易形式: 1 行に `x y`。`#` で始まる行はコメント。

```text
# my block
0 0
0 1
1 0
1 1
```

付属コードの `parse-life106-line` が1行分のパーサです。ファイル全体の読み込みは、環境によって `file->lines` などが必要になるため、発展課題でも構いません。

#### 5.6 発展: big-bang で自動再生・描画

howtocode の **HTDW（How to Design Worlds）** / `big-bang` は、「時間が進む」「画面に描く」「キーで操作する」アプリの定型です。

ライフへの対応イメージ:

- **WorldState** … 今の `ListOfPosn`（または世代番号も持つ構造体）  
- **on-tick** … `(next-generation world)` で自動的に世代を進める  
- **to-draw** … `world->rows` の結果を画像に載せる、または `2htdp/image` で升目を描く  
- **on-key** … スペースで一時停止、`n` で1世代、など  

ドメイン分析（紙に書く）:

1. 何が一定か（セルサイズ、画面幅）  
2. 何が変わるか（生存リスト、世代番号）  
3. どの big-bang 句が要るか（tick / draw / key）  

main の骨（イメージ。画像を使う場合は Intermediate や teachpack の準備が必要なことがある）:

```racket
;; 発展用のスケッチ（本章の必須コードではない）
;; (require 2htdp/image)
;; (require 2htdp/universe)

;; main: ListOfPosn -> ListOfPosn
(define (main w0)
  (big-bang w0
    [on-tick next-generation]
    [to-draw render-world]))

;; render-world: ListOfPosn -> Image
(define (render-world w)
  (... w))  ; world->rows や place-image で描画
```

骨格段階の必須到達点は次です。

- `world->rows` とパターンが付属コードで動く  
- 第4章の `check-expect` が緑  
- big-bang は「次に足す部品」として位置づけを理解する  

GIF 化は、各世代の画像を連番で出し、外部ツールでつなぐ発展課題です。

#### 5.7 まとめ

**この章で出てきた主な名前と役割**

- `world->rows` — 生存リストを `"#"` / `"."` の行のリストに変換（表示の核）  
- `char-at` / `row-from` / `rows-from` — 1マス・1行・全体を組み立てる補助  
- `next-generation` / `step-n` / `same-world?` / `place` — 第4章と同型（世代と比較）  
- `pattern-block` / `pattern-blinker` / `pattern-glider` / `pattern-pulsar` など — 表示・テスト用パターン  
- `parse-life106-line` — ファイル1行分の簡易パーサ  
- `main` / `render-world`（発展） — big-bang 用の入口と描画の骨  

- 表示はビューポート ＋ `"#"` / `"."` の行リスト  
- パターン名は第4章テストと共有する  
- **Template + check-expect（第4章）** と **目視（本章）** を両方使う  
- **big-bang** は自動再生・対話の発展（howtocode HTDW）  

```bash
# リポジトリ root から
racket code/ch05-display.rkt
```
