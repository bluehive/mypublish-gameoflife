;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; ============================================================
;; 第5章 発展サンプル: 升目の見やすい表示 ＋ グライダー 0〜8 世代
;; ============================================================
;;
;; 【このファイルの位置づけ】
;; - 本線（必須）: code/ch05-display.rkt  … #lang htdp/bsl
;; - 本ファイル（任意・発展）:            … #lang htdp/isl+
;; - 教科書: books/racket-game-of-life/ch05-display.md §5.2 発展節
;;
;; 【なぜ BSL ではなく ISL+ か】
;; - BSL の相互作用ウィンドウでは、文字列のリストが
;;     (cons "##.." (cons "...." ...))
;;   のように印字され、盤（升目）に見えにくい。
;; - Intermediate Student with lambda（isl+）では map / lambda /
;;   build-list / local が使え、行の組み立てが書きやすい。
;; - さらに 2htdp/batch-io の write-file で、改行つきの升目を
;;   標準出力にそのまま出せる（「目で追う」体験用）。
;;
;; 【言語・公式】
;; - #lang htdp/isl+  = Intermediate Student with lambda
;; - https://docs.racket-lang.org/htdp-langs/intermediate-lam.html
;;
;; 【実行方法】
;; - カレントディレクトリはリポジトリ root であること
;;     racket code/ch05-display-isl.rkt
;; - DrRacket の場合: このファイルを開き、言語レベルを
;;   「Intermediate Student with lambda」に合わせる（#lang と一致）
;;
;; 【ルールエンジンについて】
;; - next-generation などは第4章・本線 ch05 と「同型の抜粋」
;; - 採点・本線の理解は BSL 側で足りる。ここは表示デモ用の複製
;;
;; 【デモが出すもの】
;; 1. 9×9 ビューポートの静止ブロック（中央付近）
;; 2. グライダーを世代 0〜8 まで、12×10 ののぞき窓で連番表示
;;
;; ------------------------------------------------------------
;; 【シグネチャ（署名）について — このファイルの方針】
;; ------------------------------------------------------------
;;
;; 1. シグネチャとは何か
;;    - 「関数がどんな型の引数を何個受け取り、どんな型を返すか」という約束
;;    - コード上は (: 名前 (引数の型 … -> 返り値の型)) と書く
;;    - 例: (: survives? (Number -> Boolean))
;;      意味: 引数1つ（数）→ 返り値は真偽値
;;
;; 2. なぜ書くか
;;    - 人間向けの仕様書になる（読むだけで使い方が分かる）
;;    - DrRacket / 学生言語が、呼び出しが約束と違うとき検査・報告できる
;;    - check-expect と並べると「仕様＋例＋本体」がそろう
;;
;; 3. 理想の型名（コメントで書く）
;;    - Posn … 座標 (make-posn x y)
;;    - ListOfPosn … 生存リスト（データ定義どおり）
;;    - ListOfString … 行のリスト（world->rows の返り値）
;;    - Number / Boolean / String … 組み込み
;;
;; 4. コードの (: …) で使える型（ISL+ / HtDP 学生言語）
;;    - 使える例: Number, Boolean, String, Any, (ListOf Number), (ListOf String) など
;;    - 使えない例: Posn, ListOfPosn（未定義エラーになる）
;;      → 第3章「BSL の (: …) で Posn が使えない」と同じ制約
;;
;; 5. このファイルでの二段書き
;;    - コメント: ;; 理想: ListOfPosn Number Number -> ListOfPosn
;;      （教科書・ノート用の正確な意味）
;;    - コード:   (: place (Any Number Number -> Any))
;;      （実行可能な署名。Posn が出るところは Any で緩める）
;;    - Number / Boolean / String / (ListOf String) だけなら
;;      コメントとコードをほぼ一致させられる
;;
;; 6. 読み方の例
;;    (: next-alive? (Boolean Number -> Boolean))
;;      第1引数 Boolean, 第2引数 Number, 返り値 Boolean
;;    (: world->rows (Any Number Number Number Number -> (ListOf String)))
;;      第1引数は実際は ListOfPosn だが署名上は Any、
;;      返り値は文字列のリスト（各要素が1行）
;; ============================================================

#lang htdp/isl+

;; write-file: 文字列をファイルや標準出力へ書く（表示デモ用）
(require 2htdp/batch-io)
;; check-expect / (test): 仕様テスト
(require test-engine/racket-tests)

