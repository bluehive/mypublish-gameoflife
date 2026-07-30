;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; =============================================================================
;; 付録 H / Issue #13 — ライフゲーム純ロジック（壁境界・BSL）
;; =============================================================================
;;
;; 【なにをするファイルか】
;;   コンウェイのライフゲーム（規則 B3/S23）を、有限盤＋壁境界で計算する。
;;   描画は持たない。アニメは code/big-bang-gliders.rkt（2htdp/universe）。
;;
;; 【デザインレシピの順】（howtocode / HtDP 流）
;;   データ定義 → 解釈 → シグネチャ・目的 → 本体 → check-expect
;;
;; 【境界の意味（壁）】
;;   ・盤の外にはセルが存在しない（トーラス＝周期境界ではない）
;;   ・盤外の近傍は常に「死」として数える
;;   ・端にぶつかったグライダーはやがて形を崩して消える
;;
;; 【実行】（リポジトリ root から）
;;   racket code/life-engine.rkt
;;
;; =============================================================================

#lang htdp/bsl

(require test-engine/racket-tests)

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

;; survives? : Number -> Boolean
;; いま生きているセルが、次世代も生き残るか（近傍が 2 または 3）。
(: survives? (Number -> Boolean))
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

;; births? : Number -> Boolean
;; いま死んでいるセルが、次世代に誕生するか（近傍がちょうど 3）。
(: births? (Number -> Boolean))
(define (births? neighbors)
  (= neighbors 3))

