;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;; 第5章 発展: 9×9 静止盤を見やすく表示（ISL+）
;; 言語: Intermediate Student with lambda  (#lang htdp/isl+)
;; 公式: https://docs.racket-lang.org/htdp-langs/intermediate-lam.html
;; CLI: racket code/ch05-display-isl.rkt  （リポジトリ root から）
;;
;; 本線は code/ch05-display.rkt（#lang htdp/bsl）。
;; このファイルは「升目を目で読む」体験用の任意サンプルです。

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

;; 2×2 静止物（ブロック）・原点付近
(define pattern-block
  (list (make-posn 0 0) (make-posn 0 1)
        (make-posn 1 0) (make-posn 1 1)))

;; place: ListOfPosn Number Number -> ListOfPosn
;; すべての生存セルを (dx, dy) だけ平行移動する
(define (place cells dx dy)
  (map (lambda (p)
         (make-posn (+ (posn-x p) dx)
                    (+ (posn-y p) dy)))
       cells))

;; 9×9 ビューポートの中央付近に置くブロック
(define block-9 (place pattern-block 3 3))

;; member-posn?: Posn ListOfPosn -> Boolean
(define (member-posn? cell cells)
  (cond
    [(empty? cells) false]
    [(equal? cell (first cells)) true]
    [else (member-posn? cell (rest cells))]))

;; char-at: ListOfPosn Number Number -> String
(define (char-at live x y)
  (if (member-posn? (make-posn x y) live) "#" "."))

;; row-string: ListOfPosn Number Number Number -> String
;; 行 y を、列 origin-x から width マス分の文字列にする（ISL+ の map/lambda）
(define (row-string live origin-x y width)
  (foldr string-append
         ""
         (map (lambda (i)
                (char-at live (+ origin-x i) y))
              (build-list width (lambda (i) i)))))

;; world->rows: ListOfPosn Number Number Number Number -> ListOfString
(define (world->rows cells origin-x origin-y width height)
  (map (lambda (j)
         (row-string cells origin-x (+ origin-y j) width))
       (build-list height (lambda (j) j))))

;; rows->text: ListOfString -> String
;; 行リストを改行でつないだ1本の文字列にする（盤として読みやすい形）
(define (rows->text rows)
  (cond
    [(empty? rows) ""]
    [(empty? (rest rows)) (first rows)]
    [else (string-append (first rows) "\n" (rows->text (rest rows)))]))

;; world->text: ListOfPosn Number Number Number Number -> String
(define (world->text cells origin-x origin-y width height)
  (rows->text (world->rows cells origin-x origin-y width height)))

;; show-world: 盤を標準出力に升目として出す（副作用・学習用）
;; write-file は 2htdp/batch-io。'stdout でターミナル／相互作用に出る。
(define (show-world cells origin-x origin-y width height)
  (write-file 'stdout
              (string-append
               (world->text cells origin-x origin-y width height)
               "\n")))

;; ------------------------------------------------------------
;; テスト（データとしての正しさ）
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

(check-expect
 (world->text block-9 0 0 9 9)
 (string-append
  ".........\n"
  ".........\n"
  ".........\n"
  "...##....\n"
  "...##....\n"
  ".........\n"
  ".........\n"
  ".........\n"
  "........."))

;; ------------------------------------------------------------
;; デモ: 9×9 静止ブロックを升目表示
;; （racket でこのファイルを実行すると、テストの前後に盤が出ます）
;; ------------------------------------------------------------
(write-file 'stdout ";; --- 9x9 still life (block near center) ---\n")
(show-world block-9 0 0 9 9)
(write-file 'stdout ";; --- end demo ---\n")

(test)
