---
title: "第5章　描画と対話——盤面を見る"
---

> **この章のゴール（7月骨格）**  
> 第4章の `next-generation` を、目で追える形にする。  
> ASCII 表示・REPL での世代送り・有名パターンのカタログを最低限そろえる。  
> **付属コード**: `code/ch05-display.rkt`（`#lang htdp/asl`・章単体で完結）  
> **状態**: 骨格ドラフト（GUI / GIF は発展枠 / Issue #1）

#### 5.1 ASCII で盤面を見る

スパースな生存リストはそのままでは形が見えない。ビューポート（原点・幅・高さ）を決めて、文字のグリッドに写す。

```racket
(define (world->rows cells origin-x origin-y width height)
  …) ; 生存を "#"、それ以外を "."

;; ASL にはキーワード引数が無いので位置引数
(display-world glider-cells 0 0 12 8 0)
```

例（グライダー）:

```
.#..........
..#.........
###.........
............
```

- `#` / `.` は慣習。好みで `■` `・` でもよいが、等幅フォント前提
- **ロジック座標**と**表示原点**を分ける（グライダーが画面外に出たら origin をずらす）

`2htdp/image` や `racket/gui` は後続で。骨格段階では ASCII がフィードバック最速。

**P5-1** `pattern-block` を 6×4 のビューで `display-world` し、2×2 の `#` を確認せよ。

#### 5.2 世代を進める REPL コマンド

```racket
;; DrRacket で code/ch05-display.rkt を Run したあと、相互作用で:

(define w0 pattern-glider)
(define w1 (next-generation w0))
(display-world w1 0 0 16 10 1)

;; まとめて見る
(evolve-ascii pattern-blinker 4 0 0 8 5)
```

- `step-n`（第4章）で n 世代先のスナップショットだけ取る  
- `evolve-ascii` で途中経過を流す（`#:delay` でアニメ風）

DrRacket の相互作用ウィンドウでも、ターミナルの `racket` でも可。

**P5-2** ブリンカーを 6 世代 `evolve-ascii` し、偶数世代で同じ形に戻ることを目視せよ。

#### 5.3 有名パターン

| 名前 | 種別 | コード上の識別子 | 覚え方 |
|------|------|------------------|--------|
| ブロック | 静止物 | `pattern-block` | 2×2 が永遠 |
| ブリンカー | 振動子 p2 | `pattern-blinker` | 横↔縦 |
| ビーコン | 振動子 p2 | `pattern-beacon` | 角が点滅 |
| トード | 振動子 p2 | `pattern-toad` | 6 セル |
| グライダー | 宇宙船 | `pattern-glider` | 4 世代で斜め 1 |
| パルサー | 振動子 p3 | `pattern-pulsar` | **未収録（プレースホルダ）** |

平行移動:

```racket
(place pattern-glider 5 3)  ; (+5, +3)
```

合成:

```racket
(union-cells pattern-block (place pattern-glider 8 0))
```

第4章の `check-expect` と組み合わせると、「カタログの形がエンジンと一致している」ことを機械的に保証できる。

**P5-3** グライダーを `(place … 2 2)` してから 4 世代進め、さらに (1,1) シフトしていることを `same-world?` で確認せよ。

#### 5.4 ファイルから初期配置を読む（骨格）

簡易 **Life 1.06 風**: 1 行に `x y`。`#` 始まりはコメント。

```
# my pattern
0 0
0 1
1 0
1 1
```

```racket
(define cells (load-cells "path/to/pattern.txt"))
(display-world cells)
```

RLE 形式や `.cells`（Golly）は発展課題。まずは手で書ける行形式から。

#### 5.5 GIF / 画像列のエクスポート（発展・未実装）

方針メモのみ（7月骨格の範囲外）:

1. 各世代を `2htdp/image` の bitmap に描く  
2. 連番 PNG を書く  
3. 外部ツール（`ffmpeg` 等）で GIF/APNG 化  

本リポジトリの EPUB パイプラインとは独立。必要になったら Issue で切り出す。

#### まとめ（骨格チェックリスト）

| 項目 | 状態 |
|------|------|
| ASCII `display-world` | 実装済（実験） |
| `evolve-ascii` | 実装済（実験） |
| block / blinker / beacon / toad / glider | 実装済 |
| pulsar 完全座標 | 未（プレースホルダ） |
| Life 1.06 風ロード | パーサのみ |
| 2htdp / GUI / GIF | 未（発展） |

第4章のテストが緑であることと、本章で「形が見える」ことが、7月成功定義の第5章骨格の到達点です。

> **実験メモ（worktree）**  
> `experimental/20260723-mypublish-gol-feat` 上の骨格。公開 chapters への追加は承認後。
