;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; =============================================================================
;; 付録 H / Issue #11 — ライフゲーム純ロジック（壁境界・GUI なし）
;; =============================================================================
;;
;; 【なにをするファイルか】
;;   コンウェイのライフゲーム（規則 B3/S23）を、有限盤＋壁境界で計算する。
;;   描画は持たない。Sketching 側（sketching-gliders.rkt）やテストから require する。
;;
;; 【デザインレシピの順】（howtocode / HtDP 流）
;;   データ定義 → 解釈 → シグネチャ・目的 → 本体 →（テストは別ファイル）
;;
;; 【境界の意味（壁）】
;;   ・盤の外にはセルが存在しない（トーラス＝周期境界ではない）
;;   ・盤外の近傍は常に「死」として数える
;;   ・端にぶつかったグライダーはやがて形を崩して消える
;;
;; 【実行】
;;   単体では何も表示しない。テストは:
;;     racket code/life-engine-test.rkt
;;
;; =============================================================================

#lang racket

(require lang/posn)

(provide GRID-WIDTH
         GRID-HEIGHT
         GLIDER
         survives?
         births?
         next-alive?
         in-bounds?
         shift-cell
         cell-neighbors
         member-posn?
         count-neighbors/wall
         next-generation/wall
         place-cells
         place-glider
         three-gliders-world
         same-world?
         step-n/wall
         sort-cells)

;; ------------------------------------------------------------
;; 盤の大きさ（Issue #11 で確定: 60×40）
;; ------------------------------------------------------------

(define GRID-WIDTH 60)  ; 横方向のセル数
(define GRID-HEIGHT 40) ; 縦方向のセル数

;; 南東へ進む標準グライダー（第4章 ch04-life-rules.rkt と同じ形）。
;; 相対座標。実際の位置へは place-glider で平行移動する。
;;
;;   . O .
;;   . . O
;;   O O O
(define GLIDER
  (list (make-posn 1 0)
        (make-posn 2 1)
        (make-posn 0 2)
        (make-posn 1 2)
        (make-posn 2 2)))

;; ------------------------------------------------------------
;; データ: Neighbors は 0〜8 の整数
;; 解釈: あるセルの周囲 8 マス（ムーア近傍）のうち、生きている個数
;; ------------------------------------------------------------

;; survives? : Integer -> Boolean
;; いま生きているセルが、次世代も生き残るか（近傍が 2 または 3）。
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

;; births? : Integer -> Boolean
;; いま死んでいるセルが、次世代に誕生するか（近傍がちょうど 3）。
(define (births? neighbors)
  (= neighbors 3))

