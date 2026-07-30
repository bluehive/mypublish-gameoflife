;; Licensed under the MIT License.
;; See LICENSE file in the project root for full license text.
;;
;; =============================================================================
;; 付録 H / Issue #13 — big-bang によるライフゲーム・アニメ（BSL）
;; =============================================================================
;;
;; 【なにをするファイルか】
;;   60×40 の有限盤（壁境界）の上で、グライダー 3 機が斜めに進む様子を
;;   2htdp/image + 2htdp/universe（big-bang）でアニメーション表示する。
;;
;; 【役割分担】
;;   ・ルールの正しさ（check-expect・headless）
;;       → code/life-engine.rkt（本ファイルではテストしない）
;;   ・見た目（色・升目・ウィンドウ・世代の進行）
;;       → 本ファイル
;;
;; 【言語】
;;   #lang htdp/bsl
;;   ・本編（第1–5章）と同じ Beginning Student Language
;;   ・Sketching / #lang racket / set! は使わない（Issue #13 案 A）
;;
;; 【なぜロジックを life-engine と二重に書くか】
;;   BSL のモジュールは、通常の Racket のように provide / require で
;;   定義を共有しにくい。付録の「Run 一発で動く自己完結デモ」にするため、
;;   壁境界ロジックは life-engine.rkt と【同型】の定義をここに置く。
;;   正しさの正本・自動テストは必ず life-engine.rkt を見ること。
;;
;; 【Sketching 版（Issue #11）との対応】
;;   | 旧 Sketching              | 本ファイル（BSL + big-bang）        |
;;   |---------------------------|-------------------------------------|
;;   | 可変 world + set!         | 世界は値（ListOf Posn）              |
;;   | 副作用でキャンバスに描画   | to-draw が Image を返す             |
;;   | 手続き的 draw ループ       | on-tick が次の世界を返す             |
;;   | 0 引数の setup / draw      | 世界を受け取る 1 引数関数            |
;;   | raco pkg install sketching | 追加パッケージ不要（2htdp 標準）    |
;;
;; 【実行方法】（リポジトリ root から）
;;   racket code/big-bang-gliders.rkt
;;   または DrRacket で本ファイルを開き Run
;;   → ウィンドウが開き、約 8 fps で世代が進む
;;
;; 【注意】
;;   ウィンドウを開くため、mise の test:racket では big-bang-*.rkt をスキップする。
;;   ロジック検証は: racket code/life-engine.rkt
;;
;; 【データの流れ（読む順）】
;;   1. 定数（盤サイズ・ピクセル・色・グライダー形）
;;   2. 壁境界の純関数（B3/S23・候補セル・次世代）
;;   3. 初期配置 THREE-GLIDERS-WORLD
;;   4. 描画（Image を組み立てる再帰）
;;   5. tock / render と big-bang 起動
;;
;; =============================================================================

#lang htdp/bsl

(require 2htdp/image)     ; empty-scene / square / place-image / add-line / make-color
(require 2htdp/universe)  ; big-bang / on-tick / to-draw

;; ============================================================
;; データ定義（本ファイルで扱う世界）
;; ============================================================
;;
;; World は ListOf Posn
;;   - empty
;;   - (cons Posn World)
;; 解釈: 「いま生きているセル」の座標だけを載せる疎な表現。
;;       死んでいるマスはリストに載せない（第3–4章と同じ考え方）。
;;
;; 画面座標との対応:
;;   論理セル (cx, cy)  … 盤の列 cx・行 cy（0 始まり、y は下方向）
;;   ピクセル            … 左上原点。1 セルは CELL-SIZE ピクセル四方
;;   place-image の位置  … 画像の【中心】を置く座標
;;     中心 x = cx * CELL-SIZE + CELL-SIZE/2
;;     中心 y = cy * CELL-SIZE + CELL-SIZE/2

;; ------------------------------------------------------------
;; 盤・表示定数
;; ------------------------------------------------------------
;; 盤の論理サイズ GRID-WIDTH × GRID-HEIGHT は life-engine と同じ 60×40
;; （Issue #11 で確定した仕様を Issue #13 でも維持）。

(define GRID-WIDTH 60)  ; 横方向のセル数
(define GRID-HEIGHT 40) ; 縦方向のセル数

;; 1 セルを何ピクセルの正方形で描くか。
;; 60×12 = 720、40×12 = 480 → 一般的なウィンドウサイズに収まる。
(define CELL-SIZE 12)

(define CANVAS-W (* GRID-WIDTH CELL-SIZE))  ; キャンバス横幅（px）= 720
(define CANVAS-H (* GRID-HEIGHT CELL-SIZE)) ; キャンバス高さ（px）= 480

