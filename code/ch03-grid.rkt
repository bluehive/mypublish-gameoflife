;; Copyright (c) 2026 mevius
;; 第3章: グリッド表現（BSL）
;; CLI: racket code/ch03-grid.rkt

#lang htdp/bsl

(require test-engine/racket-tests)

;; ListOfPosn — 生存セル
(define WORLD-BLOCK
  (list (make-posn 1 1) (make-posn 1 2)
        (make-posn 2 1) (make-posn 2 2)))

;; 署名: (ListOf Posn) Posn -> Boolean  （BSL の : では Posn 型名が使えないためコメント）
(define (alive? cells cell)
  (cond
    [(empty? cells) false]
    [(equal? (first cells) cell) true]
    [else (alive? (rest cells) cell)]))

;; 密グリッド 3x3 の例（グライダー断片）
(define TINY-GRID
  (list (list 0 1 0)
        (list 0 0 1)
        (list 1 1 1)))

(: grid-ref (Any Number Number -> Number))
(define (grid-ref g r c)
  (list-ref (list-ref g r) c))

(check-expect (alive? WORLD-BLOCK (make-posn 1 1)) true)
(check-expect (alive? WORLD-BLOCK (make-posn 0 0)) false)
(check-expect (grid-ref TINY-GRID 0 1) 1)
(check-expect (grid-ref TINY-GRID 2 0) 1)
(check-expect (grid-ref TINY-GRID 0 0) 0)

(test)
