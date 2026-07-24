;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;; 第3章: グリッド表現（BSL・デザインレシピ順）
;; CLI: racket code/ch03-grid.rkt  （リポジトリ root から）

#lang htdp/bsl

(require test-engine/racket-tests)

;; ============================================================
;; デザインレシピの順番（このファイルの並び）
;; 1. データ定義  2. 解釈(interp.)  3. 具体例
;; 4. テンプレート(...)  5. スタブ  6. check-expect  7. 本体
;; ============================================================

;; ------------------------------------------------------------
;; 【本線 A】ListOfPosn — 生存セルだけ（スパース）
;; ------------------------------------------------------------

;; 1. データ定義
;; ListOfPosn is one of:
;;  - empty
;;  - (cons Posn ListOfPosn)

;; 2. 解釈 (interp.)
;; interp. 今生きているセルの座標だけを並べたリスト。
;;         死んでいるマスはリストに載せない。空の盤は empty。

;; 3. 具体例
(define WORLD0 empty)
(define WORLD1 (cons (make-posn 0 0) empty))
(define WORLD-BLOCK
  (list (make-posn 1 1) (make-posn 1 2)
        (make-posn 2 1) (make-posn 2 2)))

;; 4. テンプレート（骨。... は BSL のプレースホルダ。呼び出しはしない）
;; listof-posn-template: ListOfPosn -> Any
(define (listof-posn-template w)
  (cond
    [(empty? w) (...)]
    [else
     (... (first w)
          (listof-posn-template (rest w)))]))

;; 5. スタブ（一時的。完成時は本体で置き換える — コメントのまま残す）
;; alive?: ListOfPosn Posn -> Boolean
;; (define (alive? cells cell) false)

;; 6–7. 本体 + テスト（所属判定）
;; alive?: リスト cells に座標 cell があれば true
(define (alive? cells cell)
  (cond
    [(empty? cells) false]
    [(equal? (first cells) cell) true]
    [else (alive? (rest cells) cell)]))

(check-expect (alive? WORLD-BLOCK (make-posn 1 1)) true)
(check-expect (alive? WORLD-BLOCK (make-posn 0 0)) false)
(check-expect (alive? WORLD0 (make-posn 0 0)) false)

;; ------------------------------------------------------------
;; 【理解用 B】密グリッド — すべてのマスを 0/1 で書く
;; ------------------------------------------------------------

;; 1. データ定義
;; CellValue is 0 or 1
;; Row is ListOf CellValue
;; Grid is ListOf Row

;; 2. 解釈 (interp.)
;; interp. CellValue: 0 = 死, 1 = 生
;; interp. Grid: 上から下へ行、左から右へ列の表

;; 3. 具体例
(define TINY-GRID
  (list (list 0 1 0)
        (list 0 0 1)
        (list 1 1 1)))
(define TINY-ROW0 (list 0 1 0))

;; 4. テンプレート（Grid を「行のリスト」として歩く骨）
;; grid-template: Grid -> Any
(define (grid-template g)
  (cond
    [(empty? g) (...)]
    [else
     (... (first g)
          (grid-template (rest g)))]))

;; 5. スタブ（コメント）
;; grid-ref: Grid Number Number -> Number
;; (define (grid-ref g r c) 0)

;; 6–7. 本体 + テスト
;; grid-ref: 表 g の行 r・列 c の 0 または 1
(: grid-ref (Any Number Number -> Number))
(define (grid-ref g r c)
  (list-ref (list-ref g r) c))

(check-expect (grid-ref TINY-GRID 0 1) 1)
(check-expect (grid-ref TINY-GRID 2 0) 1)
(check-expect (grid-ref TINY-GRID 0 0) 0)

(test)
