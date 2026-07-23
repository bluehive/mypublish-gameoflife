;; Copyright (c) 2026 mevius
;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; 第4章 サンプル: ライフゲームのルールとセルオートマトン
;; 言語: Advanced Student (#lang htdp/asl)
;; 正本: books/racket-game-of-life/ch04-life-rules.md
;; 盤面: 生存セル = (make-posn x y) のリスト（不変・スパース）
;;
;; CLI: racket code/ch04-life-rules.rkt

#lang htdp/asl

(require test-engine/racket-tests)

;; ------------------------------------------------------------
;; 4.1 ルール（B3/S23）— 1セルの次状態
;; ------------------------------------------------------------

(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

(define (births? neighbors)
  (= neighbors 3))

(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

;; ------------------------------------------------------------
;; 4.2 近傍 — count-neighbors
;; ------------------------------------------------------------

(define neighbor-deltas
  (list (make-posn -1 -1) (make-posn 0 -1) (make-posn 1 -1)
        (make-posn -1  0)                   (make-posn 1  0)
        (make-posn -1  1) (make-posn 0  1) (make-posn 1  1)))

(define (shift-cell cell delta)
  (make-posn (+ (posn-x cell) (posn-x delta))
             (+ (posn-y cell) (posn-y delta))))

(define (cell-neighbors cell)
  (map (lambda (d) (shift-cell cell d)) neighbor-deltas))

(define (alive-in? live-cells cell)
  (member? cell live-cells))

;; 固定境界: 盤外はリストにいない＝寄与 0
(define (count-neighbors cell live-cells)
  (length
   (filter (lambda (n) (alive-in? live-cells n))
           (cell-neighbors cell))))

;; ------------------------------------------------------------
;; 候補集合と次世代
;; ------------------------------------------------------------

;; リストの和集合（重複除去）
(define (add-unique x xs)
  (if (member? x xs)
      xs
      (cons x xs)))

(define (union-list a b)
  (foldr add-unique b a))

;; 1セルの近傍を live に足す
(define (add-neighbors-of cell acc)
  (union-list (cell-neighbors cell) acc))

;; 次世代の候補 = 生存 ∪ その全近傍
(define (candidate-cells live-cells)
  (foldr add-neighbors-of live-cells live-cells))

(define (next-generation cells)
  (local [(define live cells)
          (define candidates (candidate-cells live))]
    (filter (lambda (c)
              (next-alive? (alive-in? live c)
                           (count-neighbors c live)))
            candidates)))

;; 比較用ソート（x 昇順、同 x なら y 昇順）
(define (cell<? a b)
  (or (< (posn-x a) (posn-x b))
      (and (= (posn-x a) (posn-x b))
           (< (posn-y a) (posn-y b)))))

(define (sort-cells cells)
  (sort cells cell<?))

(define (same-world? a b)
  (equal? (sort-cells a) (sort-cells b)))

;; n 世代進める（名前付き let = ASL の recur 相当）
(define (step-n cells n)
  (cond
    [(<= n 0) cells]
    [else (step-n (next-generation cells) (- n 1))]))

;; ------------------------------------------------------------
;; 4.4 トーラス（周期境界）
;; ------------------------------------------------------------

(define (wrap-coord v limit)
  (modulo v limit))

(define (wrap-cell cell width height)
  (make-posn (wrap-coord (posn-x cell) width)
             (wrap-coord (posn-y cell) height)))

(define (cell-neighbors/torus cell width height)
  (map (lambda (d)
         (wrap-cell (shift-cell cell d) width height))
       neighbor-deltas))

(define (count-neighbors/torus cell live-cells width height)
  (length
   (filter (lambda (n) (alive-in? live-cells n))
           (cell-neighbors/torus cell width height))))

(define (add-neighbors-of/torus width height)
  (lambda (cell acc)
    (union-list (cell-neighbors/torus cell width height) acc)))

(define (candidate-cells/torus live-cells width height)
  (foldr (add-neighbors-of/torus width height) live-cells live-cells))

(define (next-generation/torus cells width height)
  (local [(define live cells)
          (define candidates (candidate-cells/torus live width height))]
    (filter (lambda (c)
              (next-alive? (alive-in? live c)
                           (count-neighbors/torus c live width height)))
            candidates)))

;; ------------------------------------------------------------
;; 有名パターン
;; ------------------------------------------------------------

(define block
  (list (make-posn 1 1) (make-posn 1 2)
        (make-posn 2 1) (make-posn 2 2)))

(define blinker-h
  (list (make-posn 2 1) (make-posn 2 2) (make-posn 2 3)))

(define blinker-v
  (list (make-posn 1 2) (make-posn 2 2) (make-posn 3 2)))

;; グライダー
;;  . # .
;;  . . #
;;  # # #
(define glider
  (list (make-posn 1 0) (make-posn 2 1)
        (make-posn 0 2) (make-posn 1 2) (make-posn 2 2)))

(define beacon
  (list (make-posn 1 1) (make-posn 1 2) (make-posn 2 1) (make-posn 2 2)
        (make-posn 3 3) (make-posn 3 4) (make-posn 4 3) (make-posn 4 4)))

;; 平行移動
(define (place cells dx dy)
  (map (lambda (c)
         (make-posn (+ (posn-x c) dx)
                    (+ (posn-y c) dy)))
       cells))

;; ------------------------------------------------------------
;; check-expect
;; ------------------------------------------------------------

;; ルール単体
(check-expect (survives? 2) true)
(check-expect (survives? 3) true)
(check-expect (survives? 1) false)
(check-expect (survives? 4) false)
(check-expect (births? 3) true)
(check-expect (births? 2) false)
(check-expect (next-alive? true 2) true)
(check-expect (next-alive? false 3) true)
(check-expect (next-alive? true 0) false)
(check-expect (next-alive? false 2) false)

;; 近傍
(check-expect (length (cell-neighbors (make-posn 0 0))) 8)
(check-expect (count-neighbors (make-posn 1 1) block) 3)
(check-expect (count-neighbors (make-posn 0 0) block) 1)

;; 静止物: ブロック
(check-expect (same-world? (next-generation block) block) true)
(check-expect (same-world? (step-n block 5) block) true)

;; 振動子: ブリンカー周期 2
(check-expect (same-world? (next-generation blinker-h) blinker-v) true)
(check-expect (same-world? (next-generation blinker-v) blinker-h) true)
(check-expect (same-world? (step-n blinker-h 2) blinker-h) true)
(check-expect (same-world? (step-n blinker-h 4) blinker-h) true)

;; ビーコン周期 2
(check-expect
 (same-world? (next-generation (next-generation beacon)) beacon)
 true)

;; グライダー: 4 世代で (1,1) シフト
(check-expect
 (same-world? (step-n glider 4) (place glider 1 1))
 true)
(check-expect (length glider) 5)
(check-expect (length (next-generation glider)) 5)
(check-expect (length (step-n glider 4)) 5)

;; トーラス: 端のブリンカー
(define blinker-edge
  (list (make-posn 0 0) (make-posn 0 1) (make-posn 0 2)))

(check-expect
 (same-world?
  (next-generation/torus (next-generation/torus blinker-edge 5 5) 5 5)
  blinker-edge)
 true)

(test)
