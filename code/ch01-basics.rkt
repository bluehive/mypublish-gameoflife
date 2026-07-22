;; Copyright (c) 2026 mevius
;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; 第1章 サンプル: Racketの基礎——式と関数
;; 正本: ../racket-game-of-life.md
;; DrRacket で開き、定義ウィンドウを Run したあと相互作用ウィンドウで試す。

#lang racket

;; ------------------------------------------------------------
;; 1.2 四則と define
;; ------------------------------------------------------------

(define width 30)
(define height 20)
(define cell-size 15)

;; 盤のピクセル幅（ライフゲーム GUI でも使う計算）
(define (board-pixel-width)
  (* width cell-size))

(define (board-pixel-height)
  (* height cell-size))

;; 問題: 平方
(define (square x)
  (* x x))

;; 問題: 平均
(define (average a b)
  (/ (+ a b) 2))

;; ------------------------------------------------------------
;; 1.3 文字列と表示
;; ------------------------------------------------------------

(define (greet name)
  (string-append "Hello, " name "!"))

(define (show-cell-label x y alive?)
  (printf "cell (~a, ~a) alive? ~a\n" x y alive?))

;; ------------------------------------------------------------
;; 1.4 真偽と if / cond
;; ------------------------------------------------------------

;; B3/S23 の「生きているセルは生き残るか？」だけ切り出した判定
;; neighbors: 周囲の生存数 (0〜8)
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

;; 死んでいるセルは誕生するか？
(define (births? neighbors)
  (= neighbors 3))

;; 次の瞬間、このセルは生きているか？
(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

;; cond 版（読み比べ用）
(define (next-alive?/cond currently-alive? neighbors)
  (cond
    [currently-alive? (or (= neighbors 2) (= neighbors 3))]
    [else (= neighbors 3)]))

;; ------------------------------------------------------------
;; 1.5 リストの基礎
;; ------------------------------------------------------------

;; 生存セルは (x . y) のペアのリスト
(define sample-cells
  '((3 . 2) (4 . 3) (2 . 4) (3 . 4) (4 . 4))) ; グライダー断片

(define (first-cell cells)
  (first cells))

(define (rest-cells cells)
  (rest cells))

;; セルがリストに含まれるか（member は見つかると残りリストを返すので and で真偽に）
(define (alive? cells cell)
  (and (member cell cells) #t))

;; リストの長さ（再帰の予告。第2章で深掘り）
(define (my-length xs)
  (if (empty? xs)
      0
      (+ 1 (my-length (rest xs)))))

;; map / filter の予告（第2章・第3章で本格利用）
(define (xs-of-cells cells)
  (map car cells))

(define (cells-with-x cells x)
  (filter (lambda (c) (= (car c) x)) cells))

;; ------------------------------------------------------------
;; 1.6 三角関数（ゲーム・可視化の入口）
;; ------------------------------------------------------------

;; 度数法 → 弧度法
(define (deg->rad deg)
  (* deg (/ pi 180)))

;; 単位円上の点（アニメの往復運動などに使える）
(define (unit-circle-point deg)
  (let ([t (deg->rad deg)])
    (list (cos t) (sin t))))

;; ------------------------------------------------------------
;; 1.7 ベクトル（高校1年レベル）
;; ------------------------------------------------------------

;; 2D ベクトルを (vx . vy) で表す
(define (v-add a b)
  (cons (+ (car a) (car b))
        (+ (cdr a) (cdr b))))

(define (v-scale k a)
  (cons (* k (car a))
        (* k (cdr a))))

;; セル座標をベクトル加算でずらす（近傍計算の素）
(define (shift-cell cell delta)
  (v-add cell delta))

(define neighbor-deltas
  '((-1 . -1) (0 . -1) (1 . -1)
    (-1 .  0)          (1 .  0)
    (-1 .  1) (0 .  1) (1 .  1)))

(define (cell-neighbors cell)
  (map (lambda (d) (shift-cell cell d)) neighbor-deltas))

;; ------------------------------------------------------------
;; 1.8 行列のイメージ（グリッドの数学）
;; ------------------------------------------------------------

;; 行のリストとしての小さな行列（表示用）
(define tiny-grid
  '((0 1 0)
    (0 0 1)
    (1 1 1)))

(define (grid-ref grid r c)
  (list-ref (list-ref grid r) c))

;; ------------------------------------------------------------
;; 自己チェック（Run すると #t が並ぶ想定）
;; ------------------------------------------------------------

(module+ test
  (require rackunit)
  (check-equal? (square 8) 64)
  (check-equal? (average 2 8) 5)
  (check-equal? (greet "Racket") "Hello, Racket!")
  (check-true (survives? 2))
  (check-true (survives? 3))
  (check-false (survives? 1))
  (check-true (births? 3))
  (check-false (births? 2))
  (check-true (next-alive? #t 2))
  (check-true (next-alive? #f 3))
  (check-false (next-alive? #t 0))
  (check-equal? (first-cell sample-cells) '(3 . 2))
  (check-true (alive? sample-cells '(4 . 4)))
  (check-false (alive? sample-cells '(0 . 0)))
  (check-equal? (my-length sample-cells) 5)
  (check-equal? (v-add '(1 . 2) '(3 . 4)) '(4 . 6))
  (check-equal? (length (cell-neighbors '(0 . 0))) 8)
  (check-equal? (grid-ref tiny-grid 2 0) 1)
  (printf "ch01-basics: all tests passed\n"))

;; 相互作用ウィンドウ用のデモ呼び出し（コメントを外して試せる）
;; (board-pixel-width)
;; (next-alive? #t 3)
;; (cell-neighbors '(3 . 2))
;; (unit-circle-point 90)
