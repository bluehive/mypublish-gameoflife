;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; =============================================================================
;; 付録 H / Issue #11 — life-engine.rkt の rackunit テスト
;; =============================================================================
;;
;; 【なにをするファイルか】
;;   純ロジック（壁境界・B3/S23・グライダー）が正しいことを headless で検証する。
;;   GUI（Sketching）は起動しない。
;;
;; 【実行】（リポジトリ root から）
;;   racket code/life-engine-test.rkt
;;   成功時 exit 0 / 失敗時 exit 1
;;
;; =============================================================================

#lang racket

(require rackunit
         rackunit/text-ui
         lang/posn
         "life-engine.rkt")

(define life-engine-tests
  (test-suite
   "life-engine（壁境界・純 Racket）"

   ;; ----- ルール B3/S23 の単位テスト -----
   (test-case "survives?: 近傍 2 と 3 だけ生存"
     (check-true (survives? 2))
     (check-true (survives? 3))
     (check-false (survives? 1))
     (check-false (survives? 4)))

   (test-case "births?: 近傍 3 だけ誕生"
     (check-true (births? 3))
     (check-false (births? 2)))

   (test-case "next-alive?: 生存・誕生・死の組み合わせ"
     (check-true (next-alive? #t 2))   ; 生きていて近傍2 → 生き残る
     (check-true (next-alive? #f 3))   ; 死んでいて近傍3 → 誕生
     (check-false (next-alive? #t 0))  ; 孤立 → 死
     (check-false (next-alive? #f 2))) ; 近傍2では誕生しない

   ;; ----- 壁・盤内判定 -----
   (test-case "in-bounds?: 60×40 の端と外側"
     (check-true (in-bounds? (make-posn 0 0) GRID-WIDTH GRID-HEIGHT))
     (check-true (in-bounds? (make-posn 59 39) GRID-WIDTH GRID-HEIGHT))
     (check-false (in-bounds? (make-posn -1 0) GRID-WIDTH GRID-HEIGHT))
     (check-false (in-bounds? (make-posn 60 0) GRID-WIDTH GRID-HEIGHT))
     (check-false (in-bounds? (make-posn 0 40) GRID-WIDTH GRID-HEIGHT)))

   (test-case "壁=死: 角の単独セルは近傍0で次世代に消える"
     ;; 角 (0,0) の近傍の多くは盤外 → 生き近傍は 0
     (define corner (list (make-posn 0 0)))
     (check-equal? (count-neighbors/wall (make-posn 0 0) corner 5 5) 0)
     (check-true (same-world? (next-generation/wall corner 5 5) '())))

   ;; ----- 静物・振動子（壁から離して配置）-----
   (test-case "ブロックは静物（何世代でも同じ）"
     (define block
       (list (make-posn 1 1) (make-posn 1 2)
             (make-posn 2 1) (make-posn 2 2)))
     (check-true (same-world? (next-generation/wall block 10 10) block))
     (check-true (same-world? (step-n/wall block 5 10 10) block)))

   (test-case "ブリンカーは周期 2"
     (define blinker-h
       (list (make-posn 2 1) (make-posn 2 2) (make-posn 2 3)))
     (define blinker-v
       (list (make-posn 1 2) (make-posn 2 2) (make-posn 3 2)))
     (check-true (same-world? (next-generation/wall blinker-h 8 8) blinker-v))
     (check-true (same-world? (next-generation/wall blinker-v 8 8) blinker-h))
     (check-true (same-world? (step-n/wall blinker-h 2 8 8) blinker-h)))

   ;; ----- グライダー（盤の中央付近＝無限平面に近い）-----
   (test-case "単独グライダーは 4 世代で (+1,+1) 平行移動"
     (define g0 (place-glider 10 10))
     (define g4 (step-n/wall g0 4 GRID-WIDTH GRID-HEIGHT))
     (check-true (same-world? g4 (place-glider 11 11)))
     (check-equal? (length g0) 5)
     (check-equal? (length g4) 5))

   (test-case "グライダー 3 機: 4 世代後も各 5 セル・位置が +1,+1"
     (define w0 (three-gliders-world))
     (define w4 (step-n/wall w0 4 GRID-WIDTH GRID-HEIGHT))
     (check-equal? (length w0) 15) ; 5×3
     (check-equal? (length w4) 15)
     ;; 初期 (2,2)(20,8)(40,15) → 4 世代後は各 +1,+1
     (define expected
       (append (place-glider 3 3)
               (place-glider 21 9)
               (place-glider 41 16)))
     (check-true (same-world? w4 expected)))

   (test-case "壁にぶつかるとグライダーは壊れる（トーラスではない）"
     ;; 右端近くに置き、十分ステップするとセル数が減る
     (define g (place-glider 56 0))
     (define after (step-n/wall g 40 GRID-WIDTH GRID-HEIGHT))
     (check-true (< (length after) 5)))))

(module+ main
  (define failures (run-tests life-engine-tests 'verbose))
  (exit (if (zero? failures) 0 1)))
