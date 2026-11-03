# ライフゲーム短縮ドラフトの改訂メモ（2026-11-03）

## 目的と対象

初学者がRacketでプログラムの基礎を学ぶことを主軸に、一般構文の重複を削り、データ・条件分岐・再帰・テストを一つの題材で練習する。変更対象は `drafts/racket-game-of-life/` と本メモのみ。`books/`、`code/`、出版設定や生成物は変更しない。参照リポジトリへの書き込みは行わない。

## 比較した参照原稿

比較時のmainのコミットを固定して記録する。

- タートル本: `cd2d3f90e767cacdffbe92abb243382f06658943`
  - [第1章](https://github.com/bluehive/mypublish-racket-turtle/blob/cd2d3f90e767cacdffbe92abb243382f06658943/books/racket-turtle-fractals/ch01-basics.md): 式・値・前置記法、定義、関数、条件分岐、リスト、check-expect、再帰の導入が共通。
  - [第3章](https://github.com/bluehive/mypublish-racket-turtle/blob/cd2d3f90e767cacdffbe92abb243382f06658943/books/racket-turtle-fractals/ch03-loops.md): 現行版はISLのbuild-list/map/foldrを使用し、明示的な再帰は本線から外している。ライフゲームの再帰は独自の学習として残す。
  - [付録B](https://github.com/bluehive/mypublish-racket-turtle/blob/cd2d3f90e767cacdffbe92abb243382f06658943/books/racket-turtle-fractals/appendix-b-environment.md): Windows/DrRacketの導入・設定・動作確認が重複。タートルのteachpacks導入は本教材では不要。
- マクロ本: `ab7459960596934070e4e1c0b535d866ec394bba`
  - [はじめに](https://github.com/bluehive/mypublish-racket-macro-bc/blob/ab7459960596934070e4e1c0b535d866ec394bba/books/racket-macro-bc/intro.md): Scratchとの対応、定義・条件・前置記法の導入が共通。
  - [第1章](https://github.com/bluehive/mypublish-racket-macro-bc/blob/ab7459960596934070e4e1c0b535d866ec394bba/books/racket-macro-bc/ch01-syntax.md): スタック、関数とマクロ、構文変換が中心。ライフゲームと直接重ならないので、その内容を削除理由にしない。マクロ本の履修を前提にせず、本ドラフトはBSLで完結する。

## 旧構成からの変更

| 旧原稿 | 処置と理由 | 新しい置き場 |
|---|---|---|
| 序章 | 他言語との比較、LISPの由来、構文・評価の長い説明、パターンの列挙を削除。題材の規則と準備に絞る | はじめに |
| 第1章 基礎 | 型・式・define・if/cond・一般関数・リストの総覧を削除し、共通教材を参照。座標と所属判定を題材内で学ぶ | 第1章 盤面 |
| 第2章 再帰 | 数の合計など一般例、enum/interval、繰り返すレシピとテンプレートを削除。停止条件と残りへの再帰は所属判定・近傍集計に統合 | 第1・2章 |
| 第3章 グリッド | 密グリッドの別案・相互変換・実行手順の反復を削除。生存座標リスト一つに固定 | 第1章 |
| 第4章 ルール | 1セル判定・近傍・候補・更新を残す。トーラス、パターンカタログ、長い問題解答を削除 | 第2章 |
| 第5章 表示 | ASCII表示とブロック/ブリンカーのテストを残す。ファイルパーサ、GUI/big-bang、言語レベル切替、追加パターンを削除 | 第3章 |
| 付録D 環境 | 重複する導入付録そのものを削除し、共通教材へリンク | README・はじめにの最小動作確認 |

密グリッド・トーラス・GUI等は、参照原稿と同じという理由ではなく、短く基礎を学ぶ本線に絞るために削除した。削除した説明を別の付録へ移して残すことはしない。

## 読者の進み方

`README.md` を入口に、はじめに＋3章で読む。共通のRacket基礎を参照しながら学べるが、タートル描画やマクロの実装は必修にしない。旧5章用コードを参照する混乱を避け、短縮版専用 `life-draft.rkt` を付ける。コードは既存BSL実装から必要な関数を再利用し、GUI・トーラス・パーサは含めない。本文のコードは抜粋であることを明記する。

## 分量と検証

- 比較元: リポジトリ0の `bed7fb8f6d9267c505167b5584708b2ad308e3d6`。
- 旧Markdown7ファイル（序章＋5章＋付録）: 65,454文字。
- 新本文4ファイル（はじめに＋3章）: 5,789文字。約91.2%削減。
- READMEと全コードを含むドラフト全体: 12,118文字。約81.5%削減。文字数はUTF-8をデコードした文字数（空白・コード・メタデータを含む）。本メモは編集記録なので教材本文の集計外。
- `racket drafts/racket-game-of-life/life-draft.rkt`: 19件成功。所属判定、8近傍と中央除外、空盤面、ブロック、ブリンカー、順序によらない比較、文字表示、孤立セルを確認。
- 作業用の追加確認: 生死×近傍0〜8の全18通り、負の座標のブロック、表示範囲外のセルによる誕生、候補数、本文のテスト例を加えて50件成功。
- Markdownのローカルリンク、コードフェンスの対応、`git diff --check` を確認。
- 公開用ビルドは `books/` を入力とするため、このドラフトの検証には使用しない。出版用成果物の再生成は行わない。