;; ------------------------------------------------------------
;; データ定義: 生存セルのリスト（第3–5章本線と同じ）
;; ------------------------------------------------------------
;; ListOfPosn is one of:
;;  - empty
;;  - (cons Posn ListOfPosn)
;; interp. 今生きているマスの座標だけを並べたリスト。
;;         死んでいるマスはリストに載せない（スパース表現）。
;;         例: 空の盤 = empty
;;
;; ※ ListOfPosn / Posn はデータ定義上の名前であり、
;;    (: …) の型名としては使えない（上の「シグネチャ方針」参照）。

;; ------------------------------------------------------------
;; 有名パターン（定数）
;; ------------------------------------------------------------
;; 定数に (: …) は付けない（関数の署名ではない）。

;; pattern-block: 2×2 の静止物（still life）
;; 何世代進めても形が変わらない。本線 pattern-block と同じ配置。
;;   ##
;;   ##
(define pattern-block
  (list (make-posn 0 0) (make-posn 0 1)
        (make-posn 1 0) (make-posn 1 1)))

;; pattern-glider: 宇宙船（spaceship）・周期 4
;; 4 世代で形が戻り、だいたい (1,1) 方向へ平行移動する。
;; 本線 pattern-glider・第4章 glider と同座標。
;; 世代0のイメージ（#=生）:
;;   .#.
;;   ..#
;;   ###
(define pattern-glider
  (list (make-posn 1 0) (make-posn 2 1)
        (make-posn 0 2) (make-posn 1 2) (make-posn 2 2)))

;; place
;; 理想（コメント署名）: ListOfPosn Number Number -> ListOfPosn
;; コード署名:           Any は「実際は ListOfPosn / 各要素は Posn」
;; 引数 cells = 生存リスト, dx/dy = ずらす量
;; 返り値 = 全セルを平行移動した新しいリスト（元は不変）
;; ISL+ の map + lambda で「各 posn に同じ変換」を書く例でもある。
(: place (Any Number Number -> Any))
(define (place cells dx dy)
  (map (lambda (p)
         (make-posn (+ (posn-x p) dx)
                    (+ (posn-y p) dy)))
       cells))

;; block-9: 9×9 ののぞき窓で中央付近に見えるよう、ブロックを (3,3) へ移動
;; 左上が (3,3)(4,3) / (3,4)(4,4) の 2×2 になる。
(define block-9 (place pattern-block 3 3))

;; glider-0: デモ用の初期グライダー
;; 原点ぴったりの pattern-glider だと端に寄りすぎるので、
;; (1,1) だけ内側に置き、世代 0〜8・ビューポート 12×10 で切れにくくする。
(define glider-0 (place pattern-glider 1 1))

;; ------------------------------------------------------------
;; ルールエンジン（B3/S23）— 第4章と同型の抜粋
;; ------------------------------------------------------------
;; ルール名 B3/S23 の意味:
;; - S23: 今生きていて近傍が 2 または 3 → 次も生（Survive）
;; - B3:  今死んでいて近傍がちょうど 3 → 次は生（Birth）
;; - それ以外 → 次は死
;; 近傍は自分を除く周囲 8 マス（ムーア近傍）。
;;
;; ここは引数が Number / Boolean だけなので、(: …) を理想どおり書ける。

;; survives?
;; 署名: Number -> Boolean
;; 引数 neighbors = 近傍の生存数（0〜8）
;; 返り値 = 生存条件（2 または 3）を満たせば true
(: survives? (Number -> Boolean))
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

;; births?
;; 署名: Number -> Boolean
;; 引数 neighbors = 近傍の生存数
;; 返り値 = 誕生条件（ちょうど 3）なら true
(: births? (Number -> Boolean))
(define (births? neighbors)
  (= neighbors 3))

