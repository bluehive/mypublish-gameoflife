# plan.md — 作業計画・進捗・開発駆動方針

> **このファイルの役割**
> エージェント（Grok 等）が作業するときに**最初に参照する**運用メモ。
> 目次・言語方針の詳細・フォルダ構成・mise タスク一覧は **[README.md](./README.md) を正**とし、ここでは重複しない。

| 項目 | 参照先 |
|------|--------|
| 本の目次・付録 A–G | [README.md](./README.md)「本の目次」「付録」 |
| 言語方針（移行中） | 下記 §7・[README.md](./README.md)（ASL→**BSL へ転換予定**） |
| 正本パス・開発フロー・CI | [README.md](./README.md) |
| 章本文 | `books/racket-game-of-life/` |
| 章コード | `code/*.rkt` |
| スタイル参照 | [howtocode.pages.dev](https://howtocode.pages.dev/)（ユーザー指定 2026-07-23） |
| マスター Issue | [my-grok-task-2026#27](https://github.com/bluehive/my-grok-task-2026/issues/27) |
| 本 repo | [#1 ASL](https://github.com/bluehive/mypublish-gameoflife/issues/1) → 方針見直し / [#2 ドラフト](https://github.com/bluehive/mypublish-gameoflife/issues/2) |

最終更新: 2026-07-23（ユーザーコメント解析・BSL 書き換えプラン追加）

---

## 1. 開発駆動方針

### 1.1 ドキュメントの役割分担

| ファイル | 正とする内容 | 更新タイミング |
|----------|--------------|----------------|
| **README.md** | 読者向け: 目次・言語・セットアップ・CI の説明 | 公開情報・章構成が変わったとき |
| **plan.md**（本ファイル） | 作業者向け: 予定・進捗・駆動方針・次アクション | **作業の開始/完了ごと** |
| `books/**` | 章原稿（Zenn 正本） | 章執筆・ユーザー承認後 |
| `code/**` | 実行可能な ASL サンプル + `check-expect` | コード変更と同時 |
| `config.yaml` | Zenn 公開章リスト | **ユーザー承認後のみ** chapters 変更 |

### 1.2 開発の軸（ドメイン駆動・テスト駆動・Issue 駆動）

1. **ドメイン中心**
   抽象論より先にライフゲームの語彙（セル・近傍・世代・パターン）で関数を切る。
2. **言語レベル（更新 2026-07-23）**
   **当面の第一言語は BSL**（`#lang htdp/bsl` / Beginning Student）。
   途中章から Advanced へ上げる可能性あり（ユーザー判断）。Issue #1 の ASL 第一は**上書き**。
   テストは引き続き `check-expect`（BSL 標準）。CLI は `test-engine` + `(test)` を維持。
3. **howtocode スタイル**
   導入・式・インストール・チートシート・**HtDP テンプレート**を [howtocode.pages.dev](https://howtocode.pages.dev/) から取り込む（§7）。
4. **テストゲート**
   コード変更後は `mise run ci:test`（または `test:racket`）を緑にしてから区切る。
   常駐なら `mise run watch:test`（README「ローカル CI」）。
5. **Issue 駆動**
   大きな方針変更は GitHub Issue を読み、実装前にユーザー承認を取る（特に公開 chapters・破壊的変更）。
6. **正本を増やさない**
   目次の二重管理をしない（旧 `outline.md` は廃止済み）。進捗は **plan.md**、公開向け説明は **README**。
7. **worktree 安全**
   実験は `experimental/*` worktree 可。**main を直接壊さない**。マージ・push は明示指示時。
8. **小さく積む**
   1 作業単位 = 1 章の一部 or 1 Issue チェック項目。コミットメッセージは「なぜ」を含める。

### 1.3 エージェント作業プロトコル

```
1. plan.md を読む（本ファイル）
2. 必要なら README / 対象 Issue / 対象 books|code を読む
3. 予定を「作業予定」に追記（未着手→進行中）
4. 実装（worktree 指定があればそこだけ）
5. mise run ci:test（コードに触れた場合）
6. 「作業進捗」に結果を追記（完了日・コミット・残件）
7. ユーザーが求めたときだけ commit / merge / push
```

### 1.4 やってよい / いけない（要約）

| よい | いけない |
|------|----------|
| books / code / drafts / plan の更新 | 承認なしの `config.yaml` chapters 追加 |
| ASL での実験・テスト追加 | メイン worktree を無視した main 直破壊 |
| README へのリンクで足りる説明 | 目次を別ファイルに再分裂 |
| ユーザー指示での commit/push | 秘密情報の commit |

 よい　　リスト表記
 いけない　図表　崩れるため　このplan.md も含めて

---

## 2. マイルストーン

### Phase 現状（2026-07）

| ID | 目標 | 状態 |
|----|------|------|
| M0 | リポジトリ scaffold・Zenn 骨格・mise wt | **完了** |
| M1 | ASL 方針・#1・ch01/ch04/ch05 実験ドラフト | **完了**（main 取込済） |
| M2 | 目次一本化（README）・outline 廃止 | **完了** |
| M3 | plan.md による作業駆動 | **進行中**（本ファイル作成） |
| M4 | 第5章の肉付け（パルサー等）・表示の磨き | 未着手 |
| M5 | 第2–3章ドラフト（再帰・グリッド） | 未着手 |
| M6 | Zenn chapters 拡張（ユーザー承認ゲート） | 未着手 |
| M7 | 付録 D/F の本文化・EPUB 通し | 未着手（9月 Kindle 目標は #27 系） |

7月末成功定義の詳細 → [README.md](./README.md)「7月末の成功定義」。

### 関連 Issue マップ（取り込み先のリマインダ）

| Issue | 優先 | plan 上の扱い |
|-------|------|----------------|
| 本repo #1 ASL | p0 | 方針は反映済。残チェックは進捗表で管理 |
| my-grok-task #27 | マスター | スコープ・成功定義の上位 |
| #28 HtDP | 中 | 第1–2・付録D の肉付け時 |
| #29 GoL | 中 | 第4–5 の深化 |
| #30 数学 | 低（本線外可） | 付録G / 1.6 メモ |

---

## 3. 作業予定（バックログ）

優先度: P0 > P1 > P2。エージェントは上から拾い、着手時に状態を更新する。

| ID | 優先 | 内容 | 状態 | メモ |
|----|------|------|------|------|
| P-01 | P0 | `plan.md` をルートに置き作業駆動の起点にする | **完了** | 本ファイル |
| P-02 | P0 | コード変更時は必ず `ci:test` を通す運用を継続 | 継続 | README のタスク参照 |
| P-03 | P1 | 第5章: `pattern-pulsar` 座標の本実装 + check-expect | **完了** | Issue #2 |
| P-04 | P1 | 第4章: テスト観点の文章と ASL コードの用語を完全一致 | **完了** | Issue #2 |
| P-05 | P1 | 第2章ドラフト（再帰・map/filter）+ 可能なら code | **完了** | Issue #2 / ch02-recursion.rkt |
| P-06 | P2 | 第3章ドラフト（グリッド・posn リスト以外の表現） | 未着手 | |
| P-07 | P2 | 付録 D 環境構築の独立 md 化（要なら） | 未着手 | 今は README メモで可 |
| P-08 | P2 | Zenn: ch01 を chapters に載せる案をユーザー承認取り | 未着手 | **承認必須** |
| P-09 | P2 | Issue #1 チェックリストを進捗に合わせてコメント/クローズ判断 | 未着手 | ユーザー判断 |
| P-10 | P2 | EPUB 通し（`book:epub`）の定期 verify | 未着手 | pandoc 前提 |
| **P-11** | **P0** | **howtocode 準拠で README + books ドラフト全面見直し（§7）** | **完了** | 承認後実行 |
| P-12 | P0 | 言語: ASL → **BSL**（code/*.rkt・README 言語方針） | **完了** | `#lang htdp/bsl` |
| P-13 | P0 | 序章を howtocode intro/install/expressions ベースで書き直し | **完了** | intro.md |
| P-14 | P0 | 第1章を howtocode cheatsheet ベースで書き直し | **完了** | ch01 |
| P-15 | P1 | 第2章以降に HtDP テンプレート方針を埋め込み | **完了** | ch02–ch05 |
| P-16 | P1 | ch02–ch05 コードを BSL 可能範囲で書き換え / 不能箇所を注記 | **完了** | 構造的再帰 |

---

## 7. 書き換えプラン（ユーザーコメント 2026-07-23）

> 出典: README 末尾 `## assert : user wirte 0723`
> **実行はユーザー承認後**。承認後: experimental で実装 → `ci:test` → commit → push → SE チェック。

### 7.1 ユーザー意図の要約

| # | 発言 | 解釈 |
|---|------|------|
| 1 | 序章と第1章が気に入らない | 現行ドラフトのトーン・構成を破棄寄りで再設計 |
| 2 | howtocode を参考 | [howtocode.pages.dev](https://howtocode.pages.dev/) を**教材スタイルの正**に近い参照にする |
| 3 | 使用言語を **BSL** へ | `#lang htdp/bsl`（Beginning Student）。Issue #1 の ASL 第一を撤回 |
| 4 | 途中で Advanced へ変えるかも | 章が進んだら `htdp/isl` / `asl` への**段階昇格**を README/plan に余地として残す |
| 5 | 序章 ← intro / installation / expressions | 動機・環境・式と評価規則を厚くする |
| 6 | 第1章 ← cheatsheet | 構文チート（データ・式・define・if/cond・関数・struct）中心 |
| 7 | 第2章以降 ← htdp_templates | **データ定義→テンプレ→シグネチャ→例→本体**を章の骨格に |
| 8 | README と books の md を書き直すプランを plan に | 本節。実行は承認後 |

### 7.2 現状ギャップ（なぜ書き直すか）

| 領域 | 現状 | howtocode / BSL とのずれ |
|------|------|---------------------------|
| 言語 | `#lang htdp/asl`（ch01–05） | BSL では `lambda`・一部 `local` パターン・自由な高階が制限される |
| 序章 | ライフゲーム動機が先・インストールが薄い | intro は「他言語のノイズ vs 括弧1規則」、installation は DrRacket+**Beginning Student** 明示 |
| 第1章 | GoL 部品（生存判定・近傍）へ早く橋渡し | cheatsheet は汎用構文の地図。GoL は後段の例に落とす方が近い |
| 第2章 | map/filter/foldl + lambda 前提 | BSL では map 等の扱いが ASL と異なる。**リストの自己参照テンプレ**を先に据える |
| 第4–5 | スパース posn リスト + 高階 | BSL でも書けるが `lambda` なしでテンプレ再帰が主になる可能性大 |
| README | ASL 第一を明記 | 言語方針節の書き換えが必須 |

### 7.3 序章の再構成案（取り込む howtocode）

参照: [introduction](https://howtocode.pages.dev/introduction) / [installation](https://howtocode.pages.dev/installation) / [expressions](https://howtocode.pages.dev/expressions)

| 節案 | 内容 | howtocode 対応 |
|------|------|----------------|
| 0.1 なぜ他言語から始めないか | セミコロン・中置・クラス等のノイズ vs 本質（組み合わせ） | introduction “Why not other languages?” |
| 0.2 Racket と一つの構文規則 | `(operator arg …)`、LISP の影響、括弧の理由（短く） | introduction “The Racket Language” / parentheses |
| 0.3 産業での話（任意・短く） | Naughty Dog / Carmack 等は**短く**（本の主軸は GoL） | introduction industry |
| 0.4 環境構築 | ダウンロード、行番号、**Language → Beginning Student** | installation |
| 0.5 式と評価 | 左から・内側から値へ、エラー（外側に演算子）、非正確数 `#i` | expressions |
| 0.6 この本のゴール（GoL） | 既存の「なぜライフゲーム」を**後半**に残す | ドメイン維持 |

著作権: 直コピーせず、**構成・教え方・例題の精神**を取り込み、日本語で再執筆。リンクを参考文献に。

### 7.4 第1章の再構成案（cheatsheet）

参照: [cheatsheet](https://howtocode.pages.dev/cheatsheet)

| 節案 | 内容 |
|------|------|
| 1.1 基本データ | 数・文字列・真偽（`#true`/`#false`） |
| 1.2 式 | 前置記法ルール（序章の復習＋練習） |
| 1.3 `define` 定数 | |
| 1.4 `if` / `cond` | cheatsheet の形 |
| 1.5 関数 `define` | |
| 1.6 `define-struct` 入門 | dog 例 → 後でセル/posn へ |
| 1.7（橋）ライフへの一歩 | 既存の survives?/近傍は**章末の応用**に縮小配置 |

付属コード: `code/ch01-basics.rkt` を **BSL** で全面書き換え。`lambda` 依存を除去。

### 7.5 第2章以降（テンプレート駆動）

参照: [htdp_templates](https://howtocode.pages.dev/htdp_templates)

各関数・各データ型について、howtocode のチェックリストを章の定型にする:

```
Data: Description → Interpretation → Examples → Template
Function: Signature/purpose/stub → check-expect → Template → Body → Review
```

| 章 | テンプレ重点 | 備考 |
|----|--------------|------|
| 第2章 | ListOf の自己参照、`cond`+`empty?`/`first`/`rest` | BSL で再帰を主。高階は ISL 移行時に再導入可 |
| 第3章 | 二次元・struct・不変 | テンプレ表の Compound / Reference |
| 第4章 | 近傍数 Interval、World=ListOf Cell | 生成的再帰は後回し、構造的再帰で next-generation |
| 第5章 | 表示は関数の目的文＋例。big-bang は発展 | HTDW は付録 or 第5後半 |

### 7.6 ファイル別タスク（実行時チェックリスト）

**ブランチ**: `experimental/20260723-mypublish-gol-feat` のみ（main 直編集しない）

- [ ] README: 言語方針 ASL→BSL、howtocode リンク、ユーザーコメント節は「取り込み済」注記 or 整理
- [ ] `books/.../intro.md` 全面書き直し（§7.3）
- [ ] `books/.../ch01-basics.md` 全面書き直し（§7.4）
- [ ] `books/.../ch02-recursion.md` テンプレ中心に再構成（§7.5）
- [ ] `books/.../ch03-grid.md` テンプレ前提の骨子（最低限）
- [ ] `books/.../ch04-life-rules.md` BSL+テンプレ用語に合わせ調整
- [ ] `books/.../ch05-display.md` 同上
- [ ] `code/ch01`〜`ch05` を `#lang htdp/bsl` 化（不能 API は BSL+ または章注で ISL と明記）
- [ ] `drafts/` を books と同期
- [ ] `mise run ci:test`（または racket 全ファイル）緑
- [ ] plan 進捗ログ更新
- [ ] **git commit**（experimental）
- [ ] **git push** origin experimental（承認内容に含む場合）
- [ ] SE チェック: ブランチ・clean・test・言語ヘッダ

### 7.7 リスクと方針判断（承認時に確認したい点）

| 論点 | 提案（デフォルト） |
|------|-------------------|
| BSL で `map`/`filter`/`lambda` が要る箇所 | 第2章は構造的再帰で書き、高階は「Intermediate への予告」 |
| `posn` | BSL の `make-posn` を維持（チートシート struct の後で導入） |
| Issue #1（ASL）との関係 | README に「#1 は実験、#ユーザー0723 で BSL に転換」と明記 |
| main へいつマージするか | experimental で一通り緑＋ユーザー確認後 |
| 直訳コピペ | しない。構成と演習の型だけ借りる |

### 7.8 承認後の実行順序（エージェント）

1. README 言語方針を BSL に更新
2. intro.md → ch01 → code/ch01
3. ch02 + code/ch02（テンプレ）
4. ch03 骨子 → ch04/ch05 調整 + code
5. drafts 同期・ci:test
6. commit / push（指示どおり）
7. SE チェック表を報告

---

## 4. 作業進捗（ログ）

新しいエントリを**上に**足す（新しいほど上）。

### 2026-07-23

| 時刻帯 | 内容 | 結果 |
|--------|------|------|
| — | **Issue #3**: ch03–05 ドラフト仕上げ・付録D独立md | experimental commit 予定（push なし） |
| — | **§7 承認後実行**: BSL 転換 + howtocode 準拠で README/books/code 書き直し → commit/push | 完了（本作業） |
| — | README ユーザーコメント解析。howtocode 参照。**BSL 転換・章書き直しプランを §7 に記載** | プラン作成済 |

| — | **Issue #2**: P-03 パルサー + P-04 ch04 用語 + P-05 第2章ドラフト/code | experimental commit `0a577d2`（ASL のまま） |
| — | worktree で ch04/ch05 ドラフト + rackunit 実験 → ASL 化 | 完了。`#lang htdp/asl` + check-expect |
| — | Issue #1 読み取り・承認後に README/目次/コード/outline 更新 | 完了 |
| — | README 目次・mise `ci:test` / `watch:test`・main マージ・push | 完了（merge `63a4065` 系） |
| — | outline.md 削除、付録を README へ統合 | 完了（`c9d775c`） |
| — | **plan.md 作成**（作業予定・進捗・駆動方針） | 完了 |

**現状スナップショット**

- 目次正本: README のみ
- コード: ch01–ch05 は **`#lang htdp/bsl`**
- 教材スタイル: howtocode（intro/cheatsheet/templates）
- Zenn chapters: `intro` のみ
- **次**: ユーザーによる本文レビュー、必要なら main マージ

---

## 5. 直近の次アクション（エージェント用チェックリスト）

次のセッション開始時:

- [ ] 本ファイル「作業予定」の未着手 P0/P1 を確認
- [ ] ユーザー指示が Issue / 章番号を含むか確認
- [ ] コードを触るなら作業後 `mise run ci:test`
- [ ] 進捗ログに 1 行以上追記
- [ ] README と矛盾する目次・方針を書かない（矛盾時は README を優先し plan を直す）

---

## 6. 変更履歴（plan.md 自身）

| 日付 | 変更 |
|------|------|
| 2026-07-23 | 初版。駆動方針・マイルストーン・バックログ・進捗ログ |
| 2026-07-23 | §7 howtocode/BSL 書き換えプラン。駆動方針を BSL 第一に更新 |