;; next-alive? : Boolean Integer -> Boolean
;; 現在の生死と近傍数から、次世代に生きているべきかを決める（B3/S23）。
(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

;; ------------------------------------------------------------
;; データ: Cell は Posn
;; 解釈: 盤上の格子座標（x は右、y は下方向の整数）
;;
;; データ: World は (Listof Posn)
;; 解釈: 「いま生きているセル」だけのリスト。死セルは載せない（疎な表現）。
;; ------------------------------------------------------------

;; in-bounds? : Posn Integer Integer -> Boolean
;; 壁境界: 有効な座標は 0 ≤ x < width かつ 0 ≤ y < height のみ。
(define (in-bounds? cell width height)
  (and (<= 0 (posn-x cell) (sub1 width))
       (<= 0 (posn-y cell) (sub1 height))))

;; shift-cell : Posn Integer Integer -> Posn
;; セルを (dx, dy) だけ平行移動した新しい Posn を返す。
(define (shift-cell cell dx dy)
  (make-posn (+ (posn-x cell) dx)
             (+ (posn-y cell) dy)))

;; cell-neighbors : Posn -> (Listof Posn)
;; 周囲 8 マスの座標リスト。盤外の座標もそのまま含み得る（壁判定は呼び出し側）。
(define (cell-neighbors cell)
  (list (shift-cell cell -1 -1)
        (shift-cell cell 0 -1)
        (shift-cell cell 1 -1)
        (shift-cell cell -1 0)
        (shift-cell cell 1 0)
        (shift-cell cell -1 1)
        (shift-cell cell 0 1)
        (shift-cell cell 1 1)))

;; member-posn? : Posn (Listof Posn) -> Boolean
;; 座標 cell がリスト cells に含まれるか（equal? による比較）。
(define (member-posn? cell cells)
  (cond
    [(empty? cells) #f]
    [(equal? cell (first cells)) #t]
    [else (member-posn? cell (rest cells))]))

;; count-neighbors/wall : Posn (Listof Posn) Integer Integer -> Integer
;; 壁付き近傍カウント。盤外のマスは数えない（＝常に死）。
(define (count-neighbors/wall cell live width height)
  (for/sum ([n (in-list (cell-neighbors cell))])
    (if (and (in-bounds? n width height)
             (member-posn? n live))
        1
        0)))

;; --- 次世代の候補セル（生きているセル ∪ その盤内近傍）---

;; add-unique : Posn (Listof Posn) -> (Listof Posn)
;; x が xs に無ければ先頭に cons。重複を避ける集合的追加。
(define (add-unique x xs)
  (if (member-posn? x xs) xs (cons x xs)))

;; union-list : (Listof Posn) (Listof Posn) -> (Listof Posn)
;; リスト a の要素を b に重複なく合流させる。
(define (union-list a b)
  (cond
    [(empty? a) b]
    [else (union-list (rest a) (add-unique (first a) b))]))

;; add-neighbors-of/wall : Posn (Listof Posn) Integer Integer -> (Listof Posn)
;; cell の近傍のうち盤内だけを acc に合流。
(define (add-neighbors-of/wall cell acc width height)
  (define inside
    (filter (λ (n) (in-bounds? n width height))
            (cell-neighbors cell)))
  (union-list inside acc))

;; fold-add-neighbors/wall : ... -> (Listof Posn)
;; 生きセル列の各要素について近傍を畳み込み、候補集合を広げる。
(define (fold-add-neighbors/wall cells acc width height)
  (cond
    [(empty? cells) acc]
    [else
     (fold-add-neighbors/wall
      (rest cells)
      (add-neighbors-of/wall (first cells) acc width height)
      width height)]))

;; candidate-cells/wall : (Listof Posn) Integer Integer -> (Listof Posn)
;; 次世代を判定すべき座標一覧 = 盤内の生きセル + それらの盤内近傍。
(define (candidate-cells/wall live width height)
  (define live-in
    (filter (λ (c) (in-bounds? c width height)) live))
  (fold-add-neighbors/wall live-in live-in width height))

;; filter-next/wall : (Listof Posn) (Listof Posn) Integer Integer -> (Listof Posn)
;; 候補それぞれについて next-alive? を適用し、次世代に生きるセルだけ残す。
(define (filter-next/wall candidates live width height)
  (cond
    [(empty? candidates) '()]
    [(next-alive? (member-posn? (first candidates) live)
                  (count-neighbors/wall (first candidates) live width height))
     (cons (first candidates)
           (filter-next/wall (rest candidates) live width height))]
    [else (filter-next/wall (rest candidates) live width height)]))

;; next-generation/wall : (Listof Posn) Integer Integer -> (Listof Posn)
;; 壁境界の B3/S23 を 1 世代進めた新しいワールドを返す（破壊的更新はしない）。
(define (next-generation/wall cells width height)
  (filter-next/wall (candidate-cells/wall cells width height)
                    cells
                    width
                    height))

;; ------------------------------------------------------------
;; 配置ヘルパ
;; ------------------------------------------------------------

;; place-cells : (Listof Posn) Integer Integer -> (Listof Posn)
;; パターン全体を (dx, dy) だけずらす。
(define (place-cells cells dx dy)
  (for/list ([c (in-list cells)])
    (make-posn (+ (posn-x c) dx)
               (+ (posn-y c) dy))))

;; place-glider : Integer Integer -> (Listof Posn)
;; 相対パターン GLIDER を (x, y) 付近に置いた 5 セルを返す。
(define (place-glider x y)
  (place-cells GLIDER x y))

;; three-gliders-world : -> (Listof Posn)
;; 60×40 盤向け。互いに干渉しにくい位置にグライダー 3 機。
;;   (2,2) / (20,8) / (40,15)
(define (three-gliders-world)
  (append (place-glider 2 2)
          (place-glider 20 8)
          (place-glider 40 15)))

;; ------------------------------------------------------------
;; テスト用ヘルパ（順序を無視した盤の比較・N 世代実行）
;; ------------------------------------------------------------

;; cell<? : Posn Posn -> Boolean
;; ソート用の全順序（先に x、同点なら y）。
(define (cell<? a b)
  (cond
    [(< (posn-x a) (posn-x b)) #t]
    [(> (posn-x a) (posn-x b)) #f]
    [else (< (posn-y a) (posn-y b))]))

;; insert-cell / sort-cells : 挿入ソートで座標リストを正規化
(define (insert-cell c sorted)
  (cond
    [(empty? sorted) (list c)]
    [(cell<? c (first sorted)) (cons c sorted)]
    [else (cons (first sorted) (insert-cell c (rest sorted)))]))

(define (sort-cells cells)
  (cond
    [(empty? cells) '()]
    [else (insert-cell (first cells) (sort-cells (rest cells)))]))

;; same-world? : (Listof Posn) (Listof Posn) -> Boolean
;; 順序を無視して、同じ生きセル集合か。
(define (same-world? a b)
  (equal? (sort-cells a) (sort-cells b)))

;; step-n/wall : (Listof Posn) Integer Integer Integer -> (Listof Posn)
;; 壁付き next-generation を n 回適用する。
(define (step-n/wall cells n width height)
  (cond
    [(<= n 0) cells]
    [else (step-n/wall (next-generation/wall cells width height)
                       (sub1 n)
                       width
                       height)]))
