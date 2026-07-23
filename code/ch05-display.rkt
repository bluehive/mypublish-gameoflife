;; Copyright (c) 2026 mevius
;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; 第5章 骨格: 描画と対話——盤面を見る
;; 言語: Advanced Student (#lang htdp/asl)
;; 正本: books/racket-game-of-life/ch05-display.md
;; 第4章と同型のルールを自己完結で再掲（ASL は章ファイル単体で読める方針）
;;
;; CLI: racket code/ch05-display.rkt

#lang htdp/asl

(require test-engine/racket-tests)

;; ------------------------------------------------------------
;; ルールエンジン（第4章の要約・自己完結）
;; ------------------------------------------------------------

(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

(define (births? neighbors)
  (= neighbors 3))

(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

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

(define (count-neighbors cell live-cells)
  (length
   (filter (lambda (n) (alive-in? live-cells n))
           (cell-neighbors cell))))

(define (add-unique x xs)
  (if (member? x xs) xs (cons x xs)))

(define (union-list a b)
  (foldr add-unique b a))

(define (add-neighbors-of cell acc)
  (union-list (cell-neighbors cell) acc))

(define (candidate-cells live-cells)
  (foldr add-neighbors-of live-cells live-cells))

(define (next-generation cells)
  (local [(define live cells)
          (define candidates (candidate-cells live))]
    (filter (lambda (c)
              (next-alive? (alive-in? live c)
                           (count-neighbors c live)))
            candidates)))

(define (cell<? a b)
  (or (< (posn-x a) (posn-x b))
      (and (= (posn-x a) (posn-x b))
           (< (posn-y a) (posn-y b)))))

(define (sort-cells cells)
  (sort cells cell<?))

(define (same-world? a b)
  (equal? (sort-cells a) (sort-cells b)))

(define (step-n cells n)
  (cond
    [(<= n 0) cells]
    [else (step-n (next-generation cells) (- n 1))]))

(define (place cells dx dy)
  (map (lambda (c)
         (make-posn (+ (posn-x c) dx)
                    (+ (posn-y c) dy)))
       cells))

;; ------------------------------------------------------------
;; 5.1 ASCII 表示
;; ------------------------------------------------------------

;; ASL に displayln が無いので display + newline
(define (display-line s)
  (begin
    (display s)
    (newline)))

;; 1 行分の文字列を組み立てる
(define (row->string live-cells ox y width)
  (implode
   (map (lambda (i)
          (if (alive-in? live-cells (make-posn (+ ox i) y))
              "#"
              "."))
        (range 0 width 1))))

(define (world->rows cells origin-x origin-y width height)
  (map (lambda (j)
         (row->string cells origin-x (+ origin-y j) width))
       (range 0 height 1)))

(define (display-world cells origin-x origin-y width height gen)
  (begin
    (when (number? gen)
      (begin
        (display "Generation ")
        (display gen)
        (newline)))
    (for-each display-line
              (world->rows cells origin-x origin-y width height))))

;; ------------------------------------------------------------
;; 5.2 世代送り（簡易）
;; ------------------------------------------------------------

(define (evolve-ascii cells n origin-x origin-y width height)
  (local [(define (loop world gen)
            (begin
              (display-world world origin-x origin-y width height gen)
              (display-line "---")
              (cond
                [(>= gen n) world]
                [else (loop (next-generation world) (add1 gen))])))]
    (loop cells 0)))
;; ------------------------------------------------------------
;; 5.3 有名パターン
;; ------------------------------------------------------------

(define pattern-block
  (list (make-posn 0 0) (make-posn 0 1)
        (make-posn 1 0) (make-posn 1 1)))

(define pattern-blinker
  (list (make-posn 0 1) (make-posn 1 1) (make-posn 2 1)))

(define pattern-beacon
  (list (make-posn 0 0) (make-posn 0 1) (make-posn 1 0) (make-posn 1 1)
        (make-posn 2 2) (make-posn 2 3) (make-posn 3 2) (make-posn 3 3)))

(define pattern-glider
  (list (make-posn 1 0) (make-posn 2 1)
        (make-posn 0 2) (make-posn 1 2) (make-posn 2 2)))

(define pattern-toad
  (list (make-posn 1 0) (make-posn 2 0) (make-posn 3 0)
        (make-posn 0 1) (make-posn 1 1) (make-posn 2 1)))

;; パルサーは座標が大きく、骨格では空リスト（プレースホルダ）
(define pattern-pulsar empty)

(define (union-cells a b)
  (sort-cells (union-list a b)))

;; ------------------------------------------------------------
;; 5.4 Life 1.06 風パーサ（行単位）
;; ASL に string-split / string-trim が無いので最小実装
;; ------------------------------------------------------------

;; 先頭の空白位置（無ければ false）
(define (first-space-index s i)
  (cond
    [(>= i (string-length s)) false]
    [(string=? (string-ith s i) " ") i]
    [else (first-space-index s (add1 i))]))

;; 行が "x y" なら posn、コメント/不正なら false
(define (parse-life106-line line)
  (cond
    [(string=? line "") false]
    [(string=? (string-ith line 0) "#") false]
    [else
     (local [(define sp (first-space-index line 0))]
       (cond
         [(false? sp) false]
         [else
          (local [(define a (string->number (substring line 0 sp)))
                  (define b (string->number
                             (substring line (add1 sp) (string-length line))))]
            (if (and (number? a) (number? b))
                (make-posn a b)
                false))]))]))
;; ------------------------------------------------------------
;; check-expect
;; ------------------------------------------------------------

(define rows-block (world->rows pattern-block 0 0 4 4))

(check-expect (length rows-block) 4)
(check-expect (string-ith (first rows-block) 0) "#")
(check-expect (string-ith (first rows-block) 2) ".")

(check-expect
 (same-world?
  (place pattern-block 3 5)
  (list (make-posn 3 5) (make-posn 3 6)
        (make-posn 4 5) (make-posn 4 6)))
 true)

;; ブリンカー横 → 縦
(check-expect
 (same-world?
  (next-generation pattern-blinker)
  (list (make-posn 1 0) (make-posn 1 1) (make-posn 1 2)))
 true)

(check-expect
 (same-world? (step-n pattern-glider 4) (place pattern-glider 1 1))
 true)

(check-expect (parse-life106-line "# comment") false)
(check-expect (parse-life106-line "3 4") (make-posn 3 4))

(check-expect
 (length (union-cells pattern-block (place pattern-block 10 0)))
 8)

(test)
