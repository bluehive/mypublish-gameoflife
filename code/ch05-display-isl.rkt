;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;; 第5章 発展: 升目の見やすい表示 ＋ グライダー 0〜8 世代（ISL+）
;; 言語: Intermediate Student with lambda  (#lang htdp/isl+)
;; 公式: https://docs.racket-lang.org/htdp-langs/intermediate-lam.html
;; CLI: racket code/ch05-display-isl.rkt  （リポジトリ root から）
;;
;; 本線は code/ch05-display.rkt（#lang htdp/bsl）。
;; このファイルは「升目を目で読む」体験用の任意サンプルです。
;; ルールエンジンは第4章／本線 ch05 と同型の抜粋です。

#lang htdp/isl+

(require 2htdp/batch-io)
(require test-engine/racket-tests)

;; ------------------------------------------------------------
;; データ: 生存セルのリスト（第3–5章本線と同じ解釈）
;; ------------------------------------------------------------
;; ListOfPosn is one of:
;;  - empty
;;  - (cons Posn ListOfPosn)
;; interp. 今生きているセルの座標だけ。死は載せない。

;; 2×2 静止物（ブロック）
(define pattern-block
  (list (make-posn 0 0) (make-posn 0 1)
        (make-posn 1 0) (make-posn 1 1)))

;; グライダー（本線 pattern-glider と同座標）
(define pattern-glider
  (list (make-posn 1 0) (make-posn 2 1)
        (make-posn 0 2) (make-posn 1 2) (make-posn 2 2)))

;; place: ListOfPosn Number Number -> ListOfPosn
(define (place cells dx dy)
  (map (lambda (p)
         (make-posn (+ (posn-x p) dx)
                    (+ (posn-y p) dy)))
       cells))

;; 9×9 ビューポート中央付近のブロック
(define block-9 (place pattern-block 3 3))

;; 左上に余白を取ったグライダー（12×10 内で 0〜8 世代が見やすい）
(define glider-0 (place pattern-glider 1 1))

;; ------------------------------------------------------------
;; ルールエンジン（第4章と同型・抜粋）
;; ------------------------------------------------------------
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

(define (births? neighbors)
  (= neighbors 3))

(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

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

(define (member-posn? cell cells)
  (cond
    [(empty? cells) false]
    [(equal? cell (first cells)) true]
    [else (member-posn? cell (rest cells))]))

(define (count-alive-in neighbors live)
  (cond
    [(empty? neighbors) 0]
    [(member-posn? (first neighbors) live)
     (+ 1 (count-alive-in (rest neighbors) live))]
    [else (count-alive-in (rest neighbors) live)]))

(define (count-neighbors cell live)
  (count-alive-in (cell-neighbors cell) live))

(define (add-unique x xs)
  (cond
    [(member-posn? x xs) xs]
    [else (cons x xs)]))

(define (union-list a b)
  (cond
    [(empty? a) b]
    [else (union-list (rest a) (add-unique (first a) b))]))

(define (add-neighbors-of cell acc)
  (union-list (cell-neighbors cell) acc))

(define (fold-add-neighbors cells acc)
  (cond
    [(empty? cells) acc]
    [else (fold-add-neighbors (rest cells)
                              (add-neighbors-of (first cells) acc))]))

(define (candidate-cells live)
  (fold-add-neighbors live live))

(define (filter-next candidates live)
  (cond
    [(empty? candidates) empty]
    [(next-alive? (member-posn? (first candidates) live)
                  (count-neighbors (first candidates) live))
     (cons (first candidates)
           (filter-next (rest candidates) live))]
    [else (filter-next (rest candidates) live)]))

(define (next-generation cells)
  (filter-next (candidate-cells cells) cells))

(define (step-n cells n)
  (cond
    [(<= n 0) cells]
    [else (step-n (next-generation cells) (- n 1))]))

(define (cell<? a b)
  (cond
    [(< (posn-x a) (posn-x b)) true]
    [(> (posn-x a) (posn-x b)) false]
    [else (< (posn-y a) (posn-y b))]))

(define (insert-cell c sorted)
  (cond
    [(empty? sorted) (list c)]
    [(cell<? c (first sorted)) (cons c sorted)]
    [else (cons (first sorted) (insert-cell c (rest sorted)))]))

(define (sort-cells cells)
  (cond
    [(empty? cells) empty]
    [else (insert-cell (first cells) (sort-cells (rest cells)))]))

(define (same-world? a b)
  (equal? (sort-cells a) (sort-cells b)))

;; ------------------------------------------------------------
;; ASCII 表示（ISL+）
;; ------------------------------------------------------------
(define (char-at live x y)
  (if (member-posn? (make-posn x y) live) "#" "."))

(define (row-string live origin-x y width)
  (foldr string-append
         ""
         (map (lambda (i)
                (char-at live (+ origin-x i) y))
              (build-list width (lambda (i) i)))))

(define (world->rows cells origin-x origin-y width height)
  (map (lambda (j)
         (row-string cells origin-x (+ origin-y j) width))
       (build-list height (lambda (j) j))))

(define (rows->text rows)
  (cond
    [(empty? rows) ""]
    [(empty? (rest rows)) (first rows)]
    [else (string-append (first rows) "\n" (rows->text (rest rows)))]))

(define (world->text cells origin-x origin-y width height)
  (rows->text (world->rows cells origin-x origin-y width height)))

(define (world-banner title cells origin-x origin-y width height)
  (string-append title
                 "\n"
                 (world->text cells origin-x origin-y width height)
                 "\n"))

;; 世代 n の見出し付きテキスト（ビューポート固定）
(define (generation-banner n cells origin-x origin-y width height)
  (world-banner
   (string-append ";; --- generation "
                  (number->string n)
                  " ---")
   cells origin-x origin-y width height))

;; generations-text: 世代 0..max-n を連結（各回 next-generation）
(define (generations-text cells max-n origin-x origin-y width height)
  (local [(define (loop n world acc)
            (cond
              [(> n max-n) acc]
              [else
               (loop (add1 n)
                     (next-generation world)
                     (string-append
                      acc
                      (generation-banner n world
                                         origin-x origin-y
                                         width height)))]))]
    (loop 0 cells "")))

;; ビューポート: グライダー 0〜8 用 12×10、原点 (0,0)
(define VP-W 12)
(define VP-H 10)

;; ------------------------------------------------------------
;; テスト
;; ------------------------------------------------------------
(define rows-4 (world->rows pattern-block 0 0 4 4))
(check-expect rows-4
              (list "##.." "##.." "...." "...."))

(define rows-9 (world->rows block-9 0 0 9 9))
(check-expect (length rows-9) 9)
(check-expect rows-9
              (list "........."
                    "........."
                    "........."
                    "...##...."
                    "...##...."
                    "........."
                    "........."
                    "........."
                    "........."))

;; グライダー: 4 世代で形が戻り (1,1) 進む（第4章と同型）
(check-expect
 (same-world? (step-n pattern-glider 4) (place pattern-glider 1 1))
 true)
(check-expect
 (same-world? (step-n glider-0 4) (place glider-0 1 1))
 true)
(check-expect
 (same-world? (step-n glider-0 8) (place glider-0 2 2))
 true)

(check-expect (length (world->rows glider-0 0 0 VP-W VP-H)) VP-H)

;; ------------------------------------------------------------
;; デモ出力（1回の write-file）
;; ------------------------------------------------------------
(define DEMO-BLOCK
  (world-banner ";; --- 9x9 still life (block near center) ---"
                block-9 0 0 9 9))

(define DEMO-GLIDER-0-8
  (string-append
   ";; === glider generations 0..8 (viewport "
   (number->string VP-W)
   "x"
   (number->string VP-H)
   ", origin 0,0) ===\n"
   (generations-text glider-0 8 0 0 VP-W VP-H)
   ";; === end glider demo ===\n"))

(write-file
 'stdout
 (string-append DEMO-BLOCK
                "\n"
                DEMO-GLIDER-0-8
                ";; --- end all demos ---\n"))

(test)
