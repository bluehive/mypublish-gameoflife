;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; rackunit tests for code/life-engine.rkt (Issue #11).
;; CLI (repo root): racket code/life-engine-test.rkt

#lang racket

(require rackunit
         rackunit/text-ui
         lang/posn
         "life-engine.rkt")

(define life-engine-tests
  (test-suite
   "life-engine (wall boundary, pure Racket)"

   ;; --- B3/S23 unit rules ---
   (test-case "survives? keeps 2 and 3 only"
     (check-true (survives? 2))
     (check-true (survives? 3))
     (check-false (survives? 1))
     (check-false (survives? 4)))

   (test-case "births? only on 3"
     (check-true (births? 3))
     (check-false (births? 2)))

   (test-case "next-alive?"
     (check-true (next-alive? #t 2))
     (check-true (next-alive? #f 3))
     (check-false (next-alive? #t 0))
     (check-false (next-alive? #f 2)))

   ;; --- bounds / wall ---
   (test-case "in-bounds? on 60×40"
     (check-true (in-bounds? (make-posn 0 0) GRID-WIDTH GRID-HEIGHT))
     (check-true (in-bounds? (make-posn 59 39) GRID-WIDTH GRID-HEIGHT))
     (check-false (in-bounds? (make-posn -1 0) GRID-WIDTH GRID-HEIGHT))
     (check-false (in-bounds? (make-posn 60 0) GRID-WIDTH GRID-HEIGHT))
     (check-false (in-bounds? (make-posn 0 40) GRID-WIDTH GRID-HEIGHT)))

   (test-case "outside neighbors do not count (wall = dead)"
     ;; Lone cell at corner: all out-of-board neighbors ignored → 0 live neighbors
     (define corner (list (make-posn 0 0)))
     (check-equal? (count-neighbors/wall (make-posn 0 0) corner 5 5) 0)
     ;; After one step, isolated cell dies
     (check-true (same-world? (next-generation/wall corner 5 5) '())))

   ;; --- still life / oscillator (away from walls) ---
   (test-case "block is still life"
     (define block
       (list (make-posn 1 1) (make-posn 1 2)
             (make-posn 2 1) (make-posn 2 2)))
     (check-true (same-world? (next-generation/wall block 10 10) block))
     (check-true (same-world? (step-n/wall block 5 10 10) block)))

   (test-case "blinker period 2"
     (define blinker-h
       (list (make-posn 2 1) (make-posn 2 2) (make-posn 2 3)))
     (define blinker-v
       (list (make-posn 1 2) (make-posn 2 2) (make-posn 3 2)))
     (check-true (same-world? (next-generation/wall blinker-h 8 8) blinker-v))
     (check-true (same-world? (next-generation/wall blinker-v 8 8) blinker-h))
     (check-true (same-world? (step-n/wall blinker-h 2 8 8) blinker-h)))

   ;; --- glider translation (infinite-like, center of large board) ---
   (test-case "single glider advances +1,+1 every 4 generations"
     (define g0 (place-glider 10 10))
     (define g4 (step-n/wall g0 4 GRID-WIDTH GRID-HEIGHT))
     (check-true (same-world? g4 (place-glider 11 11)))
     (check-equal? (length g0) 5)
     (check-equal? (length g4) 5))

   (test-case "three gliders: each component still 5 cells after 4 steps"
     (define w0 (three-gliders-world))
     (define w4 (step-n/wall w0 4 GRID-WIDTH GRID-HEIGHT))
     (check-equal? (length w0) 15)
     (check-equal? (length w4) 15)
     ;; Expected positions: each glider shifted by (1,1)
     (define expected
       (append (place-glider 3 3)
               (place-glider 21 9)
               (place-glider 41 16)))
     (check-true (same-world? w4 expected)))

   (test-case "glider dies against wall (not torus)"
     ;; Place near right edge so SE glider hits the wall and collapses.
     (define g (place-glider 56 0))
     (define after (step-n/wall g 40 GRID-WIDTH GRID-HEIGHT))
     (check-true (< (length after) 5)))))

(module+ main
  (define failures (run-tests life-engine-tests 'verbose))
  (exit (if (zero? failures) 0 1)))
