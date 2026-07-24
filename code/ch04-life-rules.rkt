;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;; 第4章: ライフゲームのルール（BSL・デザインレシピ順）
;; CLI: racket code/ch04-life-rules.rkt  （リポジトリ root から）

#lang htdp/bsl

(require test-engine/racket-tests)

;; ============================================================
;; デザインレシピ順: データ定義 → interp. → 例 → テンプレ → スタブ → 本体/テスト
;; ============================================================

;; ------------------------------------------------------------
;; データ: 近傍の生存数（Number 0〜8）
;; ------------------------------------------------------------
;; Neighbors is Number
;; interp. あるセルの周囲8マスのうち、生きている個数（0〜8）

(define N0 0)
(define N2 2)
(define N3 3)
(define N8 8)

;; テンプレート（数の基本データ）
(define (neighbors-template n)
  (... n))

;; スタブ例（コメント）
;; (define (survives? neighbors) false)

(: survives? (Number -> Boolean))
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

(: births? (Number -> Boolean))
(define (births? neighbors)
  (= neighbors 3))

(: next-alive? (Boolean Number -> Boolean))
(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

(check-expect (survives? 2) true)
(check-expect (survives? 3) true)
(check-expect (survives? 1) false)
(check-expect (births? 3) true)
(check-expect (next-alive? true 2) true)
(check-expect (next-alive? false 3) true)
(check-expect (next-alive? true 0) false)

;; ------------------------------------------------------------
;; データ: ListOfPosn（生存セルの盤）
;; ------------------------------------------------------------
;; ListOfPosn is one of:
;;  - empty
;;  - (cons Posn ListOfPosn)
;; interp. 今生きているセルの座標だけ。死はリストに載せない。

(define WORLD0 empty)
(define block
  (list (make-posn 1 1) (make-posn 1 2)
        (make-posn 2 1) (make-posn 2 2)))
(define blinker-h
  (list (make-posn 2 1) (make-posn 2 2) (make-posn 2 3)))
(define blinker-v
  (list (make-posn 1 2) (make-posn 2 2) (make-posn 3 2)))
(define glider
  (list (make-posn 1 0) (make-posn 2 1)
        (make-posn 0 2) (make-posn 1 2) (make-posn 2 2)))
(define beacon
  (list (make-posn 1 1) (make-posn 1 2) (make-posn 2 1) (make-posn 2 2)
        (make-posn 3 3) (make-posn 3 4) (make-posn 4 3) (make-posn 4 4)))
(define blinker-edge
  (list (make-posn 0 0) (make-posn 0 1) (make-posn 0 2)))

;; テンプレート: ListOfPosn
(define (listof-posn-template cells)
  (cond
    [(empty? cells) (...)]
    [else
     (... (first cells)
          (listof-posn-template (rest cells)))]))

;; スタブ例（コメント）
;; (define (member-posn? cell cells) false)
;; (define (count-neighbors cell live) 0)
;; (define (next-generation cells) empty)

;; --- 座標・近傍 ---
(define (shift-cell cell dx dy)
  (make-posn (+ (posn-x cell) dx)
             (+ (posn-y cell) dy)))

(define (cell-neighbors cell)
  (list (shift-cell cell -1 -1)
        (shift-cell cell 0 -1)
        (shift-cell cell 1 -1)
        (shift-cell cell -1 0)
        (shift-cell cell 1 0)
        (shift-cell cell -1 1)
        (shift-cell cell 0 1)
        (shift-cell cell 1 1)))

(define (my-length xs)
  (cond
    [(empty? xs) 0]
    [else (+ 1 (my-length (rest xs)))]))

;; member-posn?: Posn ListOfPosn -> Boolean
(define (member-posn? cell cells)
  (cond
    [(empty? cells) false]
    [(equal? cell (first cells)) true]
    [else (member-posn? cell (rest cells))]))

;; count-alive-in: 近傍リストのうち live に含まれる個数
(define (count-alive-in neighbors live)
  (cond
    [(empty? neighbors) 0]
    [(member-posn? (first neighbors) live)
     (+ 1 (count-alive-in (rest neighbors) live))]
    [else (count-alive-in (rest neighbors) live)]))

(define (count-neighbors cell live)
  (count-alive-in (cell-neighbors cell) live))

(define (add-unique x xs)
  (cond
    [(member-posn? x xs) xs]
    [else (cons x xs)]))

(define (union-list a b)
  (cond
    [(empty? a) b]
    [else (union-list (rest a) (add-unique (first a) b))]))

(define (add-neighbors-of cell acc)
  (union-list (cell-neighbors cell) acc))

(define (fold-add-neighbors cells acc)
  (cond
    [(empty? cells) acc]
    [else (fold-add-neighbors (rest cells)
                              (add-neighbors-of (first cells) acc))]))

(define (candidate-cells live)
  (fold-add-neighbors live live))

(define (filter-next candidates live)
  (cond
    [(empty? candidates) empty]
    [(next-alive? (member-posn? (first candidates) live)
                  (count-neighbors (first candidates) live))
     (cons (first candidates)
           (filter-next (rest candidates) live))]
    [else (filter-next (rest candidates) live)]))

(define (next-generation cells)
  (filter-next (candidate-cells cells) cells))

;; 比較・n 世代・平行移動（テスト用）
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

(define (same-world? a b)
  (equal? (sort-cells a) (sort-cells b)))

(define (step-n cells n)
  (cond
    [(<= n 0) cells]
    [else (step-n (next-generation cells) (- n 1))]))

(define (place cells dx dy)
  (cond
    [(empty? cells) empty]
    [else (cons (make-posn (+ (posn-x (first cells)) dx)
                           (+ (posn-y (first cells)) dy))
                (place (rest cells) dx dy))]))

;; トーラス（周期境界）
(define (wrap-coord v limit)
  (modulo v limit))

(define (wrap-cell cell width height)
  (make-posn (wrap-coord (posn-x cell) width)
             (wrap-coord (posn-y cell) height)))

(define (cell-neighbors/torus cell width height)
  (list (wrap-cell (shift-cell cell -1 -1) width height)
        (wrap-cell (shift-cell cell 0 -1) width height)
        (wrap-cell (shift-cell cell 1 -1) width height)
        (wrap-cell (shift-cell cell -1 0) width height)
        (wrap-cell (shift-cell cell 1 0) width height)
        (wrap-cell (shift-cell cell -1 1) width height)
        (wrap-cell (shift-cell cell 0 1) width height)
        (wrap-cell (shift-cell cell 1 1) width height)))

(define (count-alive-in/torus neighbors live)
  (cond
    [(empty? neighbors) 0]
    [(member-posn? (first neighbors) live)
     (+ 1 (count-alive-in/torus (rest neighbors) live))]
    [else (count-alive-in/torus (rest neighbors) live)]))

(define (count-neighbors/torus cell live width height)
  (count-alive-in/torus (cell-neighbors/torus cell width height) live))

(define (add-neighbors-of/torus cell acc width height)
  (union-list (cell-neighbors/torus cell width height) acc))

(define (fold-add-neighbors/torus cells acc width height)
  (cond
    [(empty? cells) acc]
    [else (fold-add-neighbors/torus (rest cells)
                                    (add-neighbors-of/torus (first cells) acc width height)
                                    width height)]))

(define (candidate-cells/torus live width height)
  (fold-add-neighbors/torus live live width height))

(define (filter-next/torus candidates live width height)
  (cond
    [(empty? candidates) empty]
    [(next-alive? (member-posn? (first candidates) live)
                  (count-neighbors/torus (first candidates) live width height))
     (cons (first candidates)
           (filter-next/torus (rest candidates) live width height))]
    [else (filter-next/torus (rest candidates) live width height)]))

(define (next-generation/torus cells width height)
  (filter-next/torus (candidate-cells/torus cells width height) cells width height))

;; パターンテスト
(check-expect (my-length (cell-neighbors (make-posn 0 0))) 8)
(check-expect (count-neighbors (make-posn 1 1) block) 3)
(check-expect (same-world? (next-generation block) block) true)
(check-expect (same-world? (step-n block 5) block) true)
(check-expect (same-world? (next-generation blinker-h) blinker-v) true)
(check-expect (same-world? (next-generation blinker-v) blinker-h) true)
(check-expect (same-world? (step-n blinker-h 2) blinker-h) true)
(check-expect (same-world? (next-generation (next-generation beacon)) beacon) true)
(check-expect (same-world? (step-n glider 4) (place glider 1 1)) true)
(check-expect (my-length glider) 5)
(check-expect (my-length (next-generation glider)) 5)
(check-expect
 (same-world?
  (next-generation/torus (next-generation/torus blinker-edge 5 5) 5 5)
  blinker-edge)
 true)

(test)
