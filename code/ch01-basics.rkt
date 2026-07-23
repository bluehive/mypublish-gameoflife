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

(define (average a b)
  (/ (+ a b) 2))

(define (greet name)
  (string-append "Hello, " name "!"))

;; ------------------------------------------------------------
;; 1.4 if / cond — ライフ規則の1セル分（応用）
;; ------------------------------------------------------------

;; neighbors: 周囲の生存数 0〜8
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
;; 1.6 struct — posn（BSL 組み込み）と自前 struct
;; ------------------------------------------------------------

(define-struct dog (name age))
;; Dog is (make-dog String Number)
;; interp. 名前と年齢

(define D1 (make-dog "flipper" 5))

;; セル座標は make-posn
(define SAMPLE-CELL (make-posn 3 2))

;; ------------------------------------------------------------
;; 1.5 リスト（BSL: cons / first / rest / empty）
;; ------------------------------------------------------------

(define SAMPLE-CELLS
  (list (make-posn 3 2)
        (make-posn 4 3)
        (make-posn 2 4)
        (make-posn 3 4)
        (make-posn 4 4)))

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
;; 近傍デルタ（第4章への橋・構造的に map 相当を手で）
;; ------------------------------------------------------------

(define (shift-cell cell dx dy)
  (make-posn (+ (posn-x cell) dx)
             (+ (posn-y cell) dy)))

;; 8 近傍をリストで返す（BSL: 名前付き補助なしで直接 list）
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
;; check-expect
;; ------------------------------------------------------------

(check-expect (square-of 8) 64)
(check-expect (average 2 8) 5)
(check-expect (greet "Racket") "Hello, Racket!")
(check-expect BOARD-PIXEL-WIDTH 450)
(check-expect (survives? 2) true)
(check-expect (survives? 1) false)
(check-expect (births? 3) true)
(check-expect (next-alive? true 2) true)
(check-expect (next-alive? false 3) true)
(check-expect (next-alive? true 0) false)
(check-expect (dog-name D1) "flipper")
(check-expect (posn-x SAMPLE-CELL) 3)
(check-expect (my-length SAMPLE-CELLS) 5)
(check-expect (alive? SAMPLE-CELLS (make-posn 4 4)) true)
(check-expect (alive? SAMPLE-CELLS (make-posn 0 0)) false)
(check-expect (my-length (cell-neighbors (make-posn 0 0))) 8)

(test)