;; on-tick の第 2 引数: 「1 世代あたり何秒待つか」。
;; 1/8 秒 → おおよそ 8 fps。グライダーの斜め移動が見やすい速さ。
;; 速くしたいときは 1/16、遅くしたいときは 1/4 などに変える。
(define TICK-RATE 1/8)

;; 色（文字列または make-color の RGB）
;; LIVE-COLOR … 生きセルの塗り。旧 Sketching の緑 (40,200,60) に近い lime
;; GRID-COLOR … 升目の線（暗めのグレー）
;; BG-COLOR   … 背景（ほぼ黒）
(define LIVE-COLOR "lime")
(define GRID-COLOR (make-color 50 50 50))
(define BG-COLOR (make-color 15 15 15))

;; 南東へ進む標準グライダー（第4章・life-engine と同じ相対座標）。
;;
;;   列→  0 1 2
;; 行 0   . O .
;; 行 1   . . O
;; 行 2   O O O
;;
;; 実際の盤上の位置へは place-glider で平行移動する。
(define GLIDER
  (list (make-posn 1 0)
        (make-posn 2 1)
        (make-posn 0 2)
        (make-posn 1 2)
        (make-posn 2 2)))

;; ============================================================
;; 壁境界ロジック（life-engine.rkt と同型・BSL）
;; ============================================================
;;
;; 規則 B3/S23:
;;   ・生きていて近傍 2 または 3 → 生き残る（S23）
;;   ・死んでいて近傍ちょうど 3 → 誕生（B3）
;;   ・それ以外 → 次世代は死
;;
;; 壁境界:
;;   ・盤外のマスは存在しない（トーラス＝左右上下がつながる、ではない）
;;   ・盤外は常に「死」として近傍に数えない
;;   ・端に突っ込んだグライダーはやがて形を崩して消える
;;
;; BSL の都合:
;;   ・map / filter / lambda / for は使わない → 構造的再帰
;;   ・0 引数関数は定義できない → 初期配置は定数 THREE-GLIDERS-WORLD
;;   ・set! / begin は使わない → 次世代は新しいリストを返す

;; survives? : Number -> Boolean
;; いま生きているセルが、近傍数 neighbors のとき次世代も生き残るか。
(define (survives? neighbors)
  (or (= neighbors 2) (= neighbors 3)))

;; births? : Number -> Boolean
;; いま死んでいるセルが、近傍数 neighbors のとき次世代に誕生するか。
(define (births? neighbors)
  (= neighbors 3))

;; next-alive? : Boolean Number -> Boolean
;; 現在の生死 currently-alive? と近傍数から、次世代に生きるべきかを決める。
(define (next-alive? currently-alive? neighbors)
  (if currently-alive?
      (survives? neighbors)
      (births? neighbors)))

;; in-bounds? : Posn Number Number -> Boolean
;; 壁境界: 有効な座標は 0 ≤ x < width かつ 0 ≤ y < height のみ。
;; （(- width 1) は BSL で sub1 の代わりに使える引き算）
(define (in-bounds? cell width height)
  (and (<= 0 (posn-x cell) (- width 1))
       (<= 0 (posn-y cell) (- height 1))))

;; shift-cell : Posn Number Number -> Posn
;; セルを (dx, dy) だけ平行移動した新しい Posn を返す（元の値は変えない）。
(define (shift-cell cell dx dy)
  (make-posn (+ (posn-x cell) dx)
             (+ (posn-y cell) dy)))

;; cell-neighbors : Posn -> ListOf Posn
;; ムーア近傍（周囲 8 マス）の座標リスト。
;; 盤外の座標もそのまま含み得る → 壁判定は count / candidate 側で行う。
;;
;;   (x-1,y-1) (x,y-1) (x+1,y-1)
;;   (x-1,y  )         (x+1,y  )
;;   (x-1,y+1) (x,y+1) (x+1,y+1)
(define (cell-neighbors cell)
  (list (shift-cell cell -1 -1)
        (shift-cell cell 0 -1)
        (shift-cell cell 1 -1)
        (shift-cell cell -1 0)
        (shift-cell cell 1 0)
        (shift-cell cell -1 1)
        (shift-cell cell 0 1)
        (shift-cell cell 1 1)))

;; member-posn? : Posn ListOfPosn -> Boolean
;; 座標 cell がリスト cells に含まれるか（equal? による構造比較）。
(define (member-posn? cell cells)
  (cond
    [(empty? cells) false]
    [(equal? cell (first cells)) true]
    [else (member-posn? cell (rest cells))]))

