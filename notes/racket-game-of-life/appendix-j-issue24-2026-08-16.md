# 付録J Issue #24 作業メモ（2026-08-16）

- 出典 Issue: https://github.com/bluehive/mypublish-gameoflife/issues/24
- 原記事: https://stopa.io/post/265 （Stepan Parunashvili, 2020）
- 承認: 新規 appendix-j / 本文 2000–4000字 / 序章コラム≈500字 / 司書=Grok・批判=pro・Hermes=実装 / intro 未コミットは混ぜない

## Grok 司書 R1（つまずき）

`/tmp/grok-book-j/r1.txt` を転記。R2/R3 は grok タイムアウトしやすいので短プロンプトで再走。

1. eval/cookie/websocket → 「文字列をそのまま走らせない」に縮める
2. JSON → 命令カード
3. 配列 vs 本編リスト → 「先頭＝すること、残り＝材料」。角括弧はこの思考実験
4. 入れ子再帰 → 0.4 の内側から外側。第2章とは目的が違うと注記
5. do/def/fn の対訳は Clojure より `define`。マクロ・構造編集は発展

本編転用: 「命令を『いちばん左がすること、残りが材料』の入れ子リストで書くと、プログラムとデータが同じ形になる。」

## 原記事との整合（Hermes）

| 原記事 | 付録J |
|--------|--------|
| eval 危険 | 文章をそのまま実行しない（cookie 省略） |
| JSON オブジェクト | 命令カード |
| 配列簡略化 | 先頭＝すること |
| 入れ子+再帰 | 規則2行 + 0.4 接続 |
| do / def / fn | 残す。BSL 非本線と明記 |
| Code is Data / unless / 構造編集 | J.2。マクロは本編外 |
| Clojure 種明かし | Racket/BSL の `define` を主、Clojure は一文 |
| 発明ではなく発見 | J.4。より良い表面があり得ると残す |

## git

- 作業ブランチ: `experimental/20260816-appendix-j-lisp-syntax`
- stash: `wip intro.md unrelated (issue24 作業に混ぜない)`
- `.grok/` は untracked のまま載せない
