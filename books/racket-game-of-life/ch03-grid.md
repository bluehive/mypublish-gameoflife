---
title: "第3章　データ構造——グリッドを表現する"
---

> **状態**: 骨子ドラフト（Issue ユーザー方針 / howtocode テンプレート）  
> **言語**: Beginning Student（`#lang htdp/bsl`）

#### 3.1 二次元の表し方（候補）

| 表現 | データ定義のイメージ | 向き |
|------|----------------------|------|
| 生存セルの `ListOfPosn` | スパース。第4章の本線 | 空の大海を持たない |
| 行のリスト（`ListOf ListOfNumber`） | 密グリッド | 添字二重ループに近い |
| `define-struct` で Cell / World | Compound テンプレ | フィールドが明確 |

#### 3.2 テンプレートの指針

howtocode の **Compound / Self Reference / Reference** 表に従う。

- World が ListOfPosn なら第2章のリストテンプレ  
- World が struct なら全アクセサをテンプレに並べる  

#### 3.3 不変データ

世代更新は「今の World を壊す」より **新しい World を返す**（第4章）。

#### 3.4 演習（予定）

- 小さな 3×3 密グリッドを `list` の `list` で書き、`grid-ref` 相当を再帰または `list-ref` で取る  
- 同じ配置を `ListOfPosn` でも書き、相互変換の仕様を `check-expect` で固定する  

（本文・付属コードの拡充は後続タスク）
