;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;; 第2章: 再帰と HtDP テンプレート（BSL・デザインレシピ順）
;; CLI: racket code/ch02-recursion.rkt  （リポジトリ root から）

#lang htdp/bsl

(require test-engine/racket-tests)

;; ============================================================
;; デザインレシピ順: データ定義 → interp. → 例 → テンプレ → スタブ → 本体/テスト
;; ============================================================

;; ------------------------------------------------------------
;; データ: ListOfNumber
;; ------------------------------------------------------------
;; ListOfNumber is one of:
;;  - empty
;;  - (cons Number ListOfNumber)
;; interp. 数のリスト（長さ・合計・所属などの練習用）

(define LON0 empty)
(define LON1 (cons 99 empty))
(define LON2 (cons 4 (cons 6 empty)))
(define LON3 (cons 1 (cons 8 (cons 5 empty))))

;; 4. テンプレート
(define (listof-number-template lon)
  (cond
    [(empty? lon) (...)]
    [else
     (... (first lon)
          (listof-number-template (rest lon)))]))

;; 5. スタブ例（コメント）
;; (define (my-length lon) 0)
;; (define (sum-list lon) 0)

;; 6–7. 本体 + テスト
(: factorial (Number -> Number))
(define (factorial n)
  (cond
    [(<= n 1) 1]
    [else (* n (factorial (- n 1)))]))

(check-expect (factorial 0) 1)
(check-expect (factorial 5) 120)

(: fib (Number -> Number))
(define (fib n)
  (cond
    [(= n 0) 0]
    [(= n 1) 1]
    [else (+ (fib (- n 1)) (fib (- n 2)))]))

(check-expect (fib 0) 0)
(check-expect (fib 1) 1)
(check-expect (fib 6) 8)

;; my-length: List -> Number（要素型は数でも posn でも可）
(: my-length (Any -> Number))
(define (my-length lon)
  (cond
    [(empty? lon) 0]
    [else (+ 1 (my-length (rest lon)))]))

(check-expect (my-length empty) 0)
(check-expect (my-length LON3) 3)

(: sum-list ((ListOf Number) -> Number))
(define (sum-list lon)
  (cond
    [(empty? lon) 0]
    [else (+ (first lon) (sum-list (rest lon)))]))

(check-expect (sum-list empty) 0)
(check-expect (sum-list LON2) 10)

(: my-member? (Number (ListOf Number) -> Boolean))
(define (my-member? x lon)
  (cond
    [(empty? lon) false]
    [(= x (first lon)) true]
    [else (my-member? x (rest lon))]))

(check-expect (my-member? 6 LON2) true)
(check-expect (my-member? 7 LON2) false)

;; ------------------------------------------------------------
;; データ: ListOfPosn
;; ------------------------------------------------------------
;; ListOfPosn is one of:
;;  - empty
;;  - (cons Posn ListOfPosn)
;; interp. 生存セル座標の列（練習用）

(define LOP0 empty)
(define LOP1 (cons (make-posn 3 2) empty))
(define LOP2 (cons (make-posn 3 2) (cons (make-posn 4 3) empty)))

;; テンプレート
(define (listof-posn-template cells)
  (cond
    [(empty? cells) (...)]
    [else
     (... (first cells)
          (listof-posn-template (rest cells)))]))

;; スタブ例（コメント）
;; (define (xs-of cells) empty)

(define (xs-of cells)
  (cond
    [(empty? cells) empty]
    [else (cons (posn-x (first cells))
                (xs-of (rest cells)))]))

(check-expect (xs-of empty) empty)
(check-expect (xs-of LOP2) (list 3 4))

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

(check-expect (my-length (cell-neighbors (make-posn 0 0))) 8)

(: neighbor-label (Number -> String))
(define (neighbor-label n)
  (cond
    [(< n 0) "invalid"]
    [(= n 0) "empty"]
    [(= n 1) "lonely"]
    [(or (= n 2) (= n 3)) "stable-or-birth"]
    [else "overcrowd"]))

(check-expect (neighbor-label 0) "empty")
(check-expect (neighbor-label 2) "stable-or-birth")
(check-expect (neighbor-label 4) "overcrowd")

(test)
