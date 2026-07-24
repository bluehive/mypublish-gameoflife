---
title: "第4章　ライフゲームのルールとセルオートマトン"
---

> **この章のゴール**
> B3/S23 を関数にし、`count-neighbors` と `next-generation` で盤を進める。
> 有名パターンを **テンプレート＋`check-expect`** で仕様として固定する。
> **付属コード**: `code/ch04-life-rules.rkt`（`#lang htdp/bsl`）
> （リポジトリ root から `racket code/ch04-life-rules.rkt`）
> **Issue**: [#3](https://github.com/bluehive/mypublish-gameoflife/issues/3) / [#2](https://github.com/bluehive/mypublish-gameoflife/issues/2)

#### 4.1 ルール（B3/S23）と1セルの次状態

**セル・オートマトンとは（ステップ）**

1. **セル** … 升目の1マス。この本では「生」か「死」の2状態だけ持つ
2. **盤（グリッド）** … セルが格子状に並んだ世界。第3章では生存だけを `ListOfPosn` で表した
3. **近傍** … あるセルが「周りを見る」ときに数える、隣のマス。ライフでは **周囲8マス**（斜め含む）
4. **ルール** … 「今の自分の生死」と「近傍の生存数」から、**次の一瞬の自分**を決める約束
5. **いっせい更新** … 全員が同じ「今」の盤だけを見て、同時に次の盤へ進む（1人が先に変わって影響を与えない）
6. **世代** … その「いっせい更新」を1回行うこと。0世代目 → 1世代目 → 2世代目 …
7. ライフゲームは、上の仕組みを持つ **セル・オートマトン** の一例である（ルール名は次の **B3/S23**）

ライフゲームでは、各マスが「生」か「死」かを持ち、**全員がいっせいに**次の状態へ進みます。見るのは自分と、周囲 **8 マス**の生存数だけです（序章の図を思い出してください）。

**ルール**の名前 **B3/S23** の意味:

- **B3（Birth 3）**: 死んでいるマスは、近傍がちょうど 3 なら次は生（誕生）
- **S23（Survive 2 or 3）**: 生きているマスは、近傍が 2 または 3 なら次も生（生存）
- それ以外は次は死（過疎または過密）

本章ではライフの約束をすべて **「ルール」** と呼びます（B3/S23 も「ルールの名前」です）。

**B3 / S23 をすべてのパターンで見る（ASCII）**

中央のマスを `C`、生きている近傍を `#`、死んでいる近傍を `.` とします。中央以外の8マスが「近傍」です。

**S23（今、中央が生 `#` のとき）** — 近傍数 `n` ごとに次の中央:

```text
n=0  過疎で死          n=1  過疎で死          n=2  生存（S）
 . . .                  . . .                  . # .
 . C .  →  .            . C .  →  .            . C .  →  #
 . . .                  # . .                  . # .

n=3  生存（S）          n=4  過密で死          … n=8 も過密で死
 # # .                  # # #                  # # #
 . C .  →  #            . C .  →  .            # C #  →  .
 . . #                  # . .                  # # #
```

**B3（今、中央が死 `.` のとき）** — 近傍数 `n` ごとに次の中央:

```text
n=0..2  生まれない       n=3  誕生（B）         n=4..8  生まれない
 . . .                   # # .                  # # #
 . C .  →  .             . C .  →  #            # C #  →  .
 . . .                   . . #                  # # #
```

まとめ（1セルだけ見る表）:

- 今 **生** かつ `n` が 2 または 3 → 次も **生**（S23）
- 今 **死** かつ `n` がちょうど 3 → 次は **生**（B3）
- それ以外 → 次は **死**


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

デザインレシピどおり、まず関数の約束と例を書きます。

**関数の意味とシグネチャの対応（コードの外で）**

- **`survives?`**
  - 意味: 近傍数が **生存**条件（S23）を満たすか
  - シグネチャ: `Number -> Boolean`
  - 引数: `neighbors` = 近傍の生存数
  - 返り値: 2 または 3 なら `true`
- **`births?`**
  - 意味: 近傍数が **誕生**条件（B3）を満たすか
  - シグネチャ: `Number -> Boolean`
  - 引数: `neighbors` = 近傍の生存数
  - 返り値: ちょうど 3 なら `true`
- **`next-alive?`**
  - 意味: 今の生死と近傍数から、**次も生えるか**
  - シグネチャ: `Boolean Number -> Boolean`
  - 引数: 第1=`currently-alive?`（今生？）、第2=`neighbors`
  - 返り値: 次が生なら `true`
  - 振り分け: 今生なら `survives?`、今死なら `births?`（ルール全体の入口）

ここでは引数が `Number` / `Boolean` だけなので、BSL の **`(: …)` シグネチャ**が使える（第2・3章で触れた「`Posn` は `(: …)` に書けない」問題が起きない）。


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

**生存セルの振り返り（第3章）**

1. ライフの本線では、**生きているマスの座標だけ**をリストに載せる（**スパース**表現）
2. 死んでいるマスはリストに**書かない**。「リストに無い＝死」
3. 空の盤は `empty`（誰も生きていない）
4. 例: 2×2 のブロックは生存4点だけ

```text
  0 1 2 3
0 . . . .
1 . # # .
2 . # # .
3 . . . .
```

5. 第4章では、このリストを「今の世代の盤」として受け取り、**次の世代のリスト**を返す

```racket
;; ブロック（2×2 の静止物）
(define block
  (list (make-posn 1 1) (make-posn 1 2)
        (make-posn 2 1) (make-posn 2 2)))
```

**なぜ近傍は 8 つなのか（ステップ＋ASCII）**

1. ライフのルールは「自分の周囲のマス」を見る。自分自身は近傍に**含めない**
2. 二次元の格子で「隣」と言えば、上下左右の **4** と、斜めの **4** で合計 **8**
3. これを **ムーア近傍**（Moore neighborhood）と呼ぶこともある（名前は覚えなくてよい）
4. 中央 `C` から見た8方向:

```text
  NW  N  NE        (-1,-1) (0,-1) (1,-1)
   W  C   E   →    (-1, 0)   C    (1, 0)
  SW  S  SE        (-1, 1) (0, 1) (1, 1)
```

5. コードでは `dx` / `dy` を -1,0,1 で回し、**(0,0) だけ除く**と、ちょうどこの8点が得られる
6. だから `cell-neighbors` の返り値の長さは常に **8**（付属コードの `check-expect` でも確認している）


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
**`shift-cell` / `cell-neighbors` の意味と署名（コードの外で）**

- **`shift-cell`**
  - 意味: ある座標を、横に `dx`・縦に `dy` ずらした**新しい** `posn` を作る
  - 署名（コメント）: `Posn Number Number -> Posn`
  - 引数: `cell` = 元の座標、`dx` / `dy` = ずらし量
  - 返り値: ずらした座標（元の `cell` は書き換えない）
- **`cell-neighbors`**
  - 意味: ある座標の **8 近傍**を、`Posn` のリストで返す
  - 署名（コメント）: `Posn -> ListOfPosn`
  - 引数: `cell` = 中心
  - 返り値: 長さ 8 のリスト（上図の NW〜SE）

なぜ署名が **コメント**か: 引数に `Posn` が出るため、BSL の `(: …)` には書けない（第3章「`Posn` が使えない件」と同じ）。ノートと `.rkt` では `;; 名前: … -> …` と書く。


「リストの中にいるか」と「近傍のうち何個が生きているか」も、第2章のリストテンプレートです。

**`member-posn?` / `count-neighbors` とコメント署名（再掲）**

1. シグネチャ（署名）は「引数の型と個数 → 返り値の型」という**約束**
2. `Number` / `Boolean` だけなら `(: name (… -> …))` と**コードで**書ける（4.1 の `survives?` など）
3. `Posn` や `ListOfPosn` を含む約束は BSL の `(: …)` では書けないので、**コメント**にする
4. コメントでも十分「人間向けの仕様」になる。実行時の型検査は `check-expect` が支える

- **`member-posn?`** … 座標が生存リストに**あるか**
  - 署名（コメント）: `Posn ListOfPosn -> Boolean`
  - 引数: `cell`, `cells` / 返り値: いれば `true`
- **`count-neighbors`** … あるマスの**近傍生存数**
  - 署名（コメント）: `Posn ListOfPosn -> Number`
  - 引数: `cell`=中心, `live`=今の生存リスト / 返り値: 0〜8 の数
- **`count-alive-in`** … 座標リストのうち、生存に含まれる**個数**
  - 署名（コメント）: `ListOfPosn ListOfPosn -> Number`
  - 引数: `neighbors`, `live` / 返り値: 個数

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

**`count-alive-in` をもう少し詳しく**

1. **名前から推測する**
   - `count` … 数える
   - `alive` … 生きているもの
   - `in` … 「〜の中で」
   - まとめると「（与えられた座標の）リストのうち、生きている個数を数える」
2. **引数の役割**
   - 第1引数 `neighbors` … 調べたい座標のリスト（例: 8近傍）
   - 第2引数 `live` … 今生きている座標のリスト（盤）
3. **本体の方針**（リストのテンプレート）
   - `neighbors` が空 → `0`
   - 先頭が `live` にいる → `1 +` 残りを数える
   - 先頭がいない → 残りだけ数える（+0）
4. **`count-neighbors` との関係**
   - `count-neighbors` は「中心の8近傍を作り、そのリストを `count-alive-in` に渡す」薄い包み
5. **付属コードの場所**
   - パス: **`code/ch04-life-rules.rkt`**（リポジトリ root 基準）
   - 実行: `racket code/ch04-life-rules.rkt`
   - 関数定義は同ファイル内の `count-alive-in` / `count-neighbors` を参照

**P4-3** `block` の `(make-posn 1 1)` の近傍数を手計算し、コードと照合せよ（期待: 3）。

#### 4.3 次世代 `next-generation`（テンプレート駆動）

無限に広い盤を全部調べる必要はありません。次に生まれうるマスは、**今生きているマスの隣**にしかありません。

**手順（ステップバイステップ）**

1. **今の盤**を `cells`（生存の `ListOfPosn`）とする
2. **候補**を集める: 「今生きているマス」と「その8近傍」を、重複なく1本のリストにする
   → これが `candidate-cells` の仕事
3. 候補の**各マス**について:
   - 今生きているか？ → `member-posn?`
   - 近傍生存数は？ → `count-neighbors`
   - 次も生えるか？ → `next-alive?`
4. 次も生えるマスだけを新しいリストに残す
   → これが `filter-next` の仕事
5. そのリストが **次世代**の盤。`next-generation` は 2→4 をまとめた入口

**`candidate-cells` と `filter-next` の役割（ステップ）**

- **`candidate-cells`**
  1. 入力: 今の生存リスト `live`
  2. やること: `live` の各セルについて8近傍を足し、`live` 自身も候補に含める
  3. なぜ必要か: 誕生は「今死んでいるが隣に3生」なので、**生存の隣**まで見ないと取りこぼす
  4. 出力: 「次世代で生死を判定すべき座標」のリスト（重複なし）
- **`filter-next`**
  1. 入力: 候補リストと、今の生存リスト
  2. やること: 候補を先頭から見て、`next-alive?` が true なら残す
  3. BSL に `filter` が無いので、**構造的再帰**で同じことを自分で書く
  4. 出力: 次世代の生存リスト
- **`next-generation`**
  1. `(filter-next (candidate-cells cells) cells)` の一行にまとめた入口
  2. 呼び出し側はこの名前だけ覚えればよい

BSL では `filter` / `local` が使えないので、付属コード（`code/ch04-life-rules.rkt`）では `candidate-cells` と `filter-next` を**構造的再帰**で書いています。

```racket
;; 完成形のイメージ（詳細は code/ch04-life-rules.rkt）
;; next-generation: ListOfPosn -> ListOfPosn
(define (next-generation cells)
  (filter-next (candidate-cells cells) cells))
```

**スタブは何のためか（ステップ）**

1. デザインレシピでは、本体を書く前に **名前・引数・返り値の形**だけ先に固定することがある
2. スタブは「まだ正しい計算はしないが、**呼び出せる**」仮の定義（例: 常に `empty` を返す）
3. 目的:
   - 先に `check-expect` を書いて Run し、「まだ赤（失敗）」な状態を共有できる
   - 周り（`step-n` やテスト）から **同じ名前で**呼べる
4. 本体ができたら、スタブを本物の式で**上書き**する（付属の完成コードではスタブはコメントに残すだけ）
5. 下の `(... cells)` は「ここに本物を書く」印（第2章のテンプレート変数）

```racket
;; next-generation: ListOfPosn -> ListOfPosn
(define (next-generation cells)
  (... cells))
```

**P4-4** 空リストを `next-generation` に渡すとどうなるか。
**P4-5** 1 セルだけの世界は何世代で消えるか。

#### 4.4 境界（固定とトーラス）

**固定境界とトーラス（ステップ＋ASCII）**

1. **無限平面（イメージ）** … 座標はどこまでも続く。スパース表現はこれに近い
2. **固定境界** … 「盤の外」はマスが無い。外の座標は生存リストに現れないので、近傍として**数えられない**（自然に固定端）
3. **トーラス** … 左右がつながり、上下もつながる円筒をさらに輪にした形。端の隣が反対側になる
4. トーラスでは座標を幅・高さで **`modulo`（余り）** して折り返す（付属の `wrap-cell`）

固定境界（枠の外は存在しない。`#` の右隣は「いない」）:

```text
+---+---+---+---+
| . | . | . | . |
| . | # | # | . |   ← 右端の外は数えない
| . | # | # | . |
| . | . | . | . |
+---+---+---+---+
```

トーラス（左右がつながるイメージ。幅4のとき x=0 の左隣は x=3）:

```text
  … 3 | 0 1 2 3 | 0 …
      | . # . # |      ← 左端と右端が隣同士
      | . . . . |
```

5. 付属コードの `next-generation/torus` が周期境界版です
6. グライダーを長く観察するときは、**固定＋広い座標**の方が「端で折り返されたせい」と混同しにくく、分かりやすいことが多いです

#### 4.5 パターンテスト = テンプレート ＋ `check-expect`

第2章の「例を仕様にする」を、ライフの有名形に適用します。

- **静止物（ブロック）**: 何世代進めても `same-world?` が true
- **振動子（ブリンカー）**: 2 世代で戻る
- **宇宙船（グライダー）**: 4 世代で形が戻り、位置が (1,1) ずれる

**パターンを目で見る（ASCII）**

`#` = 生、`.` = 死。付属コードの定数（`block` / `blinker-h` / `glider`）と同じ形です。

**ブロック（静止物）** — 2×2。何世代進めても同じ:

```text
  1 2
1 # #     1世代後も →  # #
2 # #                  # #
```

**ブリンカー（振動子・周期2）** — 横3マス ↔ 縦3マスを行き来する:

```text
世代0（横 blinker-h）     世代1（縦 blinker-v）     世代2（また横）
  1 2 3                     1 2 3                     1 2 3
1 . # .                   1 . . .                   1 . # .
2 . # .                   2 # # #                   2 . # .
3 . # .                   3 . . .                   3 . # .
```

**グライダー（宇宙船・周期4）** — 4世代で形が戻り、全体が右下へ (1,1) ずれる:

```text
世代0                      世代4（同じ形が (1,1) 移動）
  0 1 2                      1 2 3
0 . # .                    1 . # .
1 . . #                    2 . . #
2 # # #                    3 # # #
```

（途中の世代1〜3は形が少しずつ変わる。テストでは「4世代後＝元を (1,1) ずらしたもの」だけを確認する。）

```racket
(check-expect (same-world? (next-generation block) block) true)
(check-expect (same-world? (step-n blinker-h 2) blinker-h) true)
(check-expect (same-world? (step-n glider 4) (place glider 1 1)) true)
```

**上記テストコードの読み方（ステップ）**

1. **`check-expect`** … 「左辺の結果」と「右辺の期待値」が等しければ成功（第1–2章）
2. **`block` / `blinker-h` / `glider`** … 付属コード（`code/ch04-life-rules.rkt`）で定義した**パターン定数**（生存座標のリスト）
   - `block` = 上図の 2×2 静止物
   - `blinker-h` = 上図の横向きブリンカー
   - `glider` = 上図のグライダー（世代0）
3. **`next-generation`** … 盤を **1 世代**だけ進める関数（4.3）
4. **`step-n`** … 盤を **n 世代**進める関数。`(step-n cells n)` は `next-generation` を n 回繰り返したのと同じ
   - 例: `(step-n blinker-h 2)` = ブリンカーを2世代進める → 周期2なので元の横形に戻るはず
   - 例: `(step-n glider 4)` = グライダーを4世代進める → 形は同じで位置だけずれるはず
5. **`place`** … 盤上のすべての生存セルを、横に `dx`・縦に `dy` **平行移動**した新しいリストを返す
   - 例: `(place glider 1 1)` = グライダー全体を右へ1・下へ1
   - グライダーのテストは「4世代後」と「最初の形を (1,1) ずらしたもの」を比べている
6. **`same-world?`** … 2つの生存リストが、**順序を無視して同じ座標集合か**を調べる（下で詳しく）
7. 3本の意味を一文で:
   - 1本目: ブロックを1世代進めても、まだ同じブロック
   - 2本目: ブリンカーを2世代進めると、元の横形に戻る
   - 3本目: グライダーを4世代進めると、元の形が (1,1) だけずれた位置にある

**`sort-cells` / `same-world?` は何と比較するか**

- リストの**要素の並び**が違うと、`equal?` では「違う盤」と判定されてしまう
- 例: `(list A B)` と `(list B A)` は同じ生存集合でも `equal?` は false
- そこで座標を決まった順に並べ直すのが `sort-cells`、並べた結果を `equal?` するのが `same-world?`
- **比較対象**: 「次世代の盤」と「期待する盤」（ブロックが不変、ブリンカーが2世代で戻る、など）
- 用途: **`check-expect` 用**（本線のルール計算そのものではない）

これが「テンプレートで書いた関数が、見た目のパターンと一致している」ことの機械的な保証です。付属コードにはビーコンやトーラス上のブリンカーなども載っています。

**ビーコン（beacon）とは（ステップ＋ASCII）**

1. **振動子**の一種。何世代かで形が変わり、また元に戻る
2. ビーコンの**周期は 2**: 世代0 → 世代1（別形）→ 世代2（元に戻る）
3. 典型形は、2×2 のブロックが斜めに2つ、**角で1マス分すき間**を空けて置いた形
4. 世代が進むと、すき間付近の2マスが交互に点滅するように見える

世代0（2つの 2×2 が離れている）:

```text
  1 2 3 4
1 # # . .
2 # # . .
3 . . # #
4 . . # #
```

世代1（角の2マスが消え、すき間が広がったように見える）:

```text
  1 2 3 4
1 # # . .
2 # . . .
3 . . . #
4 . . # #
```

5. 付属コードの定数名は `beacon`（`code/ch04-life-rules.rkt`）
6. 周期2の仕様は、例えば次で固定できる:

```racket
(check-expect
 (same-world? (next-generation (next-generation beacon)) beacon)
 true)
;; または (same-world? (step-n beacon 2) beacon)
```

**P4-6** ビーコンが周期 2 であることを、自分で `check-expect` を1本足して確かめよ。

#### 4.6 まとめ

**この章で出てきた主な名前と役割**

- `survives?` / `births?` / `next-alive?` — B3/S23 の1セル判定
- `shift-cell` / `cell-neighbors` — 座標をずらす・8近傍のリスト
- `member-posn?` — 生存リストにその座標があるか
- `count-neighbors` / `count-alive-in` — 近傍の生存数
- `candidate-cells` / `filter-next` / `next-generation` — 候補を作り次世代を返す
- `same-world?` / `sort-cells` / `step-n` / `place` — 比較・n世代・平行移動（テスト用）
- `block` / `blinker-h` / `glider` / `beacon` など — 有名パターンの定数
- `next-generation/torus` — 周期境界版

**この章を思い出すための道しるべ（高校1年生向け）**

1. **何を学んだか**
   「升目が同時に変わるおもちゃ（セル・オートマトン）」を、**短いルール B3/S23** でプログラムにした
2. **ルールは1か所に**
   生死の約束は `next-alive?`（と `survives?` / `births?`）に閉じ込めた。盤の走査と混ぜない
3. **盤の表し方は第3章のまま**
   生きている座標だけ `ListOfPosn`。死は「リストに無い」
4. **周りはいつも8つ**
   `cell-neighbors` が8座標を作り、`count-neighbors` が「そのうち何個が生きているか」を数える
5. **次の世代の作り方**
   全部のマスは見ない。`candidate-cells` で候補を集め、`filter-next` で `next-alive?` が true のものだけ残す
6. **合っているかはどう確かめるか**
   ブロックが動かない・ブリンカーが2拍で戻る、などを `check-expect` と `same-world?` で固定する
   → **パターン ＋ `check-expect` が第4章の仕様書**
7. **迷ったら戻る場所**
   - 1セルのルール → 4.1
   - 近傍と個数 → 4.2
   - 盤全体の更新 → 4.3
   - 端の扱い → 4.4
   - 有名形のテスト → 4.5
   - 手元の完成コード → `code/ch04-life-rules.rkt`

```bash
# リポジトリ root から
racket code/ch04-life-rules.rkt
```

#### 4.7 練習問題の解答（P4-1〜P4-6）

**P4-1** 中央だけ生・周囲がすべて死のとき、次世代の中央はどうなるか。

- 中央は今 **生**、近傍の生存数 `n = 0`
- S23 は「2 または 3 で生存」なので、0 では生き残れない（過疎）
- `(next-alive? true 0)` → `false` → 次世代の中央は **死**

```text
. . .
. # .  →  中央は消える
. . .
```

**P4-2** 中央が死・周囲ちょうど 3 生のとき、中央はどうなるか。

- 中央は今 **死**、`n = 3`
- B3 より誕生 → `(next-alive? false 3)` → `true`
- 次世代の中央は **生**

```text
# # .
. . .  →  中央が生まれる（配置の一例）
. . #
```

**P4-3** `block` の `(make-posn 1 1)` の近傍数を手計算し、コードと照合せよ（期待: 3）。

- `block` の生存: `(1,1) (1,2) (2,1) (2,2)`
- 中心 `(1,1)` 自身は近傍に**含めない**
- 8近傍のうち生存リストにいるのは `(1,2)` `(2,1)` `(2,2)` の **3つ**
- 付属コード: `(check-expect (count-neighbors (make-posn 1 1) block) 3)` が通る

```text
  1 2
1 C #   ← C=(1,1)、右・下・右下が生 → 近傍3
2 # #
```

**P4-4** 空リストを `next-generation` に渡すとどうなるか。

- 今の生存が `empty` → 候補も空（足す近傍も無い）
- `filter-next` は何も残さない → 返り値は **`empty`**
- 誰もいない世界は、そのまま誰もいない（安定）

**P4-5** 1 セルだけの世界は何世代で消えるか。

- 1 セルだけ生 → そのセルの近傍生存数は **0**（周りに誰もいない）
- P4-1 と同じで、次世代ではそのセルは死ぬ
- よって **1 世代で消える**（`next-generation` を1回で `empty`）

**P4-6** ビーコンが周期 2 であることを、自分で `check-expect` を1本足して確かめよ。

例（付属コードにも同型あり）:

```racket
(check-expect
 (same-world? (next-generation (next-generation beacon)) beacon)
 true)
```

または:

```racket
(check-expect (same-world? (step-n beacon 2) beacon) true)
```

- 意味: 2 世代進めると、座標集合が元の `beacon` と一致する（周期 2）
- `same-world?` を使うのは、リストの順序の違いを無視して「同じ盤」とみなすため（4.3 参照）