;; next-alive?
;; 署名: Boolean Number -> Boolean
;; 引数1 currently-alive? = 今そのマスが生か
;; 引数2 neighbors = 近傍の生存数
;; 返り値 = 次世代も生なら true
;; 振り分け: 今生 → survives? / 今死 → births?
(: next-alive? (Boolean Number -> Boolean))
(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

;; shift-cell
;; 理想: Posn Number Number -> Posn
;; コード: Any は実際には Posn
;; 引数 cell = 元の座標, dx/dy = ずらし量
;; 返り値 = ずらした新しい posn（元は不変）
(: shift-cell (Any Number Number -> Any))
(define (shift-cell cell dx dy)
  (make-posn (+ (posn-x cell) dx)
             (+ (posn-y cell) dy)))

;; cell-neighbors
;; 理想: Posn -> ListOfPosn
;; コード: Any -> Any（実際は Posn -> 長さ8の ListOfPosn）
;; 中心 cell の 8 近傍（中心自身は含めない）
;;   NW N NE     (-1,-1) (0,-1) (1,-1)
;;    W  ·  E    (-1, 0)   C    (1, 0)
;;   SW S SE     (-1, 1) (0, 1) (1, 1)
(: cell-neighbors (Any -> Any))
(define (cell-neighbors cell)
  (list (shift-cell cell -1 -1)
        (shift-cell cell 0 -1)
        (shift-cell cell 1 -1)
        (shift-cell cell -1 0)
        (shift-cell cell 1 0)
        (shift-cell cell -1 1)
        (shift-cell cell 0 1)
        (shift-cell cell 1 1)))

;; member-posn?
;; 理想: Posn ListOfPosn -> Boolean
;; コード: Any Any -> Boolean（第1=座標, 第2=生存リスト）
;; cell が cells に含まれるか（所属判定・第2章のリスト再帰）
(: member-posn? (Any Any -> Boolean))
(define (member-posn? cell cells)
  (cond
    [(empty? cells) false]
    [(equal? cell (first cells)) true]
    [else (member-posn? cell (rest cells))]))

;; count-alive-in
;; 理想: ListOfPosn ListOfPosn -> Number
;; コード: Any Any -> Number
;; 引数1 neighbors = 調べる座標リスト（例: 8近傍）
;; 引数2 live = 今の生存リスト（盤）
;; 返り値 = neighbors のうち live に含まれる個数
(: count-alive-in (Any Any -> Number))
(define (count-alive-in neighbors live)
  (cond
    [(empty? neighbors) 0]
    [(member-posn? (first neighbors) live)
     (+ 1 (count-alive-in (rest neighbors) live))]
    [else (count-alive-in (rest neighbors) live)]))

;; count-neighbors
;; 理想: Posn ListOfPosn -> Number
;; コード: Any Any -> Number
;; 中心 cell の周囲 8 マスのうち live 上で生きている個数（0〜8）
(: count-neighbors (Any Any -> Number))
(define (count-neighbors cell live)
  (count-alive-in (cell-neighbors cell) live))

;; add-unique
;; 理想: Posn ListOfPosn -> ListOfPosn
;; コード: Any Any -> Any
;; x が xs に無ければ先頭に足す（重複なし）
(: add-unique (Any Any -> Any))
(define (add-unique x xs)
  (cond
    [(member-posn? x xs) xs]
    [else (cons x xs)]))

;; union-list
;; 理想: ListOfPosn ListOfPosn -> ListOfPosn
;; コード: Any Any -> Any
;; a の要素を重複なく b に合流
(: union-list (Any Any -> Any))
(define (union-list a b)
  (cond
    [(empty? a) b]
    [else (union-list (rest a) (add-unique (first a) b))]))

;; add-neighbors-of
;; 理想: Posn ListOfPosn -> ListOfPosn
;; コード: Any Any -> Any
;; cell の 8 近傍を acc に重複なく足す
(: add-neighbors-of (Any Any -> Any))
(define (add-neighbors-of cell acc)
  (union-list (cell-neighbors cell) acc))

;; fold-add-neighbors
;; 理想: ListOfPosn ListOfPosn -> ListOfPosn
;; コード: Any Any -> Any
;; cells の各要素の近傍を acc に蓄積
(: fold-add-neighbors (Any Any -> Any))
(define (fold-add-neighbors cells acc)
  (cond
    [(empty? cells) acc]
    [else (fold-add-neighbors (rest cells)
                              (add-neighbors-of (first cells) acc))]))

;; candidate-cells
;; 理想: ListOfPosn -> ListOfPosn
;; コード: Any -> Any
;; 次世代で判定すべき候補 = 生存 ∪ 各生存の 8 近傍
;; （誕生は「今死×隣3生」なので生存の隣まで見ないと取りこぼす）
(: candidate-cells (Any -> Any))
(define (candidate-cells live)
  (fold-add-neighbors live live))

;; filter-next
;; 理想: ListOfPosn ListOfPosn -> ListOfPosn
;; コード: Any Any -> Any
;; 候補のうち next-alive? が true のものだけ残す
;; （構造的再帰。ISL+ なら filter+lambda でも書けるが、本線と同型を保つ）
(: filter-next (Any Any -> Any))
(define (filter-next candidates live)
  (cond
    [(empty? candidates) empty]
    [(next-alive? (member-posn? (first candidates) live)
                  (count-neighbors (first candidates) live))
     (cons (first candidates)
           (filter-next (rest candidates) live))]
    [else (filter-next (rest candidates) live)]))

;; next-generation
;; 理想: ListOfPosn -> ListOfPosn
;; コード: Any -> Any
;; 盤を 1 世代だけ進める（第4章・本線と同じ入口）
(: next-generation (Any -> Any))
(define (next-generation cells)
  (filter-next (candidate-cells cells) cells))

;; step-n
;; 理想: ListOfPosn Number -> ListOfPosn
;; コード: Any Number -> Any
;; next-generation を n 回。n<=0 なら cells のまま
(: step-n (Any Number -> Any))
(define (step-n cells n)
  (cond
    [(<= n 0) cells]
    [else (step-n (next-generation cells) (- n 1))]))

;; ---- 盤の比較（テスト用）----
;; リストの順序が違っても「同じ生存集合」なら true にしたい。
;; そこで座標を決まった順に並べてから equal? する。

;; cell<?
;; 理想: Posn Posn -> Boolean
;; コード: Any Any -> Boolean
;; ソート順: x が小さい方が先。x 同じなら y が小さい方が先
(: cell<? (Any Any -> Boolean))
(define (cell<? a b)
  (cond
    [(< (posn-x a) (posn-x b)) true]
    [(> (posn-x a) (posn-x b)) false]
    [else (< (posn-y a) (posn-y b))]))

;; insert-cell
;; 理想: Posn ListOfPosn -> ListOfPosn
;; コード: Any Any -> Any
;; ソート済み sorted に c を順序を保って挿入
(: insert-cell (Any Any -> Any))
(define (insert-cell c sorted)
  (cond
    [(empty? sorted) (list c)]
    [(cell<? c (first sorted)) (cons c sorted)]
    [else (cons (first sorted) (insert-cell c (rest sorted)))]))

;; sort-cells
;; 理想: ListOfPosn -> ListOfPosn
;; コード: Any -> Any
(: sort-cells (Any -> Any))
(define (sort-cells cells)
  (cond
    [(empty? cells) empty]
    [else (insert-cell (first cells) (sort-cells (rest cells)))]))

;; same-world?
;; 理想: ListOfPosn ListOfPosn -> Boolean
;; コード: Any Any -> Boolean
;; 順序を無視して同じ座標集合か（check-expect 用）
(: same-world? (Any Any -> Boolean))
(define (same-world? a b)
  (equal? (sort-cells a) (sort-cells b)))

;; ------------------------------------------------------------
;; ASCII 表示（このファイルの主目的）
;; ------------------------------------------------------------
;; ビューポート（のぞき窓）:
;; - origin-x, origin-y … 窓の左上に対応する盤上の座標
;; - width, height      … 窓の幅・高さ（マス数＝文字数）
;; 各マス: 生存なら "#"、死（リストに無い）なら "."
;;
;; 返り値が String / (ListOf String) の関数は、(: …) でその型を書ける。

;; char-at
;; 理想: ListOfPosn Number Number -> String
;; コード: Any Number Number -> String
;; (x,y) が live にいれば "#"、いなければ "."
(: char-at (Any Number Number -> String))
(define (char-at live x y)
  (if (member-posn? (make-posn x y) live) "#" "."))

;; row-string
;; 理想: ListOfPosn Number Number Number -> String
;; コード: Any Number Number Number -> String
;; 行 y を、列 origin-x から width マス分の1文字列にする
;; ISL+: build-list で 0..width-1 → map で文字 → foldr で連結
(: row-string (Any Number Number Number -> String))
(define (row-string live origin-x y width)
  (foldr string-append
         ""
         (map (lambda (i)
                (char-at live (+ origin-x i) y))
              (build-list width (lambda (i) i)))))

;; world->rows
;; 理想: ListOfPosn Number Number Number Number -> ListOfString
;; コード: 返り値だけ (ListOf String) と厳密に書ける
;; 第1要素が上の行。各要素が "#"/"." の文字列
(: world->rows (Any Number Number Number Number -> (ListOf String)))
(define (world->rows cells origin-x origin-y width height)
  (map (lambda (j)
         (row-string cells origin-x (+ origin-y j) width))
       (build-list height (lambda (j) j))))

;; rows->text
;; 署名: (ListOf String) -> String  （理想とコードが一致）
;; 行リストを改行 "\n" でつないだ1本の文字列にする
(: rows->text ((ListOf String) -> String))
(define (rows->text rows)
  (cond
    [(empty? rows) ""]
    [(empty? (rest rows)) (first rows)]
    [else (string-append (first rows) "\n" (rows->text (rest rows)))]))

;; world->text
;; 理想: ListOfPosn Number Number Number Number -> String
;; コード: Any Number Number Number Number -> String
;; world->rows のあと rows->text
(: world->text (Any Number Number Number Number -> String))
(define (world->text cells origin-x origin-y width height)
  (rows->text (world->rows cells origin-x origin-y width height)))

;; world-banner
;; 理想: String ListOfPosn Number Number Number Number -> String
;; コード: String Any Number Number Number Number -> String
;; 見出し title の下に升目（末尾改行あり）
(: world-banner (String Any Number Number Number Number -> String))
(define (world-banner title cells origin-x origin-y width height)
  (string-append title
                 "\n"
                 (world->text cells origin-x origin-y width height)
                 "\n"))

;; generation-banner
;; 理想: Number ListOfPosn Number Number Number Number -> String
;; コード: Number Any Number Number Number Number -> String
;; 世代番号 n を見出しにした升目ブロック
(: generation-banner (Number Any Number Number Number Number -> String))
(define (generation-banner n cells origin-x origin-y width height)
  (world-banner
   (string-append ";; --- generation "
                  (number->string n)
                  " ---")
   cells origin-x origin-y width height))

;; generations-text
;; 理想: ListOfPosn Number Number Number Number Number -> String
;;        cells max-n origin-x origin-y width height
;; コード: Any Number Number Number Number Number -> String
;; 世代 0..max-n を連結。各世代のあと next-generation で盤を進める
;; local の loop: (世代番号, 今の盤, これまでの文字列) の蓄積再帰
(: generations-text (Any Number Number Number Number Number -> String))
(define (generations-text cells max-n origin-x origin-y width height)
  (local [(define (loop n world acc)
            (cond
              [(> n max-n) acc]
              [else
               (loop (add1 n)
                     (next-generation world)
                     (string-append
                      acc
                      (generation-banner n world
                                         origin-x origin-y
                                         width height)))]))]
    (loop 0 cells "")))

;; グライダー連番デモ用のビューポートサイズ（幅×高さ）
;; 原点は (0,0)。8 世代で右下にずれても切れにくいよう 12×10
(define VP-W 12)
(define VP-H 10)

;; ------------------------------------------------------------
;; テスト（仕様の固定）
;; ------------------------------------------------------------
;; Run / racket 実行時に (test) がすべての check-expect を走らせる。
;; 失敗するとデモ出力のあとに失敗内容が出る。
;; シグネチャ違反があれば、それも報告されることがある。

;; 4×4 に置いたブロックの左上 2×2 が "##"
(define rows-4 (world->rows pattern-block 0 0 4 4))
(check-expect rows-4
              (list "##.." "##.." "...." "...."))

;; 9×9 中央付近ブロックの行数と升目
(define rows-9 (world->rows block-9 0 0 9 9))
(check-expect (length rows-9) 9)
(check-expect rows-9
              (list "........."
                    "........."
                    "........."
                    "...##...."
                    "...##...."
                    "........."
                    "........."
                    "........."
                    "........."))

;; グライダーの周期・平行移動（第4章の仕様と同じ）
;; - 4 世代 → 形が戻り (1,1) 進む
;; - 8 世代 → さらに (1,1)、合計 (2,2)
(check-expect
 (same-world? (step-n pattern-glider 4) (place pattern-glider 1 1))
 true)
(check-expect
 (same-world? (step-n glider-0 4) (place glider-0 1 1))
 true)
(check-expect
 (same-world? (step-n glider-0 8) (place glider-0 2 2))
 true)

;; ビューポートの高さは VP-H 行
(check-expect (length (world->rows glider-0 0 0 VP-W VP-H)) VP-H)

;; ------------------------------------------------------------
;; デモ出力
;; ------------------------------------------------------------
;; write-file の第1引数 'stdout は「標準出力へ書く」。
;; トップレベルで複数回 write-file すると、戻り値 'stdout が
;; 余分に印字されやすいので、デモ文字列を1本にまとめて1回だけ書く。

;; デモ1: 9×9 静止ブロック
(define DEMO-BLOCK
  (world-banner ";; --- 9x9 still life (block near center) ---"
                block-9 0 0 9 9))

;; デモ2: グライダー世代 0..8（見出し + generations-text）
(define DEMO-GLIDER-0-8
  (string-append
   ";; === glider generations 0..8 (viewport "
   (number->string VP-W)
   "x"
   (number->string VP-H)
   ", origin 0,0) ===\n"
   (generations-text glider-0 8 0 0 VP-W VP-H)
   ";; === end glider demo ===\n"))

;; 標準出力へ一括表示（ブロック → 空行 → グライダー連番 → 終了行）
(write-file
 'stdout
 (string-append DEMO-BLOCK
                "\n"
                DEMO-GLIDER-0-8
                ";; --- end all demos ---\n"))

;; 全 check-expect を実行（失敗時はここにメッセージ）
(test)
