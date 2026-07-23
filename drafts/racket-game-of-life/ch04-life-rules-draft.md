---
title: "第4章　ライフゲームのルールとセルオートマトン"
---

> **この章のゴール**  
> コンウェイのルール（B3/S23）を関数に落とし、`count-neighbors` と `next-generation` で盤面を進める。  
> 静止物・振動子・グライダーを `check-expect` で回帰できるようにする。  
> **付属コード**: `code/ch04-life-rules.rkt`（`#lang htdp/asl` — `racket code/ch04-life-rules.rkt`）  
> **状態**: 実験 worktree ドラフト（Issue #1 ASL / #27 / #29 — 7月成功定義）

#### 4.1 コンウェイのルール（B3/S23）

ライフゲームは二次元グリッド上の**セルオートマトン**です。各セルは「生きている / 死んでいる」の二値で、全セルが**同時に**次の状態へ進みます。

ルールは短い（B3/S23 = Birth 3 / Survive 2 or 3）:

| 今の状態 | 周囲 8 マスの生存数 | 次の状態 |
|----------|---------------------|----------|
| 死 | ちょうど 3 | **誕生** |
| 生 | 2 または 3 | **生存** |
| 生 | 0,1 または 4〜8 | **死**（過疎 / 過密） |
| 死 | 3 以外 | 死のまま |

第1章で切り出した判定をそのまま使う:

```racket
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

(define (births? neighbors)
  (= neighbors 3))

(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))
```

ポイント:

- ルールは**局所的**（自分と近傍だけ）で、全体の「意味」はパターン観察から来る
- 実装は「1セルの次状態」→「全候補セルへの写像」と二段に分けるとテストしやすい

**P4-1** 紙に 3×3 の盤を描き、中央だけ生・周囲 8 が死のとき、次世代はどうなるか答えよ。  
**P4-2** 中央が死で周囲がちょうど 3 生のとき、中央はどうなるか。

#### 4.2 隣接セルを数える — `count-neighbors`

##### 盤面の表現（スパース集合）

本編のコアは、**生存セルだけ**を `posn` のリストで持つ方式です（死セルは書かない）。

```racket
;; ブロック（2×2 の静止物）
(define block
  (list (make-posn 1 1) (make-posn 1 2)
        (make-posn 2 1) (make-posn 2 2)))
```

利点:

- 空の大海原を 0 で埋めなくてよい（大規模・疎な配置向き）
- 次世代は「新しいリストを返す」だけで、破壊的更新が不要（関数型）
- ASL の `member?` / `filter` / `map` と相性がよい

トレードオフ:

- 「ある座標が生きているか」はリスト走査（線形）。教育用サイズでは十分

##### 8 近傍

```racket
(define neighbor-deltas
  (list (make-posn -1 -1) (make-posn 0 -1) (make-posn 1 -1)
        (make-posn -1  0)                   (make-posn 1  0)
        (make-posn -1  1) (make-posn 0  1) (make-posn 1  1)))

(define (shift-cell cell delta)
  (make-posn (+ (posn-x cell) (posn-x delta))
             (+ (posn-y cell) (posn-y delta))))

(define (cell-neighbors cell)
  (map (lambda (d) (shift-cell cell d)) neighbor-deltas))
```

`count-neighbors` は「近傍のうち、今生きているものがいくつあるか」:

```racket
(define (count-neighbors cell live-cells)
  (length
   (filter (lambda (n) (member? n live-cells))
           (cell-neighbors cell))))
```

- **固定境界**では、盤の外はリストにいない＝寄与 0（後述のトーラスと対比）

**P4-3** `block` のセル `(make-posn 1 1)` の近傍数を手計算し、`count-neighbors` と一致するか確認せよ（期待: 3）。

#### 4.3 次世代 — `next-generation`

ナイーブに「無限グリッドの全座標」を走査する必要はない。誕生が起きるのは**生存セルの隣**だけなので、候補は:

\[
\text{candidates} = \text{live} \cup \bigcup_{c \in \text{live}} \text{neighbors}(c)
\]

```racket
;; 候補 = 生存 ∪ 各生存の近傍（重複除去は union-list）
(define (next-generation cells)
  (local [(define live cells)
          (define candidates (candidate-cells live))]
    (filter (lambda (c)
              (next-alive? (member? c live)
                           (count-neighbors c live)))
            candidates)))
```

読み方:

1. 候補リストを作る（生存とその近傍）  
2. 各候補について `next-alive?` が真なら残す  
3. 結果は**新しいリスト**（入力は書き換えない）  

順序は不定になり得るので、テストではソートして比較する:

```racket
(define (same-world? a b)
  (equal? (sort-cells a) (sort-cells b)))
```

n 世代まとめて進める:

```racket
(define (step-n cells n)
  (cond
    [(<= n 0) cells]
    [else (step-n (next-generation cells) (- n 1))]))
```

**P4-4** 空リスト `'()` を `next-generation` に渡すとどうなるか。理由を一文で。  
**P4-5** 単独セル `'((0 . 0))` は何世代で消えるか（手計算 + コード）。

#### 4.4 境界の扱い — 固定 vs トーラス

| 方式 | イメージ | 実装の要点 |
|------|----------|------------|
| **固定境界** | 盤の外は常に死 | 座標をそのままたどる。外は set にいない |
| **トーラス** | 左右・上下がつながる円筒→ドーナツ | 座標を `modulo` で折り返す |

