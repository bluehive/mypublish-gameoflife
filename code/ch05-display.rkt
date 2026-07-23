;; Copyright (c) 2026 mevius
;; 第5章: 描画とパターン（BSL）
;; CLI: racket code/ch05-display.rkt

#lang htdp/bsl

(require test-engine/racket-tests)

;; ---- engine (ch04 と同型・BSL) ----

(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

(define (births? neighbors)
  (= neighbors 3))

(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

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

(define (member-posn? cell cells)
  (cond
    [(empty? cells) false]
    [(equal? cell (first cells)) true]
    [else (member-posn? cell (rest cells))]))

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

(define (my-length xs)
  (cond
    [(empty? xs) 0]
    [else (+ 1 (my-length (rest xs)))]))

;; ---- ASCII ----

;; char-at: ListOfPosn Number Number -> String  ("#" or ".")
(define (char-at live x y)
  (if (member-posn? (make-posn x y) live) "#" "."))

;; row-from: ... build string for one row starting at ox, length width
(define (row-from live ox y i width)
  (cond
    [(>= i width) ""]
    [else (string-append (char-at live (+ ox i) y)
                         (row-from live ox y (add1 i) width))]))

(define (rows-from live ox oy j height width)
  (cond
    [(>= j height) empty]
    [else (cons (row-from live ox (+ oy j) 0 width)
                (rows-from live ox oy (add1 j) height width))]))

(define (world->rows cells origin-x origin-y width height)
  (rows-from cells origin-x origin-y 0 height width))

;; 表示は副作用。BSL に begin が無いため、テスト対象は純粋な world->rows のみ。
;; DrRacket 相互作用では (world->rows ...) の結果リストを目視する。

;; ---- patterns ----

(define pattern-block
  (list (make-posn 0 0) (make-posn 0 1)
        (make-posn 1 0) (make-posn 1 1)))

(define pattern-blinker
  (list (make-posn 0 1) (make-posn 1 1) (make-posn 2 1)))

(define pattern-beacon
  (list (make-posn 0 0) (make-posn 0 1) (make-posn 1 0) (make-posn 1 1)
        (make-posn 2 2) (make-posn 2 3) (make-posn 3 2) (make-posn 3 3)))

(define pattern-glider
  (list (make-posn 1 0) (make-posn 2 1)
        (make-posn 0 2) (make-posn 1 2) (make-posn 2 2)))

(define pattern-toad
  (list (make-posn 1 0) (make-posn 2 0) (make-posn 3 0)
        (make-posn 0 1) (make-posn 1 1) (make-posn 2 1)))

(define pattern-pulsar
  (list
   (make-posn 2 0) (make-posn 3 0) (make-posn 4 0)
   (make-posn 8 0) (make-posn 9 0) (make-posn 10 0)
   (make-posn 0 2) (make-posn 5 2) (make-posn 7 2) (make-posn 12 2)
   (make-posn 0 3) (make-posn 5 3) (make-posn 7 3) (make-posn 12 3)
   (make-posn 0 4) (make-posn 5 4) (make-posn 7 4) (make-posn 12 4)
   (make-posn 2 5) (make-posn 3 5) (make-posn 4 5)
   (make-posn 8 5) (make-posn 9 5) (make-posn 10 5)
   (make-posn 2 7) (make-posn 3 7) (make-posn 4 7)
   (make-posn 8 7) (make-posn 9 7) (make-posn 10 7)
   (make-posn 0 8) (make-posn 5 8) (make-posn 7 8) (make-posn 12 8)
   (make-posn 0 9) (make-posn 5 9) (make-posn 7 9) (make-posn 12 9)
   (make-posn 0 10) (make-posn 5 10) (make-posn 7 10) (make-posn 12 10)
   (make-posn 2 12) (make-posn 3 12) (make-posn 4 12)
   (make-posn 8 12) (make-posn 9 12) (make-posn 10 12)))

(define (union-cells a b)
  (sort-cells (union-list a b)))

;; Life 1.06 line parser
(define (first-space-index s i)
  (cond
    [(>= i (string-length s)) false]
    [(string=? (substring s i (add1 i)) " ") i]
    [else (first-space-index s (add1 i))]))

(define (parse-life106-line line)
  (cond
    [(string=? line "") false]
    [(string=? (substring line 0 1) "#") false]
    [else
     (if (false? (first-space-index line 0))
         false
         (make-posn
          (string->number (substring line 0 (first-space-index line 0)))
          (string->number (substring line
                                     (add1 (first-space-index line 0))
                                     (string-length line)))))]))

;; tests
(define rows-block (world->rows pattern-block 0 0 4 4))

(check-expect (my-length rows-block) 4)
(check-expect (substring (first rows-block) 0 1) "#")
(check-expect (substring (first rows-block) 2 3) ".")

(check-expect
 (same-world?
  (place pattern-block 3 5)
  (list (make-posn 3 5) (make-posn 3 6)
        (make-posn 4 5) (make-posn 4 6)))
 true)

(check-expect
 (same-world?
  (next-generation pattern-blinker)
  (list (make-posn 1 0) (make-posn 1 1) (make-posn 1 2)))
 true)

(check-expect
 (same-world? (step-n pattern-glider 4) (place pattern-glider 1 1))
 true)

(check-expect (parse-life106-line "# comment") false)
(check-expect (parse-life106-line "3 4") (make-posn 3 4))

(check-expect
 (my-length (union-cells pattern-block (place pattern-block 10 0)))
 8)

(check-expect (my-length pattern-pulsar) 48)
(check-expect (same-world? (step-n pattern-pulsar 3) pattern-pulsar) true)
(check-expect (same-world? (next-generation pattern-pulsar) pattern-pulsar) false)

(test)
