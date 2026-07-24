---
title: "付録A　付属ソースコード一覧（ガイド）"
---

> **この付録のゴール**  
> 本リポジトリの `code/` にある付属プログラムを、「どの章用か・何をするか」で一覧する。  
> **正本の場所**: [code/（main ブランチ）](https://github.com/bluehive/mypublish-gameoflife/tree/main/code)  
> **読者**: 高校1年（Scratch 約20時間）でも、「どのファイルを開けばよいか」が分かるようにする。  
> **Issue**: [#7](https://github.com/bluehive/mypublish-gameoflife/issues/7)

#### A.1 はじめに

- 各ファイルは、章の本文（`books/racket-game-of-life/`）とセットです。  
- 多くは **`#lang htdp/bsl`（Beginning Student）** です。第5章の発展だけ **ISL+** があります。  
- 実行は **リポジトリの root** から、例えば次のとおりです。

```bash
racket code/ch01-basics.rkt
```

- ライセンスはリポジトリの [MIT License](https://github.com/bluehive/mypublish-gameoflife/blob/main/LICENSE) です。  
- 以前メモにあった外部リポジトリ [bluehive/my-racket](https://github.com/bluehive/my-racket) は参考用です。**この本の付属コードの正本は本リポジトリの `code/`** です。

#### A.2 ファイル一覧と役割

リンクは GitHub の **main** 上の各ファイルです（最新の公開形）。学習中の実験ブランチでは、ローカルの `code/` を開いても構いません。

| ファイル | 章 | 言語 | 役割（ひとこと） |
| --- | --- | --- | --- |
| [ch01-basics.rkt](https://github.com/bluehive/mypublish-gameoflife/blob/main/code/ch01-basics.rkt) | 第1章 | BSL | 式・`define`・`cond`・関数・`posn`・リスト・`check-expect` の基礎 |
| [ch02-recursion.rkt](https://github.com/bluehive/mypublish-gameoflife/blob/main/code/ch02-recursion.rkt) | 第2章 | BSL | デザインレシピ、`my-length` / `sum-list` など**構造的再帰** |
| [ch03-grid.rkt](https://github.com/bluehive/mypublish-gameoflife/blob/main/code/ch03-grid.rkt) | 第3章 | BSL | 盤の表現（`ListOfPosn` と密グリッド）、`grid-ref` など |
| [ch04-life-rules.rkt](https://github.com/bluehive/mypublish-gameoflife/blob/main/code/ch04-life-rules.rkt) | 第4章 | BSL | B3/S23、`next-generation`、ブロック／ブリンカー／グライダー等のテスト |
| [ch05-display.rkt](https://github.com/bluehive/mypublish-gameoflife/blob/main/code/ch05-display.rkt) | 第5章・本線 | BSL | `world->rows` で ASCII 表示、パターンと `check-expect` |
| [ch05-display-isl.rkt](https://github.com/bluehive/mypublish-gameoflife/blob/main/code/ch05-display-isl.rkt) | 第5章・発展 | ISL+ | 升目の見やすい表示、グライダー世代 0〜8（任意） |

ディレクトリそのもの:  
https://github.com/bluehive/mypublish-gameoflife/tree/main/code

#### A.3 どれから開くか（迷ったとき）

1. いま読んでいる**章番号**と同じ `ch0N-….rkt` を開く  
2. DrRacket で Run するか、上の `racket code/…` でテストが通るか見る  
3. 第5章で「ターミナルに升目を出したい」ときだけ、発展の `ch05-display-isl.rkt`（言語レベルに注意）  

#### A.4 関連

- 章本文の目次: リポジトリ root の [README.md](https://github.com/bluehive/mypublish-gameoflife/blob/main/README.md)  
- 環境: [付録D](appendix-d-environment.md)  
- デバッグの手がかり: [付録F](appendix-f-debug.md)  