本章の既定は**固定境界**（無限平面のスパース近似）。端でパターンが「壁にぶつかる」挙動になる。

トーラス版の近傍:

```racket
(define (wrap-cell cell width height)
  (make-posn (modulo (posn-x cell) width)
             (modulo (posn-y cell) height)))

(define (cell-neighbors/torus cell width height)
  (map (lambda (d)
         (wrap-cell (shift-cell cell d) width height))
       neighbor-deltas))
```

`next-generation/torus` は候補・近傍の両方で折り返しを使う（付属コード参照）。

**いつトーラスにするか**

- 小さな閉世界で振動子を端またぎで試すとき  
- GUI で「画面の端から反対へ出る」演出が欲しいとき  

グライダーを長く観察するなら、固定＋十分広い座標空間（または後述の描画ビューポート）の方が素直です。

**P4-6** 幅 5・高さ 5 のトーラス上で、端に置いたブリンカーが周期 2 で戻ることを `raco test` のケースで確認せよ。

#### 4.5 ユニットテスト（`check-expect` / ASL）

##### なぜテストするか

ライフゲームは「見た目が正しそう」で誤解しやすい。**名前付きパターンの不変条件**をテストに固定すると:

- リファクタ（境界の変更など）で壊れに気づける（**回帰**）
- 境界値（近傍 0〜8、空盤、単独セル）を意図的に書ける
- 本の読者が「自分の実装が本と同じか」を機械的に照合できる

##### ASL を選ぶ理由（Issue #1）

- `check-expect` が言語に最初からある → 例＝テストにしやすい  
- エラーメッセージが学生向けで読みやすい  
- CLI では次でまとめて実行できる:

```racket
(require test-engine/racket-tests)
;; … check-expect 群 …
(test)
```

```bash
racket code/ch04-life-rules.rkt
# または mise run test:racket
```

一般的な観点:

| 観点 | ライフゲームでの例 |
|------|-------------------|
| 境界値 | 近傍 0,2,3,4 / 空盤 / 1 セル |
| 不変条件 | ブロックは何世代でも同一 |
| 周期 | ブリンカーは 2 世代で戻る |
| 移動 | グライダーは 4 世代で (1,1) シフト |
| 回帰 | ルール式を書き換えたらテストが落ちる |

##### 代表パターンと期待

```racket
;; 静止物
(check-expect (same-world? (next-generation block) block) true)

;; 振動子（周期 2）
(check-expect (same-world? (next-generation blinker-h) blinker-v) true)
(check-expect (same-world? (step-n blinker-h 2) blinker-h) true)

;; グライダー: 4 世代で南東へ 1 マス
(check-expect
 (same-world? (step-n glider 4) (place glider 1 1))
 true)
```

**P4-7** `beacon`（ビーコン）が周期 2 であることを、自分で `check-expect` を1本足して確かめよ。  
**P4-8**（発展）ランダムに 20 セル置いた初期配置を 100 世代進め、セル数が爆発していないことだけを緩く監視するテストを考えてみよ（フレークしうるので「実験」扱い）。

#### 4.6 セルオートマトンとして育てる

ここまでのコードは「ルールエンジン」です。GUI やクラスがなくても CA は成立します。拡張の方向だけ先に言葉にしておきます（実装の骨格は第5章）。

##### 4.6.1 セルをデータとして見ると

スパース表現ではセルは `make-posn` で足りる。第3章で `define-struct` を使うなら:

```racket
(define-struct cell (x y))
```

今は `posn` のままでよい（`equal?` と比較がそのまま使える）。

##### 4.6.2 セルの「サイズ」

ロジック上のセルは点。表示上のピクセルサイズ（`cell-size`）は第1章の `board-pixel-width` と同じく**ビューの話**で、`next-generation` には混ぜない。

##### 4.6.3 CA を成長させる手順

1. **初期配置**をリストで置く（パターン関数でも、手書きでも）  
2. **世代ループ**: `(step-n world n)` または REPL で `(define w2 (next-generation w1))`  
3. **観察**: 第5章の ASCII / 画像で見る  
4. **テスト**: パターンの不変条件を `rackunit` に残す  

二次元リスト（密行列）版は `my-racket/lifeofgame.rkt` にもある。教育用には:

- **密グリッド** … 添字二重ループが直感的、固定サイズ向き  
- **スパース集合** … 本編の本線、無限平面・関数型更新向き  

どちらも中身は同じ B3/S23 です。

#### まとめ

| 部品 | 役割 |
|------|------|
| `next-alive?` | 1 セルの B3/S23 |
| `count-neighbors` | 周囲の生存数 |
| `next-generation` | 候補集合 → 次の生存リスト |
| `next-generation/torus` | 周期境界版 |
| パターン + `check-expect` | 静止・振動・移動の仕様書 |

次章では、このエンジンの上に **ASCII 表示**と有名パターンのカタログを載せ、REPL から世代を進められるようにします。

> **実験メモ（worktree）**  
> 本ファイルは `experimental/20260723-mypublish-gol-feat` 上のドラフト（Issue #1 ASL）。  
> Zenn 公開は `config.yaml` の `chapters` への追加とユーザー承認後。
