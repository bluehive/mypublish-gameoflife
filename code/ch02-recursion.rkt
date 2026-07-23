;; Copyright (c) 2026 mevius
;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; 第2章 サンプル: 再帰——Racketの核心
;; 言語: Advanced Student (#lang htdp/asl)
;; 正本: books/racket-game-of-life/ch02-recursion.md
;;
;; CLI: racket code/ch02-recursion.rkt

#lang htdp/asl

(require test-engine/racket-tests)

;; ------------------------------------------------------------
;; 2.1 単純再帰 — 階乗・フィボナッチ
;; ------------------------------------------------------------

(define (factorial n)
  (cond
    [(<= n 1) 1]
    [else (* n (factorial (- n 1)))]))

(define (fib n)
  (cond
    [(= n 0) 0]
    [(= n 1) 1]
    [else (+ (fib (- n 1)) (fib (- n 2)))]))

;; ------------------------------------------------------------
;; 2.2 cond — 近傍数のラベル（読み比べ用）
;; ------------------------------------------------------------

;; ライフの近傍数をざっくり分類（教育用）
(define (neighbor-label n)
  (cond
    [(< n 0) "invalid"]
    [(= n 0) "empty"]
    [(= n 1) "lonely"]
    [(or (= n 2) (= n 3)) "stable-or-birth"]
    [else "overcrowd"]))

;; ------------------------------------------------------------
;; 2.3 末尾再帰 — リスト長（アキュムレータ）
;; ------------------------------------------------------------

(define (my-length/acc xs acc)
  (cond
    [(empty? xs) acc]
    [else (my-length/acc (rest xs) (add1 acc))]))

(define (my-length xs)
  (my-length/acc xs 0))

;; 名前付き let（ASL では let の名前付き形 / または local + 再帰）
(define (sum-list xs)
  (local [(define (loop ys total)
            (cond
              [(empty? ys) total]
              [else (loop (rest ys) (+ total (first ys)))]))]
    (loop xs 0)))

;; ------------------------------------------------------------
;; 2.4 高階関数 — map / filter / foldl
;; ------------------------------------------------------------

;; セル（posn）リストから x 座標だけ
(define (xs-of cells)
  (map posn-x cells))

;; 生存候補のうち「偶数 x」だけ残す例
(define (even-x-cells cells)
  (filter (lambda (c) (even? (posn-x c))) cells))

;; foldl で合計
(define (sum-nums nums)
  (foldl + 0 nums))

;; 近傍オフセットを map でずらす（第1・4章と同型）
(define neighbor-deltas
  (list (make-posn -1 -1) (make-posn 0 -1) (make-posn 1 -1)
        (make-posn -1  0)                   (make-posn 1  0)
        (make-posn -1  1) (make-posn 0  1) (make-posn 1  1)))

(define (shift-cell cell delta)
  (make-posn (+ (posn-x cell) (posn-x delta))
             (+ (posn-y cell) (posn-y delta))))

(define (cell-neighbors cell)
  (map (lambda (d) (shift-cell cell d)) neighbor-deltas))

;; ------------------------------------------------------------
;; 2.5 再帰で「含まれるか」（member? の素朴版）
;; ------------------------------------------------------------

(define (my-member? x xs)
  (cond
    [(empty? xs) false]
    [(equal? x (first xs)) true]
    [else (my-member? x (rest xs))]))

;; ------------------------------------------------------------
;; check-expect
;; ------------------------------------------------------------

(check-expect (factorial 5) 120)
(check-expect (factorial 0) 1)
(check-expect (fib 0) 0)
(check-expect (fib 1) 1)
(check-expect (fib 6) 8)
(check-expect (neighbor-label 2) "stable-or-birth")
(check-expect (neighbor-label 4) "overcrowd")
(check-expect (my-length (list 1 2 3 4)) 4)
(check-expect (my-length empty) 0)
(check-expect (sum-list (list 1 2 3 4)) 10)
(check-expect (xs-of (list (make-posn 3 2) (make-posn 4 3))) (list 3 4))
(check-expect (even-x-cells (list (make-posn 1 0) (make-posn 2 0) (make-posn 3 1)))
              (list (make-posn 2 0)))
(check-expect (sum-nums (list 10 20 30)) 60)
(check-expect (length (cell-neighbors (make-posn 0 0))) 8)
(check-expect (my-member? (make-posn 1 1)
                          (list (make-posn 0 0) (make-posn 1 1)))
              true)
(check-expect (my-member? (make-posn 9 9)
                          (list (make-posn 0 0) (make-posn 1 1)))
              false)

(test)
