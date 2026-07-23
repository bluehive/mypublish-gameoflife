;; Copyright (c) 2026 mevius
;; 第2章: 再帰と HtDP テンプレート（BSL）
;; CLI: racket code/ch02-recursion.rkt

#lang htdp/bsl

(require test-engine/racket-tests)

;; ============================================================
;; Data: ListOfNumber
;; ============================================================
;; ListOfNumber is one of:
;;  - empty
;;  - (cons Number ListOfNumber)
;; interp. 数のリスト

(define LON0 empty)
(define LON1 (cons 99 empty))
(define LON2 (cons 4 (cons 6 empty)))
(define LON3 (cons 1 (cons 8 (cons 5 empty))))

;; テンプレートは本文（md）に記載。実行ファイルには完成関数のみ置く。

;; ============================================================
;; Functions on ListOfNumber
;; ============================================================

;; factorial: Natural -> Natural
;; 非負整数 n の階乗
(check-expect (factorial 0) 1)
(check-expect (factorial 5) 120)

(define (factorial n)
  (cond
    [(<= n 1) 1]
    [else (* n (factorial (- n 1)))]))

;; fib: Natural -> Natural
(check-expect (fib 0) 0)
(check-expect (fib 1) 1)
(check-expect (fib 6) 8)

(define (fib n)
  (cond
    [(= n 0) 0]
    [(= n 1) 1]
    [else (+ (fib (- n 1)) (fib (- n 2)))]))

;; my-length: ListOfNumber -> Natural
(check-expect (my-length empty) 0)
(check-expect (my-length LON3) 3)

(define (my-length lon)
  (cond
    [(empty? lon) 0]
    [else (+ 1 (my-length (rest lon)))]))

;; sum-list: ListOfNumber -> Number
(check-expect (sum-list empty) 0)
(check-expect (sum-list LON2) 10)

(define (sum-list lon)
  (cond
    [(empty? lon) 0]
    [else (+ (first lon) (sum-list (rest lon)))]))

;; my-member?: Number ListOfNumber -> Boolean
(check-expect (my-member? 6 LON2) true)
(check-expect (my-member? 7 LON2) false)

(define (my-member? x lon)
  (cond
    [(empty? lon) false]
    [(= x (first lon)) true]
    [else (my-member? x (rest lon))]))

;; ============================================================
;; Data: ListOfPosn（セル列）
;; ============================================================
;; ListOfPosn is one of:
;;  - empty
;;  - (cons Posn ListOfPosn)

(define LOP1 (cons (make-posn 3 2) empty))
(define LOP2 (cons (make-posn 3 2) (cons (make-posn 4 3) empty)))

;; xs-of: ListOfPosn -> ListOfNumber
;; 各セルの x 座標のリスト
(check-expect (xs-of empty) empty)
(check-expect (xs-of LOP2) (list 3 4))

(define (xs-of cells)
  (cond
    [(empty? cells) empty]
    [else (cons (posn-x (first cells))
                (xs-of (rest cells)))]))

;; cell-neighbors: Posn -> ListOfPosn
;; 8 近傍
(check-expect (my-length (cell-neighbors (make-posn 0 0))) 8)

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

;; neighbor-label: Integer -> String
;; 近傍数のラベル（enum 的 cond）
(check-expect (neighbor-label 0) "empty")
(check-expect (neighbor-label 2) "stable-or-birth")
(check-expect (neighbor-label 4) "overcrowd")

(define (neighbor-label n)
  (cond
    [(< n 0) "invalid"]
    [(= n 0) "empty"]
    [(= n 1) "lonely"]
    [(or (= n 2) (= n 3)) "stable-or-birth"]
    [else "overcrowd"]))

(test)
