;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; Issue #11 prototype: three gliders on a 60×40 wall board, drawn with Sketching.
;;
;;   #lang racket + (require sketching)
;;   Logic: code/life-engine.rkt (pure, rackunit-tested)
;;
;; Run (GUI, from repo root):
;;   racket code/sketching-gliders.rkt
;;
;; Requires: raco pkg install sketching
;;
;; Note: mise test:racket skips this file (opens a window).

#lang racket

(require sketching
         sketching/parameters
         lang/posn
         "life-engine.rkt")

;; ------------------------------------------------------------
;; Display constants
;; ------------------------------------------------------------

(define CELL-SIZE 12) ; square pixels per cell
(define CANVAS-W (* GRID-WIDTH CELL-SIZE))   ; 720
(define CANVAS-H (* GRID-HEIGHT CELL-SIZE))  ; 480
(define FPS 8) ; readable glider motion

;; Live world state (Sketching draw loop is imperative)
(define world (three-gliders-world))

;; ------------------------------------------------------------
;; Drawing helpers
;; ------------------------------------------------------------

;; draw-grid-lines : -> Void
(define (draw-grid-lines)
  (stroke 50 50 50)
  (stroke-weight 1)
  (for ([x (in-range 0 (add1 CANVAS-W) CELL-SIZE)])
    (line x 0 x CANVAS-H))
  (for ([y (in-range 0 (add1 CANVAS-H) CELL-SIZE)])
    (line 0 y CANVAS-W y)))

;; draw-live-cells : (Listof Posn) -> Void
;; Green filled squares (no stroke on cells so grid stays visible).
(define (draw-live-cells cells)
  (no-stroke)
  (fill 40 200 60) ; green
  (for ([c (in-list cells)])
    (define px (* (posn-x c) CELL-SIZE))
    (define py (* (posn-y c) CELL-SIZE))
    (square px py CELL-SIZE)))

;; ------------------------------------------------------------
;; Sketching lifecycle (manual, because #lang racket not #lang sketching)
;; ------------------------------------------------------------

(define (setup)
  (size CANVAS-W CANVAS-H)
  (set-frame-rate FPS)
  (set-title "Game of Life — 3 gliders (Sketching prototype, #11)")
  (background 15))

(define (draw)
  (background 15)
  (draw-grid-lines)
  (draw-live-cells world)
  ;; Advance one generation after painting (initial frame shows seed).
  (set! world (next-generation/wall world GRID-WIDTH GRID-HEIGHT)))

(module+ main
  (initialize)
  (setup)
  (current-draw draw)
  (start))
