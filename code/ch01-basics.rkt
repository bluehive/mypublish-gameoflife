;; Copyright (c) 2026 mevius
;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; 第1章 サンプル: Racketの基礎——式と関数
;; 言語: Advanced Student (#lang htdp/asl)
;; 正本: books/racket-game-of-life/ch01-basics.md
;;
;; DrRacket: 言語レベルを Advanced Student にするか、この #lang のまま Run。
;; CLI:     racket code/ch01-basics.rkt
;;          （末尾の (test) で check-expect 結果を表示）

#lang htdp/asl

(require test-engine/racket-tests)

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
;; セル座標は make-posn（HtDP / ASL の定番）
;; ------------------------------------------------------------

;; 生存セルは posn のリスト
(define sample-cells
  (list (make-posn 3 2)
        (make-posn 4 3)
        (make-posn 2 4)
        (make-posn 3 4)
        (make-posn 4 4)))

(define (first-cell cells)
  (first cells))

(define (rest-cells cells)
  (rest cells))

;; セルがリストに含まれるか
(define (alive? cells cell)
  (member? cell cells))

;; リストの長さ（再帰の予告。第2章で深掘り）
(define (my-length xs)
  (if (empty? xs)
      0
      (+ 1 (my-length (rest xs)))))

;; map / filter の予告（第2章・第3章で本格利用）
(define (xs-of-cells cells)
  (map posn-x cells))

(define (cells-with-x cells x)
  (filter (lambda (c) (= (posn-x c) x)) cells))

;; ------------------------------------------------------------
;; 1.6 三角関数（ゲーム・可視化の入口）
;; ------------------------------------------------------------

;; 度数法 → 弧度法
(define (deg->rad deg)
  (* deg (/ pi 180)))

;; 単位円上の点（リストで x y を返す）
(define (unit-circle-point deg)
  (local [(define t (deg->rad deg))]
    (list (cos t) (sin t))))

;; ------------------------------------------------------------
;; 1.7 ベクトル（高校1年レベル）— posn で表す
;; ------------------------------------------------------------

(define (v-add a b)
  (make-posn (+ (posn-x a) (posn-x b))
             (+ (posn-y a) (posn-y b))))

(define (v-scale k a)
  (make-posn (* k (posn-x a))
             (* k (posn-y a))))

;; セル座標をベクトル加算でずらす（近傍計算の素）
(define (shift-cell cell delta)
  (v-add cell delta))

(define neighbor-deltas
  (list (make-posn -1 -1) (make-posn 0 -1) (make-posn 1 -1)
        (make-posn -1  0)                   (make-posn 1  0)
        (make-posn -1  1) (make-posn 0  1) (make-posn 1  1)))

(define (cell-neighbors cell)
  (map (lambda (d) (shift-cell cell d)) neighbor-deltas))

;; ------------------------------------------------------------
;; 1.8 行列のイメージ（グリッドの数学）
;; ------------------------------------------------------------

;; 行のリストとしての小さな行列（表示用）
(define tiny-grid
  (list (list 0 1 0)
        (list 0 0 1)
        (list 1 1 1)))

(define (grid-ref grid r c)
  (list-ref (list-ref grid r) c))

;; ------------------------------------------------------------
;; 自己チェック（check-expect — ASL の標準テスト）
;; ------------------------------------------------------------

(check-expect (square 8) 64)
(check-expect (average 2 8) 5)
(check-expect (greet "Racket") "Hello, Racket!")
(check-expect (survives? 2) true)
(check-expect (survives? 3) true)
(check-expect (survives? 1) false)
(check-expect (births? 3) true)
(check-expect (births? 2) false)
(check-expect (next-alive? true 2) true)
(check-expect (next-alive? false 3) true)
(check-expect (next-alive? true 0) false)
(check-expect (first-cell sample-cells) (make-posn 3 2))
(check-expect (alive? sample-cells (make-posn 4 4)) true)
(check-expect (alive? sample-cells (make-posn 0 0)) false)
(check-expect (my-length sample-cells) 5)
(check-expect (v-add (make-posn 1 2) (make-posn 3 4)) (make-posn 4 6))
(check-expect (length (cell-neighbors (make-posn 0 0))) 8)
(check-expect (grid-ref tiny-grid 2 0) 1)

;; CLI / 自動化用。DrRacket では Run 時にテスト結果も出る。
(test)
