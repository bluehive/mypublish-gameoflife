---
title: "付録 H　big-bang でライフゲームをアニメーションする"
---

> **この付録のゴール**  
> 本編と同じ **BSL**（`#lang htdp/bsl`）と **`2htdp/image` / `2htdp/universe`（`big-bang`）** を使い、壁境界の有限盤（60×40）上で **グライダー 3 機**が斜めに進む様子をアニメーション表示する。  
> 第5章 5.6 の「発展 big-bang」を、付録サイズの盤と壁境界・3 機配置で本格化する（Issue #13）。  
> **付属コード**: `code/life-engine.rkt`（純ロジック + `check-expect`） / `code/big-bang-gliders.rkt`（描画・ウィンドウ）

---

#### H.1 なぜ本編と分けるか

| 層 | 本編（第1–5章） | 本付録 |
|---|---|---|
| 言語 | `#lang htdp/bsl` | **同じ BSL** |
| 描画 | ASCII 中心 / 第5章で big-bang は発展 | **big-bang + 色つき升目**を主眼 |
| テスト | `check-expect` + `test-engine` | **同じ**（ロジックは `life-engine.rkt`） |
| 境界 | トーラスも第4章で紹介 | **壁（外側は死）** 固定 |
| 位置づけ | 必須カリキュラム | 任意の見た目強化（ただし言語は本線と一貫） |

以前のプロトタイプ（Issue #11）では Sketching（`#lang racket`）を使っていました。Issue #13 で **本編と同じ BSL に揃え**、破壊的代入（`set!`）ではなく **`on-tick` が次の世界を返す**形に改めました。

ロジックと GUI を分けると、**ルールの正しさは headless でテスト**し、見た目は big-bang に任せられます（How to Design Programs の「データと関数を先に」に沿う分割）。

---

#### H.2 仕様

| 項目 | 値 |
|---|---|
| グリッド | **60 × 40** |
| 境界 | **壁**（盤外は常に死。トーラスにしない） |
| 初期配置 | **グライダー 3 機**（十分離して配置） |
| セル描画 | **正方形**・**緑**（`lime`） |
| グリッド線 | **あり** |
| フレームレート | 既定 **約 8 fps**（`TICK-RATE` = `1/8` 秒） |
| 言語 | **`#lang htdp/bsl`** + `2htdp/image` + `2htdp/universe` |

---

#### H.3 ファイル構成

```text
code/life-engine.rkt       … B3/S23・壁境界・配置ヘルパ + check-expect（GUI なし）
code/big-bang-gliders.rkt  … big-bang アニメ（自己完結。ロジックは life-engine と同型）
```

**BSL の制約**: 学生言語のモジュール同士は、通常の Racket のように `provide` / `require` で定義を共有しにくいです。そのため `big-bang-gliders.rkt` は **実行用に自己完結**させ、正しさの正本は `life-engine.rkt` の `check-expect` に置きます。

デザインレシピの流れ（`life-engine.rkt`）:

1. データ定義（Neighbors / Cell=Posn / World=ListOf Posn）  
2. 解釈（生きているセルだけリストに載せる）  
3. 例 → 近傍カウント → `next-generation/wall`  
4. テストでグライダー 4 世代平行移動を固定  

---

#### H.4 セットアップと実行

```bash
cd /path/to/mypublish-gameoflife

# ロジックのテスト（GUI なし・CI でも実行）
racket code/life-engine.rkt
# または
mise run test:racket

# アニメーション（ウィンドウが開く）
racket code/big-bang-gliders.rkt
```

追加パッケージ（Sketching 等）は **不要**です。Racket / DrRacket に付属する `2htdp` だけで足ります。

`mise run test:racket` は **`big-bang-*.rkt` を除外**します（ウィンドウ起動で CI が止まるため）。ロジック検証は `life-engine.rkt` が担当します。

---

#### H.5 コードの要点

**壁境界の近傍**

- 盤外座標は候補に入れない／生きていると数えない  
- 端に突っ込んだグライダーはやがて消滅する（トーラスではないことの確認用テストあり）

**big-bang 側（状態は値、更新は関数）**

Sketching 時代は `(set! world …)` で状態を書き換えました。BSL では次の対応になります。

| Sketching（旧） | big-bang（BSL・現行） |
|---|---|
| 可変の `world` + `set!` | 世界は **値**（`ListOf Posn`） |
| 毎フレーム `draw`（副作用で描画） | **`to-draw`** が `Image` を返す |
| 手続き的ループ | **`on-tick`** が次の世界を返す |
| 0 引数の `setup` / `draw` | 世界を受け取る 1 引数関数 |

```racket
(big-bang THREE-GLIDERS-WORLD
  (on-tick tock TICK-RATE)   ; 約 8 fps
  (to-draw render)
  (name "Game of Life — 3 gliders (BSL big-bang, #13)"))
```

描画は: 背景の `empty-scene` → グリッド線（`add-line` の再帰）→ 緑の `square` を `place-image`。

---

#### H.6 本編との学びのつながり

- 第4章の B3/S23・グライダー 4 世代テストと同じ規則（境界だけ壁に固定）  
- 第5章の「盤を見る」と 5.6 big-bang スケッチを、60×40・色・グリッド線まで拡張  
- **言語レベルを上げない**まま「動くライフゲーム」まで到達できる  

---

#### H.7 今後

- [ ] フレームレート・色・セルサイズの読者向けカスタム節  
- [ ] トーラス境界版との比較コラム（第4章との対照）  
- [ ] キー操作で一時停止（`on-key`）  

> 旧: Sketching プロトタイプ（Issue #11）。現行: BSL + big-bang（Issue #13）。
