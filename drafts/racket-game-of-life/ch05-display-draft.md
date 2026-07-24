---
title: "第5章　描画と対話——盤面を見る"
---

> **この章のゴール**
> 第4章の盤を、目で見て分かる形にする。ASCII とパターンカタログを揃え、発展として **big-bang** に繋ぐ。
> **付属コード**: `code/ch05-display.rkt`（`#lang htdp/bsl`・本線）  
> **発展（任意）**: `code/ch05-display-isl.rkt`（`#lang htdp/isl+`・9×9 升目表示）  
> **Issue**: [#3](https://github.com/bluehive/mypublish-gameoflife/issues/3)

#### 5.1 なぜ「表示」が必要か

`ListOfPosn` のままでは形が見えません。表示は次の役割を持ちます。

- ルール実装が合っているかの**目視チェック**（テストと併用）
- ブリンカーやグライダーの動きを体感する

本線の骨格は **ASCII（文字の升目）** です。画像やアニメは後半の発展です。

#### 5.2 ビューポートと行リスト

表示したい範囲を決めます。この範囲を **ビューポート** と呼びます。

- **ビューポート** … 無限に近い盤のうち、**のぞき窓（カメラのファインダー）で切り取る枠**のこと。枠の外は今は見ない
- 原点 `(origin-x, origin-y)` … のぞき窓の**左上**に対応する盤上の座標
- 幅・高さ … のぞき窓の大きさ（文字数＝マス数）

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

**P5-1 の入出力見本（相互作用ウィンドウ）**

付属コードを Run したあと、次を入力する:

```racket
(world->rows pattern-block 0 0 4 4)
```

**BSL でよく出る表示（`cons` 連鎖）** — これが「リスト」の本体の見え方です:

```racket
(cons "##.."
      (cons "##.."
            (cons "...."
                  (cons "...." empty))))
```

（環境によっては `'()` が `empty` の代わりに出ます。どちらも「空リスト」です。）

**これは何か（ステップ）**

1. `world->rows` の返り値の型は **文字列のリスト**（1要素＝盤の1行）
2. BSL のリストは中身が `empty` か `(cons 先頭 残り)` だけ（第2章）
3. だから 4 行あると、上のように **`cons` が4回ネスト**して見える
4. 人間が書くときの略記が `(list "##.." "##.." "...." "....")` である
5. **中身は同じ**。次はどちらも true になる:

```racket
(equal?
 (world->rows pattern-block 0 0 4 4)
 (list "##.." "##.." "...." "...."))
```

6. DrRacket / BSL の相互作用ウィンドウは、答えを **`list` 表記ではなく `cons` 表記で印字する**ことが多い（言語の表示スタイル）。`(list …)` で返したいと設定しても、学生言語では常に `cons` になる、と思ってよい

升目として頭の中（または紙）で並べると:

```text
##..
##..
....
....
```

左上 2×2 が `#` なら成功です。付属コードのテストも同じ形を一部確認しています。

**9×9 ののぞき窓で静止物（ブロック）を見る**

ビューポートを 9×9 にし、ブロックをだいたい中央（左上を (3,3) にずらす）に置くと、余白付きで盤らしく見えます。

```racket
(define block-9 (place pattern-block 3 3))
(world->rows block-9 0 0 9 9)
```

`cons` 連鎖のまま出るが、中身は次の `(list …)` と同じである:

```racket
(list "........."
      "........."
      "........."
      "...##...."
      "...##...."
      "........."
      "........."
      "........."
      ".........")
```

升目イメージ:

```text
.........
.........
.........
...##....
...##....
.........
.........
.........
.........
```

付属コードでは、この期待値を `check-expect` でも固定しています（`rows-block-9x9`）。  
**本線は行のリスト（`ListOfString`）と BSL** のままにする。  
升目を**改行つきでターミナルに出す**見本は、次の発展（ISL+）を参照。

##### 発展: Intermediate Student with lambda（`#lang htdp/isl+`）で 9×9 を見やすく表示

本線の BSL では、`(world->rows …)` の答えが **`cons` 連鎖**で印字され、盤に見えにくいことがあります（上で説明したとおり正常です）。  
「行ごとに並んだ升目」をその場で見たいとき用に、**任意の発展ファイル**を用意しています。

| 項目 | 本線 | 発展（この節） |
| --- | --- | --- |
| ファイル | `code/ch05-display.rkt` | `code/ch05-display-isl.rkt` |
| 言語 | `#lang htdp/bsl` | `#lang htdp/isl+`（Intermediate Student with lambda） |
| 目的 | 仕様と `check-expect` | 9×9 静止ブロックを **改行付きで表示** |
| 必須か | **必須** | **任意**（採点・本線理解は BSL で足りる） |

- 公式ドキュメント: [Intermediate Student with lambda](https://docs.racket-lang.org/htdp-langs/intermediate-lam.html)
- ISL+ で楽になる点の例: `lambda` / `map` / `build-list` で行を組み立てる、`2htdp/batch-io` の `write-file` で標準出力に升目を出す
- **REPL が必ず `(list …)` 印字になるわけではない**（学生言語の表示スタイルは別問題）。発展の狙いは **升目として読める出力**

実行（**リポジトリ root** から）:

```bash
racket code/ch05-display-isl.rkt
```

成功すると、テストに加え、だいたい次のような 9×9 が標準出力に出ます:

```text
;; --- 9x9 still life (block near center) ---
.........
.........
.........
...##....
...##....
.........
.........
.........
.........
;; --- end demo ---
```

DrRacket で開く場合: ファイル先頭の `#lang htdp/isl+` に合わせ、言語レベルを **Intermediate Student with lambda** にする（メニューと `#lang` を食い違わせない）。

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

**P5-3 の入出力見本**

方針: 「2,2 に置いたグライダーを 4 世代進めた盤」と「最初から 3,3 に置いたグライダー」は同じ（4世代で形が戻り、(1,1) 進むため）。

相互作用ウィンドウでの確認例:

```racket
(define g0 (place pattern-glider 2 2))
(define g4 (step-n g0 4))
(same-world? g4 (place pattern-glider 3 3))
```

期待される返り値:

```racket
true
```

`check-expect` に書くなら（ノートや自分のファイル用）:

```racket
(check-expect
 (same-world? (step-n (place pattern-glider 2 2) 4)
              (place pattern-glider 3 3))
 true)
```

ASCII で目視する場合の見本（ビューポート 10×8、原点 (0,0)）:

- 世代0（`g0` = グライダーを (2,2) に置いた直後）:

```text
..........
..........
...#......
....#.....
..###.....
..........
..........
..........
```

- 4 世代後（`g4`）は、同じ形が右下へ (1,1) ずれた位置（全体として (3,3) 起点）にある。  
  `(world->rows g4 0 0 10 8)` と  
  `(world->rows (place pattern-glider 3 3) 0 0 10 8)`  
  が同じ行リストになれば目視でも一致です。

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

ここまでは **「1枚の盤を文字（ASCII）にして見る」** が本線です。  
「ウィンドウが開き、時間が進むたびに盤が勝手に動く」ところまでは、本章の**必須ではありません**。それが **発展** の `big-bang` です。

**背景（なぜ big-bang という話が出るか）**

1. 第4章までで、盤の更新（`next-generation`）は手に入った
2. 本章の本線は、その盤を `world->rows` で **文字列の升目**にして目視する
3. でも「毎秒自動で世代を進めたい」「キーで止めたい」となると、**時計と画面と入力**をまとめて扱う仕組みが要る
4. Racket の教育用ライブラリでは、その定型が **`big-bang`**（パッケージ `2htdp/universe`）
5. howtocode では、世界（World）を設計する流れを **HTDW（How to Design Worlds）** と呼ぶことがある

**狙い（この節で理解してほしいこと）**

- 本線の到達点: ASCII 表示とパターンが **付属コードで動く**こと
- 発展の位置づけ: `big-bang` は「次に足す部品」であり、**今すぐ全部実装しなくてよい**
- 対応関係だけ先に頭に入れる: 盤 = 世界の状態、世代更新 = tick、見た目 = draw

**`big-bang` の役割（ステップ）**

1. **世界の状態（WorldState）** を1つ決める（ライフなら今の `ListOfPosn`）
2. **時間が進んだとき** どう状態を変えるか（`on-tick`）
3. **画面に何を出すか**（`to-draw`）
4. 必要なら **キー入力**でどう変えるか（`on-key`）
5. `big-bang` が「初期状態」を受け取り、上の部品を繰り返し呼んでウィンドウを動かす

**コラム: Scratch でやっていたこと ↔ `big-bang`**

中学の Scratch（や似たブロック）で触れた「イベント」は、テキストではだいたい次の対応になります。**新しい魔法ではなく、同じ考え方の別表記**です。

- **ずっと（または「ずっと繰り返す」）＋ 〜秒待つ**  
  → 時間が進むたびに何かする … `big-bang` の **`on-tick`**  
  （ライフなら「1ティック＝1世代」で `next-generation`）
- **（スプライトを）表示する／コスチュームを変える**  
  → 今の状態を画面に出す … **`to-draw`**  
  （ライフなら盤を画像や升目にする `render-world`）
- **スペースキーが押されたとき** など  
  → キー入力で状態を変える … **`on-key`**  
  （一時停止、1世代だけ進める、など）
- **旗が押されたとき** に初期配置から始める  
  → 初期の世界を渡して起動する … **`(big-bang 初期状態 …)`** の第1引数

だから 5.6 は「ゼロからイベント駆動を学ぶ」節ではなく、**既に知っている操作を Racket の定型に載せ替える見取り図**だと思ってください。実装は発展で十分です。

ライフへの対応イメージ:

- **WorldState** … 今の `ListOfPosn`（または世代番号も持つ構造体）
- **on-tick** … `(next-generation world)` で自動的に世代を進める
- **to-draw** … `world->rows` の結果を画像に載せる、または `2htdp/image` で升目を描く
- **on-key** … スペースで一時停止、`n` で1世代、など

ドメイン分析（紙に書く）:

1. 何が一定か（セルサイズ、画面幅）
2. 何が変わるか（生存リスト、世代番号）
3. どの big-bang 句が要るか（tick / draw / key）

**コードのどこに `big-bang` と書くか**

- **本章の必須付属コード `code/ch05-display.rkt` には、`big-bang` は出てこない**（ASCII と `check-expect` が本線）
- `big-bang` は下の **発展用スケッチ**の `(big-bang w0 …)` の1行だけが「その名前が出る場所」
- 実際に動かすには `#lang` や言語レベル、`(require 2htdp/universe)` などの準備が別途必要（Intermediate や teachpack の話になることがある）

公式・参考 URL:

- [Worlds and the Universe（`2htdp/universe` / `big-bang`）](https://docs.racket-lang.org/teachpack/2htdpuniverse.html)
- [2htdp/image](https://docs.racket-lang.org/teachpack/2htdpimage.html)
- howtocode: [howtocode.pages.dev](https://howtocode.pages.dev/)（HTDW / デザインの流れの参考）

main の骨（イメージ。**本章の必須コードではない**）:

```racket
;; 発展用のスケッチ（code/ch05-display.rkt には含めない）
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

**`main` / `render-world` とシグネチャの対応（リスト）**

- **`main`**
  - 署名（コメント）: `ListOfPosn -> ListOfPosn`
  - 引数 `w0` … 最初の盤（例: `pattern-glider`）
  - 本体の `(big-bang w0 …)` … 初期状態を `w0` にして世界を起動する
  - `[on-tick next-generation]` … 時計が進むたびに `next-generation` を呼ぶ（状態の型は `ListOfPosn` のまま）
  - `[to-draw render-world]` … 今の状態を画面用の値に変換する関数を指定
  - 返り値 … ウィンドウが閉じたあとの最終状態（学習段階では「起動の入口」と覚えればよい）
- **`render-world`**
  - 署名（コメント）: `ListOfPosn -> Image`
  - 引数 `w` … 今の生存リスト
  - 返り値 … 画面に出す画像（本線の `world->rows` は `ListOfString` なので、画像にする変換が別途必要）
  - `(... w)` … まだ本体を書いていないプレースホルダ（第2章の `...`）

**骨格段階の必須到達点（ステップバイステップ）**

本章を「できた」とみなすためのチェックリストです。上から順に確認してください。

1. **付属コードが Run できる**  
   リポジトリ root で `racket code/ch05-display.rkt`（または DrRacket で同ファイルを開いて Run）
2. **`world->rows` とパターンが動く**  
   相互作用ウィンドウで  
   `(world->rows pattern-block 0 0 4 4)`  
   のように呼び、`"#"` と `"."` の行が返ることを目で見る（P5-1）
3. **第4章相当の仕様テストが通る**  
   付属コード末尾の `check-expect` がすべて成功する（次項の「緑」）
4. **big-bang は「次の部品」と位置づけられる**  
   上のスケッチの対応（tick = 世代、draw = 描画）が説明できれば十分。実装は発展

**「`check-expect` が緑」とは何か（ステップ）**

1. `check-expect` は「左辺の計算結果」と「右辺の期待値」が**等しいか**を調べるテスト
2. ファイルを **Run** すると、Racket / DrRacket がすべての `check-expect` を実行する
3. **全部成功**したとき、DrRacket ではテスト結果が **緑色**の表示になることが多い（「All … tests passed」など）
4. **1つでも失敗**すると、赤や失敗メッセージになり、どの行が違うかが分かる
5. つまり「緑」＝ **書いた仕様どおりに関数が動いている**という合図（コードの文字が緑になるわけではない）
6. CLI でも同様で、`racket code/ch05-display.rkt` の最後に成功メッセージが出れば同じ意味

**GIF 化・発展課題とは（この本での扱い）**

- **発展課題** … 本線（ASCII + テスト）の**あと**に、余裕があれば挑戦する課題。必須ではない
- **GIF 化** … 各世代の盤を画像ファイルとして連番で保存し、外部ツールでつないで **動く GIF アニメ**にすること
- この本の第5章本線では **GIF 化は行わない**（やり方の方針だけ触れる）
- `big-bang` も同様に **本線の必須実装ではない**（上のスケッチと URL で「次に何があるか」が分かればよい）

#### 5.7 まとめ

**この章で出てきた主な名前と役割**

- `world->rows` — 生存リストを `"#"` / `"."` の行のリストに変換（表示の核）
- `char-at` / `row-from` / `rows-from` — 1マス・1行・全体を組み立てる補助
- `next-generation` / `step-n` / `same-world?` / `place` — 第4章と同型（世代と比較）
- `pattern-block` / `pattern-blinker` / `pattern-glider` / `pattern-pulsar` など — 表示・テスト用パターン
- `parse-life106-line` — ファイル1行分の簡易パーサ
- `main` / `render-world`（発展） — big-bang 用の入口と描画の骨
- `code/ch05-display-isl.rkt`（発展）— `rows->text` / `show-world` で 9×9 を改行表示（`#lang htdp/isl+`）

- 表示はビューポート ＋ `"#"` / `"."` の行リスト
- パターン名は第4章テストと共有する
- **Template + check-expect（第4章）** と **目視（本章）** を両方使う
- **big-bang** は自動再生・対話の発展（howtocode HTDW）。必須付属コードには含めない

**ASCII でライフを「見る・進める」確認手順（本線）**

1. **コードの場所**  
   - 付属ファイル: **`code/ch05-display.rkt`**（リポジトリ root 基準）  
   - 盤 → 文字の升目: 同ファイルの **`world->rows`**  
   - 世代を進める: 同ファイル内の **`next-generation`** / **`step-n`**（第4章と同型）  
   - 有名形: **`pattern-block`** / **`pattern-blinker`** / **`pattern-glider`** など  
   - 自動テスト: ファイル末尾の **`check-expect`** 群
2. **まずテストで仕様を確認する（いちばん手早い）**

```bash
# リポジトリ root から（本線 BSL）
racket code/ch05-display.rkt

# 発展: 9×9 静止盤を升目表示（ISL+・任意）
racket code/ch05-display-isl.rkt
```

   すべて通れば、表示用変換とパターンの一部仕様は正しい。

3. **ASCII を目で見る（相互作用ウィンドウ / REPL）**  
   DrRacket で `code/ch05-display.rkt` を Run したあと、下の相互作用欄で例えば:

```racket
(world->rows pattern-block 0 0 4 4)
(world->rows block-9 0 0 9 9)
(world->rows pattern-glider 0 0 12 8)
(world->rows (next-generation pattern-blinker) 0 0 8 5)
(world->rows (step-n pattern-glider 4) 0 0 12 8)
```

   返り値は文字列のリストです。各文字列が1行の `"#"` / `"."` です。  
   **印字が `cons` だらけでも正常**です。本の `(list …)` と同じ値か `equal?` で確かめられる（§5.2）。

4. **「動いている」ように見る本線のやり方**  
   - ウィンドウアニメは big-bang（発展）  
   - 本線では **世代0 → `next-generation` → また `world->rows`** と手で進めて見比べる  
   - 例: ブリンカーなら 0 世代と 1 世代の ASCII が横↔縦に切り替わる

5. **big-bang で自動再生したいとき**  
   - 5.6 のスケッチを別ファイルに書き、`2htdp/universe` を用意する（発展・任意）
