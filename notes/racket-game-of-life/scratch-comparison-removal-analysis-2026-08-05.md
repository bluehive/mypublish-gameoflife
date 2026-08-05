# 解析: Scratch 比較・「裏設定」の文書内露出の除去

- **解析担当**: Grok (Hermes / xai-oauth grok-4.5) — **解析のみ。改訂はしない**
- **改訂担当**: deepseek-v4-flash（本ファイルを仕様として実行）
- **日付**: 2026-08-05
- **対象リポ**: `bluehive/mypublish-gameoflife`
- **対象パス**: `books/racket-game-of-life/*.md` のみ（code/ は触らない）
- **ベース**: `origin/main` を fetch した最新（またはマージ済み最新）。作業ブランチ新規:
  `experimental/20260805-remove-scratch-bridge`

---

## 1. ユーザー意図（主張）

| 項目 | 内容 |
|------|------|
| **読者レベル（著者側の想定・維持）** | 高校生・Scratch 初心者レベルでも読める難易度・語彙 |
| **文書から消す「裏設定」** | 本文に露出した「中学 Scratch 経験者向けの比較・対応表・コラム・読者ラベル」 |
| **やってはいけないこと** | 難易度を突然上げる／概念説明ごと削除して穴を空ける／Scratch 比較を別章に移すだけ |

**一文**: 難易度は高校・Scratch 初心者向けのまま、**Scratch を踏み台にした説明は本文から消し、BSL/Racket の言葉だけで同じ概念を説明する。**

---

## 2. 現状サマリ（根拠）

`rg -n 'Scratch|スクラッチ'` のヒット（books 配下）:

| ファイル | 件数 | 性質 |
|----------|------|------|
| `ch02-recursion.md` | 5 | **最大塊**: 節見出し＋対応表＋ASCII図＋トレース内の比喩 |
| `appendix-f-debug.md` | 5 | 読者ラベル、F.0 全体、printf 比喩、REPL 比喩 |
| `ch05-display.md` | 2+ | **コラム全体**（big-bang ↔ Scratch イベント） |
| `ch01-basics.md` | 1 | `cond`/`else` の一文比喩 |
| 他 md | 0 | intro / ch03 / ch04 / 他付録に Scratch 文字列なし |

補足:
- `appendix-d-environment.md` L6: 「高校生でも…」→ **高校生言及は残してよい**（Scratch ではない）
- `ch04-life-rules.md` L490: 「高校1年生向け」道しるべ → **残してよい**（Scratch ではない）
- `intro.md`: Scratch 言及なし。変更不要
- `config.yaml`: 変更不要

「比較が多すぎる」の本体は **ch02 の専用節** と **ch05 のコラム** と **appendix-f の Scratch 経験者フレーム**。

---

## 3. 改訂仕様（ファイル別・必須）

### 共通ルール

1. 文字列 `Scratch` / `スクラッチ` を **books/racket-game-of-life/ 配下の md から 0 件**にする（完了条件）。
2. 削除した説明の**教育内容は残す**（基本ケース、else の位置、on-tick 等）。比喩の足場だけ Prim で書き直す。
3. 見出しに「Scratch 経験者向け」「高校1・Scratch…」とあるものは、Scratch 部分を落とすか節ごと再構成。
4. 作業ブランチのみ。main 直接編集禁止。PR を作り **自己マージしない**。
5. `code/`・テスト・他ディレクトリは変更しない。
6. 改訂後 `rg -n 'Scratch|スクラッチ' books/racket-game-of-life` が空であることを確認して PR 本文に書く。
7. 解析メモ `notes/racket-game-of-life/scratch-comparison-removal-analysis-2026-08-05.md` は **残す**（今回の notes 追加は PR に含めてよい）。

---

### 3.1 `ch01-basics.md`（1箇所）

**場所**: 約 L75（`cond` / `else` 説明の末尾）

**現状（問題箇所）**:
> …Scratch の「もし〜なら／でなければ」を何段にも重ねた感じ——具体的な場合を上に並べ、最後に逃げ道の `else`——が `cond` の基本形です。

**改訂**:
- Scratch 文を削除。
- 同じ意味を BSL だけで1〜2文。例:
  > 具体的な場合を上から順に書き、どれにも当てはまらないときの逃げ道を最後の `else` に置く——それが `cond` の基本形です。

---

### 3.2 `ch02-recursion.md`（主戦場）

#### (A) 削除対象ブロック（約 L253–290）

見出しから図の直後まで:

```
##### Scratch の繰り返しと、再帰の対応（高校1・Scratch 経験者向け）
...
止まる枝を書き忘れると、Scratch の「ずっと」に近い事故になります。
```

**置換方針**（節は残して中身を非 Scratch 化）:

- 見出し案: `##### くり返しと再帰——止まる条件が要る`
- 内容: 「回数くり返し」「条件が満ちるまでくり返し」「止まらないくり返し」を**一般語**で対比し、リスト再帰は「止まる条件（基本ケース）＋残りを同じ関数に任せる」と説明。
- Scratch のブロック名・「ずっと」「〜まで繰り返す」の**製品固有名は使わない**（必要なら「条件が真になるまでくり返す」と一般化）。
- ASCII 対応図は **BSL 側だけの流れ図**に差し替え（左に Scratch: を置かない）。

