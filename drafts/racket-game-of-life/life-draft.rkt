#lang htdp/bsl
;; 短縮ドラフト専用。リポジトリルートで:
;; racket drafts/racket-game-of-life/life-draft.rkt
;; MIT License — see ../../LICENSE
(require test-engine/racket-tests)

;; 盤面: 重複のない整数座標のリスト。記載のない座標は死。
(define block
  (list (make-posn 1 1) (make-posn 1 2)
        (make-posn 2 1) (make-posn 2 2)))
(define blinker-h
  (list (make-posn 1 2) (make-posn 2 2) (make-posn 3 2)))
(define blinker-v
  (list (make-posn 2 1) (make-posn 2 2) (make-posn 2 3)))

;; next-alive?: Boolean Number -> Boolean (n: 整数0〜8)
(define (next-alive? alive-now? n)
  (cond
    [alive-now? (or (= n 2) (= n 3))]
    [else (= n 3)]))

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

(define (char-at live x y)
  (if (member-posn? (make-posn x y) live) "#" "."))

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


;; 小さな入力から全体へ。期待値は規則から決める。
(check-expect (member-posn? (make-posn 2 2) blinker-h) #true)
(check-expect (member-posn? (make-posn 0 0) blinker-h) #false)
(check-expect (member-posn? (make-posn 2 2) empty) #false)
(check-expect (next-alive? #true 2) #true)
(check-expect (next-alive? #false 2) #false)
(check-expect (next-alive? #false 3) #true)
(check-expect (next-alive? #true 4) #false)
(check-expect (my-length (cell-neighbors (make-posn 0 0))) 8)
(check-expect (member-posn? (make-posn 0 0)
                            (cell-neighbors (make-posn 0 0))) #false)
(check-expect (count-neighbors (make-posn 2 2) blinker-h) 2)
(check-expect (count-neighbors (make-posn 2 1) blinker-h) 3)
(check-expect (next-generation empty) empty)
(check-expect (same-world? (next-generation block) block) #true)
(check-expect (same-world? (next-generation blinker-h) blinker-v) #true)
(check-expect (same-world? (next-generation blinker-v) blinker-h) #true)
(check-expect (world->rows blinker-h 0 0 5 5)
              (list "....." "....." ".###." "....." "....."))
(check-expect (world->rows (next-generation blinker-h) 0 0 5 5)
              (list "....." "..#.." "..#.." "..#.." "....."))
(check-expect (next-generation (list (make-posn 0 0))) empty)
(check-expect (same-world? (reverse block) block) #true)

(test)
(world->rows blinker-h 0 0 5 5)
(world->rows (next-generation blinker-h) 0 0 5 5)