;; count-alive-in/wall : ListOfPosn ListOfPosn Number Number -> Number
;; 近傍リスト neighbors のうち、
;;   (1) 盤内であり、かつ
;;   (2) 生きリスト live に含まれる
;; ものの個数。盤外は数えない（＝壁＝死）。
(define (count-alive-in/wall neighbors live width height)
  (cond
    [(empty? neighbors) 0]
    [(and (in-bounds? (first neighbors) width height)
          (member-posn? (first neighbors) live))
     (+ 1 (count-alive-in/wall (rest neighbors) live width height))]
    [else (count-alive-in/wall (rest neighbors) live width height)]))

;; count-neighbors/wall : Posn ListOfPosn Number Number -> Number
;; cell の壁付き近傍カウント（0〜8）。
(define (count-neighbors/wall cell live width height)
  (count-alive-in/wall (cell-neighbors cell) live width height))

;; add-unique : Posn ListOfPosn -> ListOfPosn
;; x が xs に無ければ先頭に cons。集合的な「重複なく追加」。
(define (add-unique x xs)
  (cond
    [(member-posn? x xs) xs]
    [else (cons x xs)]))

;; union-list : ListOfPosn ListOfPosn -> ListOfPosn
;; リスト a の要素を b に重複なく合流させる。
(define (union-list a b)
  (cond
    [(empty? a) b]
    [else (union-list (rest a) (add-unique (first a) b))]))

;; filter-in-bounds : ListOfPosn Number Number -> ListOfPosn
;; 盤内の座標だけ残す（構造的再帰。BSL に filter は無い）。
(define (filter-in-bounds cells width height)
  (cond
    [(empty? cells) empty]
    [(in-bounds? (first cells) width height)
     (cons (first cells)
           (filter-in-bounds (rest cells) width height))]
    [else (filter-in-bounds (rest cells) width height)]))

;; add-neighbors-of/wall : Posn ListOfPosn Number Number -> ListOfPosn
;; cell の近傍のうち盤内だけを acc に合流。
(define (add-neighbors-of/wall cell acc width height)
  (union-list (filter-in-bounds (cell-neighbors cell) width height) acc))

;; fold-add-neighbors/wall : ListOfPosn ListOfPosn Number Number -> ListOfPosn
;; 生きセル列の各要素について近傍を畳み込み、候補集合を広げる。
(define (fold-add-neighbors/wall cells acc width height)
  (cond
    [(empty? cells) acc]
    [else
     (fold-add-neighbors/wall
      (rest cells)
      (add-neighbors-of/wall (first cells) acc width height)
      width height)]))

;; candidate-cells/wall : ListOfPosn Number Number -> ListOfPosn
;; 次世代を判定すべき座標一覧
;;   = 盤内の生きセル ∪ それらの盤内近傍
;; （遠くの死マスは生まれようがないので見ない＝疎表現の利点）
(define (candidate-cells/wall live width height)
  (fold-add-neighbors/wall
   (filter-in-bounds live width height)
   (filter-in-bounds live width height)
   width height))

;; filter-next/wall : ListOfPosn ListOfPosn Number Number -> ListOfPosn
;; 候補それぞれについて next-alive? を適用し、次世代に生きるセルだけ残す。
(define (filter-next/wall candidates live width height)
  (cond
    [(empty? candidates) empty]
    [(next-alive? (member-posn? (first candidates) live)
                  (count-neighbors/wall (first candidates) live width height))
     (cons (first candidates)
           (filter-next/wall (rest candidates) live width height))]
    [else (filter-next/wall (rest candidates) live width height)]))

;; next-generation/wall : ListOfPosn Number Number -> ListOfPosn
;; 壁境界の B3/S23 を 1 世代進めた【新しい】ワールドを返す。
;; 引数 cells は変更しない（純関数・set! なし）。
(define (next-generation/wall cells width height)
  (filter-next/wall (candidate-cells/wall cells width height)
                    cells
                    width
                    height))

;; ------------------------------------------------------------
;; 配置ヘルパ
;; ------------------------------------------------------------

;; place-cells : ListOfPosn Number Number -> ListOfPosn
;; パターン全体を (dx, dy) だけずらす（各 Posn を新しく作る）。
(define (place-cells cells dx dy)
  (cond
    [(empty? cells) empty]
    [else
     (cons (make-posn (+ (posn-x (first cells)) dx)
                      (+ (posn-y (first cells)) dy))
           (place-cells (rest cells) dx dy))]))

;; place-glider : Number Number -> ListOfPosn
;; 相対パターン GLIDER を、左上付近が (x, y) になるよう置いた 5 セルを返す。
(define (place-glider x y)
  (place-cells GLIDER x y))