;; next-alive? : Boolean Number -> Boolean
;; 現在の生死と近傍数から、次世代に生きているべきかを決める（B3/S23）。
(: next-alive? (Boolean Number -> Boolean))
(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

(check-expect (survives? 2) true)
(check-expect (survives? 3) true)
(check-expect (survives? 1) false)
(check-expect (survives? 4) false)
(check-expect (births? 3) true)
(check-expect (births? 2) false)
(check-expect (next-alive? true 2) true)
(check-expect (next-alive? false 3) true)
(check-expect (next-alive? true 0) false)
(check-expect (next-alive? false 2) false)

;; ------------------------------------------------------------
;; データ: Cell は Posn
;; 解釈: 盤上の格子座標（x は右、y は下方向の整数）
;;
;; データ: World は ListOf Posn
;; 解釈: 「いま生きているセル」だけのリスト。死セルは載せない（疎な表現）。
;; ------------------------------------------------------------

;; in-bounds? : Posn Number Number -> Boolean
;; 壁境界: 有効な座標は 0 ≤ x < width かつ 0 ≤ y < height のみ。
(define (in-bounds? cell width height)
  (and (<= 0 (posn-x cell) (- width 1))
       (<= 0 (posn-y cell) (- height 1))))

(check-expect (in-bounds? (make-posn 0 0) GRID-WIDTH GRID-HEIGHT) true)
(check-expect (in-bounds? (make-posn 59 39) GRID-WIDTH GRID-HEIGHT) true)
(check-expect (in-bounds? (make-posn -1 0) GRID-WIDTH GRID-HEIGHT) false)
(check-expect (in-bounds? (make-posn 60 0) GRID-WIDTH GRID-HEIGHT) false)
(check-expect (in-bounds? (make-posn 0 40) GRID-WIDTH GRID-HEIGHT) false)

;; shift-cell : Posn Number Number -> Posn
;; セルを (dx, dy) だけ平行移動した新しい Posn を返す。
(define (shift-cell cell dx dy)
  (make-posn (+ (posn-x cell) dx)
             (+ (posn-y cell) dy)))

;; cell-neighbors : Posn -> ListOf Posn
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

;; member-posn? : Posn ListOfPosn -> Boolean
;; 座標 cell がリスト cells に含まれるか（equal? による比較）。
(define (member-posn? cell cells)
  (cond
    [(empty? cells) false]
    [(equal? cell (first cells)) true]
    [else (member-posn? cell (rest cells))]))

;; count-alive-in/wall : ListOfPosn ListOfPosn Number Number -> Number
;; 近傍リストのうち、盤内かつ live に含まれる個数。
(define (count-alive-in/wall neighbors live width height)
  (cond
    [(empty? neighbors) 0]
    [(and (in-bounds? (first neighbors) width height)
          (member-posn? (first neighbors) live))
     (+ 1 (count-alive-in/wall (rest neighbors) live width height))]
    [else (count-alive-in/wall (rest neighbors) live width height)]))

;; count-neighbors/wall : Posn ListOfPosn Number Number -> Number
;; 壁付き近傍カウント。盤外のマスは数えない（＝常に死）。
(define (count-neighbors/wall cell live width height)
  (count-alive-in/wall (cell-neighbors cell) live width height))

(check-expect
 (count-neighbors/wall (make-posn 0 0) (list (make-posn 0 0)) 5 5)
 0)

;; add-unique : Posn ListOfPosn -> ListOfPosn
(define (add-unique x xs)
  (cond
    [(member-posn? x xs) xs]
    [else (cons x xs)]))

;; union-list : ListOfPosn ListOfPosn -> ListOfPosn
(define (union-list a b)
  (cond
    [(empty? a) b]
    [else (union-list (rest a) (add-unique (first a) b))]))

;; filter-in-bounds : ListOfPosn Number Number -> ListOfPosn
;; 盤内の座標だけ残す。
(define (filter-in-bounds cells width height)
  (cond
    [(empty? cells) empty]
    [(in-bounds? (first cells) width height)
     (cons (first cells)
           (filter-in-bounds (rest cells) width height))]
    [else (filter-in-bounds (rest cells) width height)]))

;; add-neighbors-of/wall : Posn ListOfPosn Number Number -> ListOfPosn
;; cell の近傍のうち盤内だけを acc に合流。
(define (add-neighbors-of/wall cell acc width height)
  (union-list (filter-in-bounds (cell-neighbors cell) width height) acc))

;; fold-add-neighbors/wall : ListOfPosn ListOfPosn Number Number -> ListOfPosn
(define (fold-add-neighbors/wall cells acc width height)
  (cond
    [(empty? cells) acc]
    [else
     (fold-add-neighbors/wall
      (rest cells)
      (add-neighbors-of/wall (first cells) acc width height)
      width height)]))

;; candidate-cells/wall : ListOfPosn Number Number -> ListOfPosn
;; 次世代を判定すべき座標一覧 = 盤内の生きセル + それらの盤内近傍。
(define (candidate-cells/wall live width height)
  (fold-add-neighbors/wall
   (filter-in-bounds live width height)
   (filter-in-bounds live width height)
   width height))

;; filter-next/wall : ListOfPosn ListOfPosn Number Number -> ListOfPosn
(define (filter-next/wall candidates live width height)
  (cond
    [(empty? candidates) empty]
    [(next-alive? (member-posn? (first candidates) live)
                  (count-neighbors/wall (first candidates) live width height))
     (cons (first candidates)
           (filter-next/wall (rest candidates) live width height))]
    [else (filter-next/wall (rest candidates) live width height)]))

;; next-generation/wall : ListOfPosn Number Number -> ListOfPosn
;; 壁境界の B3/S23 を 1 世代進めた新しいワールドを返す（破壊的更新はしない）。
(define (next-generation/wall cells width height)
  (filter-next/wall (candidate-cells/wall cells width height)
                    cells
                    width
                    height))

;; 角の単独セルは近傍 0 で次世代に消える
(check-expect
 (same-world? (next-generation/wall (list (make-posn 0 0)) 5 5) empty)
 true)

;; ------------------------------------------------------------
;; 配置ヘルパ
;; ------------------------------------------------------------

;; place-cells : ListOfPosn Number Number -> ListOfPosn
;; パターン全体を (dx, dy) だけずらす。
(define (place-cells cells dx dy)
  (cond
    [(empty? cells) empty]
    [else
     (cons (make-posn (+ (posn-x (first cells)) dx)
                      (+ (posn-y (first cells)) dy))
           (place-cells (rest cells) dx dy))]))

;; place-glider : Number Number -> ListOfPosn
;; 相対パターン GLIDER を (x, y) 付近に置いた 5 セルを返す。
(define (place-glider x y)
  (place-cells GLIDER x y))

;; THREE-GLIDERS-WORLD : ListOfPosn
;; 60×40 盤向け。互いに干渉しにくい位置にグライダー 3 機。
;;   (2,2) / (20,8) / (40,15)
;; BSL は 0 引数関数を許さないため定数にする。
(define THREE-GLIDERS-WORLD
  (append (place-glider 2 2)
          (place-glider 20 8)
          (place-glider 40 15)))

;; ------------------------------------------------------------
;; テスト用ヘルパ（順序を無視した盤の比較・N 世代実行）
;; ------------------------------------------------------------

;; cell<? : Posn Posn -> Boolean
(define (cell<? a b)
  (cond
    [(< (posn-x a) (posn-x b)) true]
    [(> (posn-x a) (posn-x b)) false]
    [else (< (posn-y a) (posn-y b))]))

(define (insert-cell c sorted)
  (cond
    [(empty? sorted) (list c)]
    [(cell<? c (first sorted)) (cons c sorted)]
    [else (cons (first sorted) (insert-cell c (rest sorted)))]))

(define (sort-cells cells)
  (cond
    [(empty? cells) empty]
    [else (insert-cell (first cells) (sort-cells (rest cells)))]))

;; same-world? : ListOfPosn ListOfPosn -> Boolean
;; 順序を無視して、同じ生きセル集合か。
(define (same-world? a b)
  (equal? (sort-cells a) (sort-cells b)))

;; step-n/wall : ListOfPosn Number Number Number -> ListOfPosn
;; 壁付き next-generation を n 回適用する。
(define (step-n/wall cells n width height)
  (cond
    [(<= n 0) cells]
    [else (step-n/wall (next-generation/wall cells width height)
                       (- n 1)
                       width
                       height)]))

;; my-length : List -> Number（テスト用）
(define (my-length xs)
  (cond
    [(empty? xs) 0]
    [else (+ 1 (my-length (rest xs)))]))

;; ----- 静物・振動子（壁から離して配置）-----
(define block
  (list (make-posn 1 1) (make-posn 1 2)
        (make-posn 2 1) (make-posn 2 2)))
(check-expect (same-world? (next-generation/wall block 10 10) block) true)
(check-expect (same-world? (step-n/wall block 5 10 10) block) true)

(define blinker-h
  (list (make-posn 2 1) (make-posn 2 2) (make-posn 2 3)))
(define blinker-v
  (list (make-posn 1 2) (make-posn 2 2) (make-posn 3 2)))
(check-expect (same-world? (next-generation/wall blinker-h 8 8) blinker-v) true)
(check-expect (same-world? (next-generation/wall blinker-v 8 8) blinker-h) true)
(check-expect (same-world? (step-n/wall blinker-h 2 8 8) blinker-h) true)

;; ----- グライダー（盤の中央付近＝無限平面に近い）-----
(define g0 (place-glider 10 10))
(define g4 (step-n/wall g0 4 GRID-WIDTH GRID-HEIGHT))
(check-expect (same-world? g4 (place-glider 11 11)) true)
(check-expect (my-length g0) 5)
(check-expect (my-length g4) 5)

;; グライダー 3 機: 4 世代後も各 5 セル・位置が +1,+1
(define w0 THREE-GLIDERS-WORLD)
(define w4 (step-n/wall w0 4 GRID-WIDTH GRID-HEIGHT))
(define w4-expected
  (append (place-glider 3 3)
          (place-glider 21 9)
          (place-glider 41 16)))
(check-expect (my-length w0) 15)
(check-expect (my-length w4) 15)
(check-expect (same-world? w4 w4-expected) true)

;; 壁にぶつかるとグライダーは壊れる（トーラスではない）
(define g-edge (place-glider 56 0))
(define g-edge-after (step-n/wall g-edge 40 GRID-WIDTH GRID-HEIGHT))
(check-expect (< (my-length g-edge-after) 5) true)

(test)
