;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; =============================================================================
;; 付録 H / Issue #11 — Sketching によるライフゲーム・アニメ（プロトタイプ）
;; =============================================================================
;;
;; 【なにをするファイルか】
;;   60×40 の有限盤（壁境界）の上で、グライダー 3 機が斜めに進む様子を
;;   Processing 風ライブラリ Sketching でアニメーション表示する。
;;
;; 【役割分担】
;;   ・ルール計算（B3/S23・壁） … code/life-engine.rkt（純粋関数・GUI なし）
;;   ・見た目（色・升目・ウィンドウ） … 本ファイル
;;   ・自動テスト … code/life-engine-test.rkt（rackunit）
;;
;; 【言語】
;;   #lang racket + (require sketching)
;;   ※ #lang sketching ではない。module-begin による自動起動の代わりに、
;;     末尾の (module+ main …) で initialize / setup / current-draw / start を手で呼ぶ。
;;
;; 【実行方法】（リポジトリ root から）
;;   raco pkg install sketching    ; 初回のみ
;;   racket code/sketching-gliders.rkt
;;
;; 【注意】
;;   ウィンドウを開くため、mise の test:racket では sketching-*.rkt をスキップする。
;;
;; =============================================================================

#lang racket

(require sketching              ; 描画 API（size / rect / square / stroke など）
         sketching/parameters    ; current-draw など（#lang racket 利用時に必要）
         lang/posn              ; make-posn / posn-x / posn-y
         "life-engine.rkt")     ; 盤サイズ・次世代計算・初期配置

;; ------------------------------------------------------------
;; 表示用の定数
;; ------------------------------------------------------------
;; 盤の論理サイズ GRID-WIDTH × GRID-HEIGHT は life-engine 側（60×40）。
;; ここでは「1 セルを何ピクセルの正方形で描くか」だけ決める。

(define CELL-SIZE 12) ; 1 セル = 12×12 ピクセルの正方形
(define CANVAS-W (* GRID-WIDTH CELL-SIZE))  ; 横 60×12 = 720 px
(define CANVAS-H (* GRID-HEIGHT CELL-SIZE)) ; 縦 40×12 = 480 px
(define FPS 8) ; 秒間フレーム数。グライダーの動きが見やすい速さ

;; ------------------------------------------------------------
;; ワールド状態
;; ------------------------------------------------------------
;; Sketching の draw は毎フレーム呼ばれる「手続き的」ループなので、
;; 生きているセルのリストを mutable な変数 world に置く。
;; 初期値は life-engine の three-gliders-world（離れた位置のグライダー 3 機）。

(define world (three-gliders-world))

;; ------------------------------------------------------------
;; 描画ヘルパ
;; ------------------------------------------------------------

;; draw-grid-lines : -> Void
;; 薄い灰色の縦線・横線で升目を描く（セルの境界を見やすくする）。
(define (draw-grid-lines)
  (stroke 50 50 50)   ; 線の色（暗めのグレー）
  (stroke-weight 1)   ; 線の太さ 1 px
  ;; 縦線: x = 0, CELL-SIZE, 2*CELL-SIZE, …, CANVAS-W
  (for ([x (in-range 0 (add1 CANVAS-W) CELL-SIZE)])
    (line x 0 x CANVAS-H))
  ;; 横線: y = 0, CELL-SIZE, …
  (for ([y (in-range 0 (add1 CANVAS-H) CELL-SIZE)])
    (line 0 y CANVAS-W y)))

;; draw-live-cells : (Listof Posn) -> Void
;; 生きているセルを緑の塗りつぶし正方形で描く。
;; セル自体には枠線を付けない（グリッド線と二重にならないように no-stroke）。
;;
;; 座標の対応:
;;   論理座標 (cx, cy)  →  画面左上原点のピクセル (cx*CELL-SIZE, cy*CELL-SIZE)
;;   square は左上 (px, py) と一辺の長さを取る。
(define (draw-live-cells cells)
  (no-stroke)
  (fill 40 200 60) ; 緑（R, G, B）
  (for ([c (in-list cells)])
    (define px (* (posn-x c) CELL-SIZE))
    (define py (* (posn-y c) CELL-SIZE))
    (square px py CELL-SIZE)))

;; ------------------------------------------------------------
;; Sketching のライフサイクル
;; ------------------------------------------------------------
;; #lang sketching では setup / draw を定義するだけで起動するが、
;; 本ファイルは #lang racket なので次の手順を module+ main で明示する:
;;   1. (initialize)     … ウィンドウ枠と描画コンテキスト
;;   2. (setup)          … サイズ・FPS・背景など初回設定
;;   3. (current-draw draw) … 毎フレーム呼ぶ関数を登録
;;   4. (start)          … イベントループ開始

;; setup : -> Void
;; ウィンドウサイズ・タイトル・目標 FPS・初期背景を設定する（起動時 1 回）。
(define (setup)
  (size CANVAS-W CANVAS-H)
  (set-frame-rate FPS)
  (set-title "Game of Life — 3 gliders (Sketching prototype, #11)")
  (background 15)) ; ほぼ黒

;; draw : -> Void
;; 毎フレーム: 背景を塗り直す → グリッド → 生きセル → 次世代へ更新。
;; 世代更新を「描画の後」にすることで、最初のフレームで初期配置が見える。
(define (draw)
  (background 15)
  (draw-grid-lines)
  (draw-live-cells world)
  ;; 壁境界の B3/S23 で 1 世代進める（盤外は常に死）
  (set! world (next-generation/wall world GRID-WIDTH GRID-HEIGHT)))

;; このファイルを racket で直接実行したときだけ GUI を起動する。
;; （他モジュールから require しただけではウィンドウは開かない）
(module+ main
  (initialize)
  (setup)
  (current-draw draw)
  (start))
