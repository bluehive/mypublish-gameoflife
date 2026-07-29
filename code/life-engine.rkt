;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; Pure Racket Game of Life engine (wall / finite grid).
;; Issue #11 prototype — logic only (no GUI).
;;
;; Design recipe order (howtocode / HtDP style):
;;   data definitions → interpretation → examples → template notes → body

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
;; Constants (Issue #11 answers: 60×40 board)
;; ------------------------------------------------------------

(define GRID-WIDTH 60)
(define GRID-HEIGHT 40)

;; Standard SE-going glider (same shape as ch04-life-rules.rkt).
;; Relative coords; place with place-glider.
(define GLIDER
  (list (make-posn 1 0)
        (make-posn 2 1)
        (make-posn 0 2)
        (make-posn 1 2)
        (make-posn 2 2)))

;; ------------------------------------------------------------
;; Data: Neighbors is Integer in 0..8
;; interp. number of live cells among the 8 Moore neighbors
;; ------------------------------------------------------------

;; survives? : Integer -> Boolean
;; Living cell stays alive with 2 or 3 neighbors (B3/S23).
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

;; births? : Integer -> Boolean
;; Dead cell becomes live with exactly 3 neighbors.
(define (births? neighbors)
  (= neighbors 3))

;; next-alive? : Boolean Integer -> Boolean
(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

;; ------------------------------------------------------------
;; Data: Cell is Posn
;; interp. grid coordinate (x right, y down), integers
;;
;; World is ListOf Posn
;; interp. set of live cells only (dead cells are omitted)
;; ------------------------------------------------------------

;; in-bounds? : Posn Integer Integer -> Boolean
;; Wall boundary: only cells inside [0,w)×[0,h) exist.
(define (in-bounds? cell width height)
  (and (<= 0 (posn-x cell) (sub1 width))
       (<= 0 (posn-y cell) (sub1 height))))

;; shift-cell : Posn Integer Integer -> Posn
(define (shift-cell cell dx dy)
  (make-posn (+ (posn-x cell) dx)
             (+ (posn-y cell) dy)))

;; cell-neighbors : Posn -> (Listof Posn)
;; Eight Moore neighbors (may be outside the board).
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
(define (member-posn? cell cells)
  (cond
    [(empty? cells) #f]
    [(equal? cell (first cells)) #t]
    [else (member-posn? cell (rest cells))]))

;; count-neighbors/wall : Posn (Listof Posn) Integer Integer -> Integer
;; Outside the wall counts as dead (not torus).
(define (count-neighbors/wall cell live width height)
  (for/sum ([n (in-list (cell-neighbors cell))])
    (if (and (in-bounds? n width height)
             (member-posn? n live))
        1
        0)))

;; --- candidate generation (live cells ∪ their in-bound neighbors) ---

(define (add-unique x xs)
  (if (member-posn? x xs) xs (cons x xs)))

(define (union-list a b)
  (cond
    [(empty? a) b]
    [else (union-list (rest a) (add-unique (first a) b))]))

(define (add-neighbors-of/wall cell acc width height)
  (define inside
    (filter (λ (n) (in-bounds? n width height))
            (cell-neighbors cell)))
  (union-list inside acc))

(define (fold-add-neighbors/wall cells acc width height)
  (cond
    [(empty? cells) acc]
    [else
     (fold-add-neighbors/wall
      (rest cells)
      (add-neighbors-of/wall (first cells) acc width height)
      width height)]))

;; candidate-cells/wall : (Listof Posn) Integer Integer -> (Listof Posn)
(define (candidate-cells/wall live width height)
  (define live-in
    (filter (λ (c) (in-bounds? c width height)) live))
  (fold-add-neighbors/wall live-in live-in width height))

;; filter-next/wall : ... -> (Listof Posn)
(define (filter-next/wall candidates live width height)
  (cond
    [(empty? candidates) '()]
    [(next-alive? (member-posn? (first candidates) live)
                  (count-neighbors/wall (first candidates) live width height))
     (cons (first candidates)
           (filter-next/wall (rest candidates) live width height))]
    [else (filter-next/wall (rest candidates) live width height)]))

;; next-generation/wall : (Listof Posn) Integer Integer -> (Listof Posn)
;; One step of B3/S23 with hard walls (finite grid, outside = dead).
(define (next-generation/wall cells width height)
  (filter-next/wall (candidate-cells/wall cells width height)
                    cells
                    width
                    height))

;; ------------------------------------------------------------
;; Placement helpers
;; ------------------------------------------------------------

;; place-cells : (Listof Posn) Integer Integer -> (Listof Posn)
(define (place-cells cells dx dy)
  (for/list ([c (in-list cells)])
    (make-posn (+ (posn-x c) dx)
               (+ (posn-y c) dy))))

;; place-glider : Integer Integer -> (Listof Posn)
;; SE-going glider with top-left of its bbox near (x,y).
(define (place-glider x y)
  (place-cells GLIDER x y))

;; three-gliders-world : -> (Listof Posn)
;; Three well-spaced gliders on the default 60×40 board.
(define (three-gliders-world)
  (append (place-glider 2 2)
          (place-glider 20 8)
          (place-glider 40 15)))

;; ------------------------------------------------------------
;; Testing helpers
;; ------------------------------------------------------------

(define (cell<? a b)
  (cond
    [(< (posn-x a) (posn-x b)) #t]
    [(> (posn-x a) (posn-x b)) #f]
    [else (< (posn-y a) (posn-y b))]))

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
(define (same-world? a b)
  (equal? (sort-cells a) (sort-cells b)))

;; step-n/wall : (Listof Posn) Integer Integer Integer -> (Listof Posn)
(define (step-n/wall cells n width height)
  (cond
    [(<= n 0) cells]
    [else (step-n/wall (next-generation/wall cells width height)
                       (sub1 n)
                       width
                       height)]))
