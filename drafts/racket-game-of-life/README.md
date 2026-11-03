# ライフゲームで学ぶプログラムの基礎（短縮ドラフト）

このドラフトは、Racketで小さな関数を書き、例で確かめ、組み合わせる練習です。ライフゲームの完成を通して、データの表現・条件分岐・再帰・テストを学びます。

読む順序は次のとおりです。

1. [はじめに：準備と到達点](intro-draft.md)
2. [第1章：盤面をデータにする](ch01-world-draft.md)
3. [第2章：規則から次の世代を作る](ch02-step-draft.md)
4. [第3章：表示して確かめる](ch03-observe-draft.md)

[実行できる全コード](life-draft.rkt)はこのドラフト専用です。各章の断片は、説明した関数をこのファイルで探して読むための抜粋です。自分で組み立てる場合は、第1章から同じファイルに定義を足してください。同名の定義を二重に貼る必要はありません。

リポジトリのルートで次を実行すると、全コードのテストとブリンカーの2世代分の表示を確認できます。

```sh
racket drafts/racket-game-of-life/life-draft.rkt
```

`books/` は既存の公開用原稿です。今回の短縮版は `drafts/` 内でレビューし、公開用原稿への反映は別の判断とします。既存の `code/ch01-*` などは旧5章構成に対応するため、この短縮版では上の全コードを使用します。

## 共通の基礎を復習する

前置記法・定義・条件分岐・リスト操作・`check-expect` の詳しい説明は[タートル本の第1章](https://github.com/bluehive/mypublish-racket-turtle/blob/main/books/racket-turtle-fractals/ch01-basics.md)、インストールは[同書の付録B](https://github.com/bluehive/mypublish-racket-turtle/blob/main/books/racket-turtle-fractals/appendix-b-environment.md)を参照してください。ライフゲームではタートル用の追加パッケージは使いません。

[マクロ本のはじめに](https://github.com/bluehive/mypublish-racket-macro-bc/blob/main/books/racket-macro-bc/intro.md)にも、ScratchとRacketの対応や前置記法の説明があります。本ドラフトを読むためにマクロを学ぶ必要はありません。本ドラフトは最後まで `#lang htdp/bsl` を使います。

改訂の比較根拠と削除項目は[改訂メモ](../../notes/racket-game-of-life/shortening-2026-11-03.md)にまとめています。
