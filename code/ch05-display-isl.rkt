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

;; ------------------------------------------------------------
;; 有名パターン（定数）
;; ------------------------------------------------------------

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

;; place: ListOfPosn Number Number -> ListOfPosn
;; すべての生存セルを横に dx・縦に dy だけずらした新しいリストを返す。
;; 元のリストは書き換えない（関数型）。
;; ISL+ の map + lambda で「各 posn に同じ変換」を書く例でもある。
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

;; survives?: Number -> Boolean
;; 近傍の生存数が、生存条件（2 または 3）を満たすか
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

;; births?: Number -> Boolean
;; 近傍の生存数が、誕生条件（ちょうど 3）を満たすか
(define (births? neighbors)
  (= neighbors 3))

;; next-alive?: Boolean Number -> Boolean
;; 今の生死 currently-alive? と近傍数 neighbors から、次世代も生えるか
;; 今生なら survives?、今死なら births? に振り分ける（ルール全体の入口）
(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

;; shift-cell: Posn Number Number -> Posn
;; 座標 cell を (dx, dy) ずらした新しい posn（元は不変）
(define (shift-cell cell dx dy)
  (make-posn (+ (posn-x cell) dx)
             (+ (posn-y cell) dy)))

;; cell-neighbors: Posn -> ListOfPosn
;; 中心 cell の 8 近傍をリストで返す（中心自身は含めない）
;; 向きの対応:
;;   NW N NE     (-1,-1) (0,-1) (1,-1)
;;    W  ·  E    (-1, 0)   C    (1, 0)
;;   SW S SE     (-1, 1) (0, 1) (1, 1)
(define (cell-neighbors cell)
  (list (shift-cell cell -1 -1)
        (shift-cell cell 0 -1)
        (shift-cell cell 1 -1)
        (shift-cell cell -1 0)
        (shift-cell cell 1 0)
        (shift-cell cell -1 1)
        (shift-cell cell 0 1)
        (shift-cell cell 1 1)))

;; member-posn?: Posn ListOfPosn -> Boolean
;; cell が生存リスト cells に含まれるか（所属判定・第2章のリスト再帰）
(define (member-posn? cell cells)
  (cond
    [(empty? cells) false]
    [(equal? cell (first cells)) true]
    [else (member-posn? cell (rest cells))]))

;; count-alive-in: ListOfPosn ListOfPosn -> Number
;; neighbors のうち、live に含まれる個数を数える
;; （「近傍リスト」を走査し、盤 live にいるものだけ +1）
(define (count-alive-in neighbors live)
  (cond
    [(empty? neighbors) 0]
    [(member-posn? (first neighbors) live)
     (+ 1 (count-alive-in (rest neighbors) live))]
    [else (count-alive-in (rest neighbors) live)]))

;; count-neighbors: Posn ListOfPosn -> Number
;; 中心 cell の周囲 8 マスのうち、live 上で生きている個数（0〜8）
(define (count-neighbors cell live)
  (count-alive-in (cell-neighbors cell) live))

;; add-unique: Posn ListOfPosn -> ListOfPosn
;; x が xs に無ければ先頭に足す（重複なし集合の追加）
(define (add-unique x xs)
  (cond
    [(member-posn? x xs) xs]
    [else (cons x xs)]))

;; union-list: ListOfPosn ListOfPosn -> ListOfPosn
;; リスト a の要素を、重複なく b に合流させる
(define (union-list a b)
  (cond
    [(empty? a) b]
    [else (union-list (rest a) (add-unique (first a) b))]))

;; add-neighbors-of: Posn ListOfPosn -> ListOfPosn
;; cell の 8 近傍を acc に重複なく足す
(define (add-neighbors-of cell acc)
  (union-list (cell-neighbors cell) acc))

;; fold-add-neighbors: ListOfPosn ListOfPosn -> ListOfPosn
;; cells の各要素について近傍を acc に足していく（蓄積再帰）
(define (fold-add-neighbors cells acc)
  (cond
    [(empty? cells) acc]
    [else (fold-add-neighbors (rest cells)
                              (add-neighbors-of (first cells) acc))]))

;; candidate-cells: ListOfPosn -> ListOfPosn
;; 次世代で生死を判定すべき座標の候補
;; = 今の生存 live そのもの ∪ 各生存の 8 近傍
;; （誕生は「今死んでいるが隣に3生」なので、生存の隣まで見ないと取りこぼす）
(define (candidate-cells live)
  (fold-add-neighbors live live))

;; filter-next: ListOfPosn ListOfPosn -> ListOfPosn
;; 候補 candidates のうち、現在の盤 live のもとで next-alive? が true の
;; ものだけを残す（BSL に filter が無いときの構造的再帰版）
(define (filter-next candidates live)
  (cond
    [(empty? candidates) empty]
    [(next-alive? (member-posn? (first candidates) live)
                  (count-neighbors (first candidates) live))
     (cons (first candidates)
           (filter-next (rest candidates) live))]
    [else (filter-next (rest candidates) live)]))

;; next-generation: ListOfPosn -> ListOfPosn
;; 盤を 1 世代だけ進める（本線・第4章の入口と同じ役割）
(define (next-generation cells)
  (filter-next (candidate-cells cells) cells))

;; step-n: ListOfPosn Number -> ListOfPosn
;; next-generation を n 回繰り返す。n<=0 ならそのまま cells
(define (step-n cells n)
  (cond
    [(<= n 0) cells]
    [else (step-n (next-generation cells) (- n 1))]))

;; ---- 盤の比較（テスト用）----
;; リストの順序が違っても「同じ生存集合」なら true にしたい。
;; そこで座標を決まった順に並べてから equal? する。

;; cell<?: Posn Posn -> Boolean
;; ソート用の順序: x が小さい方が先。x 同じなら y が小さい方が先
(define (cell<? a b)
  (cond
    [(< (posn-x a) (posn-x b)) true]
    [(> (posn-x a) (posn-x b)) false]
    [else (< (posn-y a) (posn-y b))]))

;; insert-cell: Posn ListOfPosn -> ListOfPosn
;; ソート済みリスト sorted に c を順序を保って挿入
(define (insert-cell c sorted)
  (cond
    [(empty? sorted) (list c)]
    [(cell<? c (first sorted)) (cons c sorted)]
    [else (cons (first sorted) (insert-cell c (rest sorted)))]))

;; sort-cells: ListOfPosn -> ListOfPosn
;; 生存リストを cell<? の順に並べ直す
(define (sort-cells cells)
  (cond
    [(empty? cells) empty]
    [else (insert-cell (first cells) (sort-cells (rest cells)))]))

;; same-world?: ListOfPosn ListOfPosn -> Boolean
;; 2 つの盤が、順序を無視して同じ座標集合か
(define (same-world? a b)
  (equal? (sort-cells a) (sort-cells b)))

;; ------------------------------------------------------------
;; ASCII 表示（このファイルの主目的）
;; ------------------------------------------------------------
;; ビューポート（のぞき窓）:
;; - origin-x, origin-y … 窓の左上に対応する盤上の座標
;; - width, height      … 窓の幅・高さ（マス数＝文字数）
;; 各マス: 生存なら "#"、死（リストに無い）なら "."

;; char-at: ListOfPosn Number Number -> String
;; 座標 (x,y) が live にいれば "#"、いなければ "."
(define (char-at live x y)
  (if (member-posn? (make-posn x y) live) "#" "."))

;; row-string: ListOfPosn Number Number Number -> String
;; 行 y について、列 origin-x から width マス分を1本の文字列にする。
;; ISL+ の書き方:
;; - build-list width (lambda (i) i)  … 0,1,...,width-1 のリスト
;; - map で各列 i の文字を作り
;; - foldr string-append で左から右へ連結
(define (row-string live origin-x y width)
  (foldr string-append
         ""
         (map (lambda (i)
                (char-at live (+ origin-x i) y))
              (build-list width (lambda (i) i)))))

;; world->rows: ListOfPosn Number Number Number Number -> ListOfString
;; 盤 cells を、ビューポート内の「行のリスト」に変換する。
;; 第1要素が上の行、各要素が "#"/"." の文字列（本線 world->rows と同役割）
(define (world->rows cells origin-x origin-y width height)
  (map (lambda (j)
         (row-string cells origin-x (+ origin-y j) width))
       (build-list height (lambda (j) j))))

;; rows->text: ListOfString -> String
;; 行リストを改行 "\n" でつないだ1本の文字列にする。
;; これがあるとターミナルに出したとき升目に見える。
(define (rows->text rows)
  (cond
    [(empty? rows) ""]
    [(empty? (rest rows)) (first rows)]
    [else (string-append (first rows) "\n" (rows->text (rest rows)))]))

;; world->text: ListOfPosn Number Number Number Number -> String
;; world->rows のあと rows->text する便利関数
(define (world->text cells origin-x origin-y width height)
  (rows->text (world->rows cells origin-x origin-y width height)))

;; world-banner: String ListOfPosn Number Number Number Number -> String
;; 見出し title の下に升目テキストを付けたブロック（末尾に改行あり）
(define (world-banner title cells origin-x origin-y width height)
  (string-append title
                 "\n"
                 (world->text cells origin-x origin-y width height)
                 "\n"))

;; generation-banner: Number ListOfPosn Number Number Number Number -> String
;; 世代番号 n を見出しにした升目ブロック
;; 例: ";; --- generation 3 ---" の下に 12×10 の盤
(define (generation-banner n cells origin-x origin-y width height)
  (world-banner
   (string-append ";; --- generation "
                  (number->string n)
                  " ---")
   cells origin-x origin-y width height))

;; generations-text:
;;   ListOfPosn Number Number Number Number Number -> String
;; 世代 0 から max-n までを順に連結した長い文字列を返す。
;; - 各世代: generation-banner で升目化
;; - 次の世代: next-generation で盤を1つ進める
;; local 内の loop は (世代番号, 今の盤, これまでの文字列) を回す蓄積再帰
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
