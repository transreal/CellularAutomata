# CellularAutomata API Reference

パッケージ: `CellularAutomata`
コンテキスト: `CellularAutomata``

## タイル生成

### GeneratePenroseRhombs[range, offset] → List
de Bruijn ペンタグリッド法でペンロースひし形タイルを生成する。
`range = {xmin, ymin, width, height}`, `offset = {g0, g1, g2, g3, g4}`
各タイルは Association `<|"label"->, "type"->"Fat"|"Thin", "vertices"->List(4点), "vertexKeys"->List(4つの5次元整数キー)|>` の形式。

### GeneratePenroseKD[range, offset] → List
ひし形分割からカイト&ダートタイルを生成する。各タイルは `"label"`, `"type"->"Kite"|"Dart"`, `"vertices"`, `"vertexKeys"` キーを持つ。`range`, `offset` の形式は `GeneratePenroseRhombs` と同じ。

### GenerateSquareGrid[cols, rows] → List
### GenerateSquareGrid[cols, rows, x0, y0] → List
正方格子タイルを生成する。`x0, y0` を省略すると `{0, 0}` から生成される（オフセット指定でグリッドの原点をずらせる）。各タイルは `"label"->{c,r}`, `"type"->"Square"`, `"vertices"`, `"vertexKeys"` を持つ。`BuildTilingGraph` と同じグラフ構造に対応。

### GenerateMultigridRhombs[symOrder, range, offset] → List
de Bruijn 多重グリッド法で `symOrder` 回対称のひし形タイリングを生成する。奇数 `n` は角度 `2πk/n` の `n` 個のグリッド族, 偶数 `n` は `n/2` 個のグリッド族を用いる。`offset` はグリッド族数と同じ要素数のリスト。例: 5=Penrose, 7=七角形, 8=Ammann–Beenker, 12=十二角形。返値は `GeneratePenroseRhombs` と同じタイル形式。

### GenerateABRhombs[range, offset] → List
Ammann–Beenker ひし形タイルを生成する。`GenerateMultigridRhombs[8, range, offset]` と等価。

### TileVertices[tile] → List
タイルの4頂点座標リストを返す。

### TileType[tile] → String
`"Fat"` または `"Thin"` を返す。KDタイルでは `"Kite"` または `"Dart"`。

## タイル描画

### DrawPenroseTiling[tiles, opts] → Graphics
ペンロースひし形タイリングを描画する。Fat=黄土色, Thin=青色で塗り分ける。

### DrawPenroseKD[tiles, opts] → Graphics
カイト&ダートタイリングをタイプ別色分けで描画する。

### DrawSquareGrid[tiles, opts] → Graphics
正方格子を白塗りで描画する。

### DrawMultigridTiling[tiles, opts] → Graphics
多重グリッドひし形タイリングをひし形タイプごとに自動配色して描画する。

### DrawABTiling[tiles, opts] → Graphics
Ammann–Beenker タイリングを描画する。`DrawMultigridTiling[tiles, opts]` と等価。

### PenroseTilingDemo[] → DynamicModule
インタラクティブなペンロースタイリングデモを表示する。サイズとオフセットをスライダーで操作できる。

## 近傍グラフ構築

### BuildTilingGraph[tiles] → Association
全タイルの頂点共有・辺共有近傍データを構築する。
返値のキー:
- `"tiles"` — 入力タイルリスト
- `"vertexToTiles"` — 頂点キー→タイルインデックスリスト
- `"mooreNeighbors"` — タイルインデックス→Moore近傍インデックスリスト
- `"neumannNeighbors"` — タイルインデックス→Neumann近傍インデックスリスト
- `"neumannDirections"` — タイルインデックス→(近傍インデックス→方向値)Association
- `"neighborTypes"` — タイルインデックス→neighborType(0-10, 15)

### BuildKDTilingGraph[tiles] → Association
カイト&ダートタイリングの近傍グラフを構築する。`BuildTilingGraph` と同じ構造。

### BuildSquareGridGraph[tiles, cols, rows] → Association
### BuildSquareGridGraph[tiles, cols, rows, x0, y0] → Association
正方格子の近傍グラフを構築する。`x0, y0` は `GenerateSquareGrid` に渡したオフセットと一致させる（省略時は `{0, 0}`）。Moore=8近傍, Neumann=4近傍(NSEW)。方向値: E=0, S=2, W=4, N=6。

## 近傍アクセサ

### MooreNeighbors[graph, tileIndex] → List
指定タイルのMoore近傍（頂点共有）インデックスリストを返す。

### NeumannNeighbors[graph, tileIndex] → List
指定タイルのNeumann近傍（辺共有）インデックスリストを返す。

### NeighborType[graph, tileIndex] → Integer
neighborType値(0-10または15)を返す。15は境界タイル。

### NeumannDirection[graph, tileIndex, neighborIndex] → Integer
タイルから見た近傍タイルの方向インデックスを返す。正方格子ではE=0,S=2,W=4,N=6。

## 近傍グラフ描画

### DrawTilingWithNeighborTypes[graph, opts] → Graphics
neighborTypeごとに色分けしてタイルを描画する。凡例としてタイプ分布をPlotLabelに表示。

### DrawTilingNeighborhood[graph, tileIndex, opts] → Graphics
指定タイルとその近傍をハイライト表示する。Moore近傍=水色, Neumann近傍=青, 対象タイル=赤。

## CAルール

### CreateCARule[ruleSpec] → Association
CAルールをruleSpec Associationから生成する。
`ruleSpec` のキー:
- `"type"` — `"GCA"` (デフォルト) または `"Partitioned"`
- `"transitionRules"` — ルールリスト(下記形式)
- `"rotational"` — `True`/`False` (デフォルト `False`)
- `"undefinedDefault"` — マッチしない場合の出力値, または `"same"` で元の値を保持
- `"defaultValue"` — 初期セル状態(整数)
- `"numStates"` — 状態数(省略時はルールの最大出力値+1から推定)
- `"neighborhood"` — `"Moore"` (デフォルト) または `"Neumann"` (GCAのみ)

GCAルール形式: `{centerState, count_state1, ..., count_stateN} -> newState`。カウントはMoore8近傍(正方格子)または頂点共有近傍(RPT)上で集計。Neumannの場合は辺共有4近傍。

Partitionedルール形式: `{centerState, nwState, neState, seState, swState} -> newState`。`rotational->True` の場合, 各ルールから4つの回転バリアントを自動生成。Partitioned CAは常にNeumann方向を使用。

例:
```mathematica
rule = CreateCARule[<|
  "type" -> "GCA",
  "transitionRules" -> {{0, _, 3} -> 1, {1, _, _} -> 0},
  "rotational" -> False,
  "undefinedDefault" -> "same",
  "defaultValue" -> 0,
  "numStates" -> 2
|>]
```

### CAStep[graph, rule, state] → List
CAルールを1ステップ適用し, 新しい状態リストを返す。`rule["type"]` が `"GCA"` なら `gcaStep`, `"Partitioned"` なら `partitionedStep` を呼ぶ。

### CAEvolve[graph, rule, initState, steps] → List
CAをstepsステップ発展させ, 全状態のリスト(長さsteps+1)を返す。

### ParseRuleFile[xmlString] → Association
iOSアプリの `.txt` ルールファイル文字列を解析してルール仕様Associationを返す。

## CA描画

### DrawCAState[graph, state] → Graphics
デフォルト色関数でCA状態を描画する。

### DrawCAState[graph, state, colorFunc, opts] → Graphics
`colorFunc` (整数→色)でタイルを色付けして描画する。

### CASimulator[cafile] → DynamicModule
ファイルベースの統合CAシミュレータを起動する。ジオメトリ(Square/RPT/KD), ルール種別(GCA/Partitioned/PCA5), 色を自動検出。Step/x10/x50/Reset/Random/Center Seedボタン付きUI。

### CASimulator[cafile, conffile] → DynamicModule
ルールファイルに加え `.caconf` 初期設定ファイルも読み込む。

### CASimulator[graph, rule] → DynamicModule
グラフとルールを直接渡すレガシーインターフェース。スカラーCA専用。

### $CAHistorySize
型: Integer, 初期値: 500
CAシミュレータの履歴用リングバッファサイズ。`CASimulator` を呼ぶ前に設定を変更する。

## PCA5（真の5近傍分割CA）

### CreatePCA5Rule[spec] → Association
真の5近傍分割CAルールを生成する。各セル状態はベクトル `{c, d1, d2, d3, d4}`（c=中心部, d1..d4=方向部）。
`spec` のキー:
- `"transitionRules"` — `{c_in,d1_in,d2_in,d3_in,d4_in} -> {c_out,d1_out,d2_out,d3_out,d4_out}` 形式のリスト
- `"rotational"` — `True` の場合, 入出力方向部ともに循環シフトした4バリアントを自動生成(Definition 2.4)
- `"numStates"` — 状態数
- `"defaultValue"` — 初期値

正方格子のスロット対応: `{c, N, E, S, W}` = インデックス `{1,2,3,4,5}`。
RPT/KDでは辺マッチングにより自動的にスロットを決定。

例:
```mathematica
rule = CreatePCA5Rule[<|
  "transitionRules" -> {{0,0,0,1,0} -> {0,1,0,0,0}},
  "rotational" -> True,
  "numStates" -> 2
|>]
```

### PCA5Step[graph, rule, state] → List
PCA5の1ステップを適用する。stateは5要素ベクトルのリスト。

### PCA5Evolve[graph, rule, initState, steps] → List
PCA5をstepsステップ発展させ, 全状態リストを返す。

### DrawPCA5State[graph, state] → Graphics
中心部(スロット1)の値で色付けしてPCA5状態を描画する。

### DrawPCA5State[graph, state, partIndex] → Graphics
`partIndex`(1-5)で指定したスロットの値で色付けする。

### PCA5Simulator[graph, rule] → DynamicModule
空の初期状態でPCA5シミュレータを起動する。

### PCA5Simulator[graph, rule, initState] → DynamicModule
初期状態を指定してPCA5シミュレータを起動する。

### PCA5Simulator[graph, rule, initState, colorAssoc] → DynamicModule
カスタム色Associationを指定してPCA5シミュレータを起動する。

### PCA5Simulator[graph, rule, initState, colorAssoc, configName] → DynamicModule
`configName` をエクスポートフォルダのベース名として設定する。PNG/PDF/MP4を `NotebookDirectory[]/configName_<suffix>/` に保存。

### IsReversiblePCA5[rule] → True|False
PCA5ルールが可逆(局所遷移関数が全単射)かどうかを返す。`rule["type"]` が `"PCA5"` でない場合や, 非可逆ルールの場合は `False`。判定は明示的に定義された遷移規則の出力(RHS)が全て相異なるかで行う(未定義入力は常に全単射を保つ出力を割り当てられるため考慮不要)。

### InvertPCA5Rule[rule] → Association
PCA5ルールの逆ルールを, 全入出力ペアを列挙してLHS/RHSを入れ替えることで生成する。`IsReversiblePCA5[rule]` が `True` の場合のみ有効。返値は `<|"invLookup"->Association, "type"->"PCA5"|>` 形式。

## iOS ファイルI/O

### LoadiOSRuleFile[path] → Association
iOSアプリの `.txt` ルールファイルを読み込む。Shift-JISエンコーディングを自動処理。
返値のキー:
- `"rule"` — `CreatePCA5Rule` または `CreateCARule` の結果
- `"metadata"` — `"geometryType"`, `"cellRange"`, `"offsetValues"`, `"stateColors"`, `"ruleType"`, `"name"` 等を含むAssociation

### LoadiOSConfigFile[path, graph] → List
iOSの `.caconf` 設定ファイルを読み込み, 指定グラフに対応した初期状態リストを返す。PCA5では `{c,d1,d2,d3,d4}` ベクトルのリスト, スカラーCAでは整数リスト。

### SaveiOSRuleFile[path, rule, metadata]
ルールをiOS形式の `.txt` ファイルに保存する。

### SaveiOSConfigFile[path, graph, state]
状態をiOSの `.caconf` 形式で保存する。

### InferCellRangeFromConfig[configPath, {width, height}] → List
`.caconf` ファイルを読み込み, 非デフォルトタイルの重心を中心とした `{xmin, ymin, width, height}` の `cellRange` を返す。

### InferCellRangeFromConfig[configPath] → List
最小バウンディング範囲の `cellRange` を返す。

### ExportPCA5Steps[graph, rule, state, nSteps, directory, colorAssoc]
PCA5をnStepsステップ発展させ, 各フレームをクリップしたPNG画像として保存する。ファイル名は `000.png`, `001.png`, ... 。Neumann近傍が4つ全て揃う内部タイルのみ描画。