;; THREE-GLIDERS-WORLD : ListOfPosn
;; 60×40 盤向けの初期配置。互いに干渉しにくい位置にグライダー 3 機。
;;   機1: (2, 2) 付近
;;   機2: (20, 8) 付近
;;   機3: (40, 15) 付近
;; BSL は「引数ゼロの関数」を許さないため、0 引数の three-gliders-world
;; ではなく【定数】として定義する（第1章の「定数 vs 0 引数」と同じ理由）。
(define THREE-GLIDERS-WORLD
  (append (place-glider 2 2)
          (place-glider 20 8)
          (place-glider 40 15)))

;; ============================================================
;; 描画（値としての Image）
;; ============================================================
;;
;; Sketching は stroke / line / square が「今のキャンバスに副作用で描く」。
;; 本編 BSL では Image は【値】であり、
;;   empty-scene → add-line → place-image
;; と「前の画像から新しい画像を作る」関数合成で組み立てる。
;;
;; BSL に for ループは無いので、縦線・横線・生きセルの走査はすべて再帰。

;; draw-v-lines : Number Image -> Image
;; 縦のグリッド線を x = 0, CELL-SIZE, 2*CELL-SIZE, …, CANVAS-W と載せる。
;; x がキャンバス右端を超えたら scene をそのまま返す（再帰の停止条件）。
(define (draw-v-lines x scene)
  (cond
    [(> x CANVAS-W) scene]
    [else
     (draw-v-lines (+ x CELL-SIZE)
                   (add-line scene x 0 x CANVAS-H GRID-COLOR))]))

;; draw-h-lines : Number Image -> Image
;; 横のグリッド線を y = 0, CELL-SIZE, …, CANVAS-H と載せる。
(define (draw-h-lines y scene)
  (cond
    [(> y CANVAS-H) scene]
    [else
     (draw-h-lines (+ y CELL-SIZE)
                   (add-line scene 0 y CANVAS-W y GRID-COLOR))]))

;; draw-grid : Image -> Image
;; 縦線を全部載せたあと横線を全部載せる（升目の完成）。
(define (draw-grid scene)
  (draw-h-lines 0 (draw-v-lines 0 scene)))

;; cell-center-x : Posn -> Number
;; 論理セルの中心の画面 x 座標（place-image は中心基準）。
(define (cell-center-x cell)
  (+ (* (posn-x cell) CELL-SIZE) (/ CELL-SIZE 2)))

;; cell-center-y : Posn -> Number
;; 論理セルの中心の画面 y 座標。
(define (cell-center-y cell)
  (+ (* (posn-y cell) CELL-SIZE) (/ CELL-SIZE 2)))

;; 生きセル用の正方形画像（毎回 square を作らず定数にしておく）。
;; "solid" = 塗りつぶし。枠線はグリッド側に任せるのでセル自体には付けない。
(define LIVE-SQUARE (square CELL-SIZE "solid" LIVE-COLOR))

;; draw-live-cells : ListOfPosn Image -> Image
;; 生きているセルを緑の正方形で scene に載せる。
;; 先頭セルを place-image した新しい画像を作り、残りは再帰。
(define (draw-live-cells cells scene)
  (cond
    [(empty? cells) scene]
    [else
     (draw-live-cells
      (rest cells)
      (place-image LIVE-SQUARE
                   (cell-center-x (first cells))
                   (cell-center-y (first cells))
                   scene))]))

;; render : World -> Image
;; big-bang の to-draw に渡す描画関数。
;; 手順: 背景 empty-scene → グリッド線 → 生きセル。
;; （毎ティック「全部描き直した Image」を返す。部分更新の set! は不要）
(define (render world)
  (draw-live-cells world
                   (draw-grid (empty-scene CANVAS-W CANVAS-H BG-COLOR))))

;; tock : World -> World
;; big-bang の on-tick に渡す更新関数。
;; 壁境界の B3/S23 で 1 世代進めた新しいリストを返す。
;; 旧 Sketching の (set! world (next-generation/wall …)) に相当するが、
;; 代入ではなく「返り値」が次の世界になる。
(define (tock world)
  (next-generation/wall world GRID-WIDTH GRID-HEIGHT))

;; ============================================================
;; 起動（ここを評価するとウィンドウが開く）
;; ============================================================
;;
;; big-bang の役割（第5章 5.6 の発展と同じ部品）:
;;   第1引数 … 初期の世界（THREE-GLIDERS-WORLD）
;;   on-tick … 時間が進むたびに呼ぶ（tock と間隔 TICK-RATE）
;;   to-draw … いまの世界を Image にする（render）
;;   name    … ウィンドウタイトル
;;
;; 閉じる: ウィンドウの閉じるボタン、または DrRacket の Stop。

(big-bang THREE-GLIDERS-WORLD
  (on-tick tock TICK-RATE)
  (to-draw render)
  (name "Game of Life — 3 gliders (BSL big-bang, #13)"))
