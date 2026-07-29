---
title: "付録 H　Sketching でライフゲームをアニメーションする（プロトタイプ）"
---

> **この付録のゴール**  
> Processing 風ライブラリ **Sketching** を使い、壁境界の有限盤（60×40）上で **グライダー 3 機**が斜めに進む様子をアニメーション表示する。  
> 本編（BSL + `2htdp/image` / `big-bang`）とは分離した **発展・グラフィック強化のプロトタイプ**（Issue #11）。  
> **付属コード**: `code/life-engine.rkt`（純ロジック） / `code/life-engine-test.rkt`（rackunit） / `code/sketching-gliders.rkt`（描画）

---

#### H.1 なぜ本編と分けるか

| 層 | 本編（第1–5章） | 本付録（プロトタイプ） |
|---|---|---|
| 言語 | `#lang htdp/bsl` 中心 | `#lang racket` |
| 描画 | ASCII / `2htdp/image` / `big-bang` | **Sketching**（Processing 風） |
| テスト | `check-expect` + `test-engine` | **rackunit**（ロジック分離） |
| 境界 | トーラスも第4章で紹介 | **壁（外側は死）** 固定 |
| 位置づけ | 必須カリキュラム | 任意の見た目強化 |

ロジックと GUI を分けると、**ルールの正しさは headless でテスト**し、見た目は Sketching に任せられます（How to Design Programs / howtocode の「データと関数を先に」に沿う分割）。

---

#### H.2 仕様（Issue #11 で確定した前提）

| 項目 | 値 |
|---|---|
| グリッド | **60 × 40** |
| 境界 | **壁**（盤外は常に死。トーラスにしない） |
| 初期配置 | **グライダー 3 機**（十分離して配置） |
| セル描画 | **正方形**・**緑** |
| グリッド線 | **あり** |
| フレームレート | 既定 **8 fps**（`sketching-gliders.rkt` の `FPS`） |
| 言語 | `#lang racket` + `(require sketching)` |

---

#### H.3 ファイル構成

```text
code/life-engine.rkt          … B3/S23・壁境界・配置ヘルパ（GUI なし）
code/life-engine-test.rkt     … rackunit テスト
code/sketching-gliders.rkt    … Sketching アニメ（require life-engine）
```

デザインレシピの流れ（`life-engine.rkt` 先頭コメントにも記載）:

1. データ定義（Neighbors / Cell=Posn / World=ListOf Posn）  
2. 解釈（生きているセルだけリストに載せる）  
3. 例 → 近傍カウント → `next-generation/wall`  
4. テストでグライダー 4 世代平行移動を固定  

---

#### H.4 セットアップと実行

```bash
# 一度だけ
raco pkg install sketching

cd /path/to/mypublish-gameoflife

# ロジックのテスト（GUI なし）
racket code/life-engine-test.rkt

# アニメーション（ウィンドウが開く）
racket code/sketching-gliders.rkt
```

`mise run test:racket` は **`sketching-*.rkt` を除外**します（ウィンドウ起動で CI が止まるため）。ロジック検証は `life-engine-test.rkt` が担当します。

---

#### H.5 コードの要点

**壁境界の近傍**

- 盤外座標は候補に入れない／生きていると数えない  
- 端に突っ込んだグライダーはやがて消滅する（トーラスではないことの確認用テストあり）

**Sketching 側（`#lang racket`）**

`#lang sketching` の module-begin は使わず、次を手で呼びます。

```racket
(initialize)
(setup)
(current-draw draw)  ; sketching/parameters
(start)
```

描画は毎フレーム: 背景 → グリッド線 → 緑の `square` → `next-generation/wall`。

---

#### H.6 本編との学びのつながり

- 第4章の B3/S23・グライダー 4 世代テストと同じ規則  
- 第5章の「盤を見る」体験を、Processing 系の見た目で再構成  
- 姉妹書『自己相似形グラフィック入門』の turtle / plot と並ぶ **もう一つの描画軸**の実験

---

#### H.7 今後（承認後に検討）

- [ ] 付録として Zenn `config.yaml` の chapters に載せるか  
- [ ] フレームレート・色・セルサイズの読者向けカスタム節  
- [ ] 本編 big-bang 版との比較コラム  

> 本ファイルは **承認前プロトタイプ**（PR）用。マージ方針は Issue #11 で判断する。