#### (B) 約 L338 トレースのポイント1

**現状**: `（Scratch で残りをくり返す感じ）`  
**改訂**: 括弧ごと削除、または `（残りリストに同じ手順を適用する）` に置換。

#### (C) その前後

- L290 付近の「Scratch の『ずっと』に近い事故」→「止まらないくり返し（無限ループ）になる」等。
- `factorial` / `my-length` / `sum-list` のコード例とトレース本体は**維持**（Scratch 非依存）。

---

### 3.3 `ch05-display.md`

**場所**: 約 L331 からコラム終わり（「既に知っている操作を Racket の定型に載せ替える…」まで、おおよそ L331–L348 前後）

**現状見出し**: `**コラム: Scratch でやっていたこと ↔ big-bang**`

**改訂**:
- コラムごと **削除**するか、次の非 Scratch コラムに置換:
  - 見出し案: `**コラム: イベントと big-bang（対応の見取り図）**`
  - 中身: 時間経過 → `on-tick`、画面更新 → `to-draw`、キー → `on-key`、起動時の初期状態 → `(big-bang 初期 …)` を**一般的なインタラクティブプログラム**の言葉で説明。
  - 「中学の Scratch」「スプライト」「コスチューム」「旗が押されたとき」は**出さない**。
  - 直後の「ライフへの対応イメージ」「ドメイン分析」は有用なら残す（Scratch 語が無ければそのまま）。

- 文「5.6 は…既に知っている操作を…載せ替える」は、Scratch 前提なので  
  「5.6 は big-bang の部品名とライフの対応を先に掴む見取り図」程度に中立化。

---

### 3.4 `appendix-f-debug.md`

| 箇所 | 現状 | 改訂 |
|------|------|------|
| 冒頭 L7 | `高校1年（Scratch 約20時間）` | `高校1年向け。難しい道具は後回しにし、まず安全な方法から。`（時間数・Scratch 削除） |
| `#### F.0 …（Scratch 経験者向け）` | 見出し＋「Scratch でも…」リスト | 見出し: `#### F.0 まず心がけること`。本文は一般的デバッグ3点（切り分け・今の値・小さな例）のみ。Scratch 文削除 |
| L28 printf 説明 | Scratch 緑ブロック＋「言う」比喩 | BSL は式＝計算であり、計算の途中に画面出力を挟めない、と**直接説明**（比喩は日常語可、Scratch 不可） |
| L56 | `Scratch の「緑の旗で全部動かす」より…` | `最初から全体を一度に動かすより、部品を単体で試すイメージです。` |

F.1 以降の BSL/REPL/トレースの実質内容は維持。

---

### 3.5 触らないファイル

- `intro.md`, `ch03-grid.md`, `ch04-life-rules.md`（高校1向け道しるべは可）, `appendix-a/d/h/i`, `config.yaml`
- ただし完了前に全 md で `Scratch|スクラッチ` 再検索し、漏れがあれば同様処理

---

## 4. 作業手順（flash 実行用チェックリスト）

```text
[ ] 1. cd ~/my-project/mypublish-gameoflife
[ ] 2. git fetch origin && git checkout main && git pull
[ ] 3. git checkout -b experimental/20260805-remove-scratch-bridge
[ ] 4. 上記 3.1–3.4 を patch/編集
[ ] 5. rg -n 'Scratch|スクラッチ' books/racket-game-of-life  → 出力空
[ ] 6. notes に本解析を含める（未コミットなら add）
[ ] 7. git add 対象のみ → commit
[ ] 8. git push -u origin HEAD
[ ] 9. gh pr create（タイトル例下記）。自己マージしない
[ ] 10. ユーザーへ PR URL を報告（Telegram 可）
```

**commit message 案**:
```
docs(books): Scratch 比較・経験者向けブリッジを本文から除去

読者難易度（高校・入門）は維持し、Scratch 対応表・コラム・ラベルを
BSL ネイティブ説明へ置換。解析: notes/.../scratch-comparison-removal-analysis-2026-08-05.md
```

**PR タイトル案**:
`docs(books): Scratch 比較ブリッジを除去（高校入門の難易度は維持）`

**PR 本文に含めること**:
- 動機（裏設定の露出過多）
- 変更ファイル一覧
- 完了条件: Scratch 文字列 0 件のコマンド結果
- 自己マージしない旨

---

## 5. 検証コマンド

```bash
rg -n 'Scratch|スクラッチ' books/racket-game-of-life
# 期待: マッチなし (exit 1)
wc -l books/racket-game-of-life/ch01-basics.md \
  books/racket-game-of-life/ch02-recursion.md \
  books/racket-game-of-life/ch05-display.md \
  books/racket-game-of-life/appendix-f-debug.md
```

---

## 6. 解析者コメント（論拠）

- 序章は既に howtocode / HtDP ベースで Scratch 非依存 → 触らないのが正しい。
- 比較の密度が不自然なのは「学習の本線」ではなく「移行期の足場」が本文に残ったため。足場は notes や別冊に逃がさず、**本線を BSL だけで自立**させるのが今回の要求。
- 高校生ラベル自体は対象読者の明示として有用。消すのは **Scratch という固有前提の露出**。
