;; Copyright (c) 2026 mevius
;; Licensed under the MIT License.
;; 第1章: 式と関数（Beginning Student / howtocode cheatsheet 準拠）
;; CLI: racket code/ch01-basics.rkt

#lang htdp/bsl

(require test-engine/racket-tests)

;; ------------------------------------------------------------
;; 1.3 define 定数
;; ------------------------------------------------------------

(define WIDTH 30)
(define HEIGHT 20)
(define CELL-SIZE 15)

;; BSL は 0 引数関数を許さない → 定数として定義
(define BOARD-PIXEL-WIDTH (* WIDTH CELL-SIZE))
(define BOARD-PIXEL-HEIGHT (* HEIGHT CELL-SIZE))

;; ------------------------------------------------------------
;; 1.5 関数
;; ------------------------------------------------------------

(define (square-of x)
  (* x x))

(define (greet name)
  (string-append "Hello, " name "!"))

;; ------------------------------------------------------------
;; 1.4 if / cond — ライフ規則の1セル分（応用）
;; ------------------------------------------------------------

(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

(define (births? neighbors)
  (= neighbors 3))

(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

(define (next-alive?/cond currently-alive? neighbors)
  (cond
    [currently-alive? (or (= neighbors 2) (= neighbors 3))]
    [else (= neighbors 3)]))

;; ------------------------------------------------------------
;; 1.6 struct — Cell（ライフ向け）と posn
;; ------------------------------------------------------------

(define-struct cell (x y alive?))
;; Cell is (make-cell Integer Integer Boolean)
;; interp. 盤上の1マス。alive? が true なら生きている

(define C1 (make-cell 3 2 true))
(define C2 (make-cell 0 0 false))

(define SAMPLE-CELL (make-posn 3 2))

;; ------------------------------------------------------------
;; 1.7 リスト（BSL: cons / first / rest / empty）
;; ------------------------------------------------------------

(define SAMPLE-CELLS
  (list (make-posn 3 2)
        (make-posn 4 3)
        (make-posn 2 4)))

(define (my-length xs)
  (cond
    [(empty? xs) 0]
    [else (+ 1 (my-length (rest xs)))]))

(define (alive? cells cell)
  (cond
    [(empty? cells) false]
    [(equal? (first cells) cell) true]
    [else (alive? (rest cells) cell)]))

;; ------------------------------------------------------------
;; 1.8 近傍8マス
;; ------------------------------------------------------------

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

;; ------------------------------------------------------------
;; check-expect（本文 1.9 と同じ系統）
;; ------------------------------------------------------------

(check-expect BOARD-PIXEL-WIDTH 450)

(check-expect (survives? 2) true)
(check-expect (survives? 1) false)
(check-expect (births? 3) true)
(check-expect (next-alive? true 2) true)
(check-expect (next-alive? false 3) true)
(check-expect (next-alive? true 0) false)

(check-expect (square-of 8) 64)
(check-expect (greet "Racket") "Hello, Racket!")

(check-expect (cell-x C1) 3)
(check-expect (cell-alive? C1) true)
(check-expect (posn-x SAMPLE-CELL) 3)

(check-expect (my-length SAMPLE-CELLS) 3)
(check-expect (alive? SAMPLE-CELLS (make-posn 3 2)) true)
(check-expect (alive? SAMPLE-CELLS (make-posn 0 0)) false)

(check-expect (my-length (cell-neighbors (make-posn 0 0))) 8)

(test)
