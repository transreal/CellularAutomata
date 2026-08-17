# CellularAutomata ユーザーマニュアル

## 概要

CellularAutomataパッケージは、ペンローズ・ローマスタイリング、一般化de Bruijnマルチグリッドタイリング（Ammann-Beenker等）、および正方格子上でのセルオートマトンシミュレーションを提供します。de Bruijn五角格子法によるペンローズタイリング生成、任意対称位数のマルチグリッドタイリング生成、近傍グラフ構築、一般セルオートマトン（GCA）および真の分割セルオートマトン（PCA5）のシミュレーションが可能です。

## タイリング生成

### ペンローズ・ローマスタイリング

#### GeneratePenroseRhombs
ペンローズ・ローマスタイルを生成します。

```mathematica
GeneratePenroseRhombs[range, offset]
```

**例:**
```mathematica
tiles = GeneratePenroseRhombs[{-5, -5, 10, 10}, {0, 0, 0, 0, 0}];
```

#### DrawPenroseTiling
タイリングをグラフィックスとして描画します。

```mathematica
DrawPenroseTiling[tiles]
```

**例:**
```mathematica
DrawPenroseTiling[tiles]
```

#### TileVertices / TileType
タイルの頂点座標と種類を取得します。

```mathematica
TileVertices[tile]
TileType[tile]
```

**例:**
```mathematica
vertices = TileVertices[tiles[[1]]];
type = TileType[tiles[[1]]]; (* "Fat" または "Thin" *)
```

### ペンローズ・カイト&ダート

#### GeneratePenroseKD
カイト&ダートタイリングを生成します。

```mathematica
GeneratePenroseKD[range, offset]
```

**例:**
```mathematica
kdTiles = GeneratePenroseKD[{-5, -5, 10, 10}, {0, 0, 0, 0, 0}];
```

#### DrawPenroseKD
カイト&ダートタイリングを描画します。

```mathematica
DrawPenroseKD[tiles]
```

### 正方格子

#### GenerateSquareGrid
正方格子タイリングを生成します。

```mathematica
GenerateSquareGrid[cols, rows]
```

**例:**
```mathematica
squareTiles = GenerateSquareGrid[20, 15];
```

#### DrawSquareGrid
正方格子を描画します。

```mathematica
DrawSquareGrid[tiles]
```

### 一般化マルチグリッドタイリング（Ammann-Beenker等）

de Bruijnペンタグリッド法を任意の対称位数に一般化したマルチグリッド法です。奇数の対称位数nでは角度2πk/nに配置されたn本のグリッド族、偶数のnではn/2本のグリッド族を使用してロンブタイリングを生成します。

#### GenerateMultigridRhombs
指定した対称位数のロンブタイリングをde Bruijnマルチグリッド法で生成します。`offset`の要素数はグリッド族の本数（奇数nならn個、偶数nならn/2個）と一致させます。

```mathematica
GenerateMultigridRhombs[symOrder, range, offset]
```

**例:**
```mathematica
(* symOrder = 5 はペンローズ、7 は七角形、8 は Ammann-Beenker、12 は十二角形タイリング *)
heptaTiles = GenerateMultigridRhombs[7, {-5, -5, 10, 10}, ConstantArray[0, 7]];
abTiles = GenerateMultigridRhombs[8, {-5, -5, 10, 10}, ConstantArray[0, 4]];
dodecaTiles = GenerateMultigridRhombs[12, {-5, -5, 10, 10}, ConstantArray[0, 6]];
```

#### DrawMultigridTiling
マルチグリッドロンブタイリングを、ロンブの種類（角度クラス）ごとに自動配色して描画します。

```mathematica
DrawMultigridTiling[tiles]
```

**例:**
```mathematica
DrawMultigridTiling[abTiles]
```

#### GenerateABRhombs / DrawABTiling
Ammann-Beenkerタイリング専用のショートカット関数です。それぞれ `GenerateMultigridRhombs[8, range, offset]` および `DrawMultigridTiling[tiles]` と等価です。

```mathematica
GenerateABRhombs[range, offset]
DrawABTiling[tiles]
```

**例:**
```mathematica
abTiles = GenerateABRhombs[{-5, -5, 10, 10}, {0, 0, 0, 0}];
DrawABTiling[abTiles]
```

## 近傍グラフ構築

### BuildTilingGraph
タイリングから近傍グラフを構築します。

```mathematica
BuildTilingGraph[tiles]
```

**例:**
```mathematica
graph = BuildTilingGraph[tiles];
```

### BuildKDTilingGraph / BuildSquareGridGraph
カイト&ダートおよび正方格子用の近傍グラフを構築します。`BuildSquareGridGraph`は、オプションで格子の原点インデックス`x0, y0`（省略時は0, 0）を指定できます。

```mathematica
BuildKDTilingGraph[tiles]
BuildSquareGridGraph[tiles, cols, rows]
BuildSquareGridGraph[tiles, cols, rows, x0, y0]
```

**例:**
```mathematica
kdGraph = BuildKDTilingGraph[kdTiles];
squareGraph = BuildSquareGridGraph[squareTiles, 20, 15];

(* 原点をオフセットしたい場合 *)
offsetGraph = BuildSquareGridGraph[squareTiles, 20, 15, 5, 5];
```

### MooreNeighbors / NeumannNeighbors
ムーア近傍およびフォン・ノイマン近傍を取得します。

```mathematica
MooreNeighbors[graph, tileIndex]
NeumannNeighbors[graph, tileIndex]
```

**例:**
```mathematica
mooreNbrs = MooreNeighbors[graph, 1];
neumannNbrs = NeumannNeighbors[graph, 1];
```

### NeighborType / NeumannDirection
近傍タイプと方向を取得します。

```mathematica
NeighborType[graph, tileIndex]
NeumannDirection[graph, tileIndex, neighborIndex]
```

## セルオートマトンルール

### CreateCARule
一般セルオートマトンルールを作成します。

```mathematica
CreateCARule[ruleSpec]
```

**例:**
```mathematica
rule = CreateCARule[<|
  "transitionRules" -> {{0, 3, 0, 0, 0} -> 1, {1, _, _, _, _} -> 0},
  "rotational" -> False,
  "undefinedDefault" -> 0,
  "defaultValue" -> 0,
  "neighborhood" -> "Moore"
|>];
```

### CreatePCA5Rule
真の5近傍分割セルオートマトンルールを作成します。

```mathematica
CreatePCA5Rule[spec]
```

**例:**
```mathematica
pca5Rule = CreatePCA5Rule[<|
  "transitionRules" -> {{0,0,0,0,0} -> {1,0,1,0,1}},
  "rotational" -> True,
  "numStates" -> 2,
  "defaultValue" -> {0,0,0,0,0}
|>];
```

## シミュレーション実行

### CAStep / CAEvolve
1ステップ実行および複数ステップ進化を行います。

```mathematica
CAStep[graph, rule, state]
CAEvolve[graph, rule, initState, steps]
```

**例:**
```mathematica
initState = Table[0, Length[graph["tiles"]]];
initState[[1]] = 1;
newState = CAStep[graph, rule, initState];
evolution = CAEvolve[graph, rule, initState, 10];
```

### PCA5Step / PCA5Evolve
PCA5シミュレーションを実行します。

```mathematica
PCA5Step[graph, rule, state]
PCA5Evolve[graph, rule, initState, steps]
```

**例:**
```mathematica
pca5Init = Table[{0,0,0,0,0}, Length[graph["tiles"]]];
pca5Init[[1]] = {1,0,0,0,0};
pca5Evolution = PCA5Evolve[graph, pca5Rule, pca5Init, 5];
```

### IsReversiblePCA5 / InvertPCA5Rule
PCA5ルールが可逆（局所遷移関数が全単射）かどうかを判定し、可逆であれば入出力を総当たりで入れ替えて逆ルールを生成します。GCAルールおよび非可逆なPCA5ルールに対しては`IsReversiblePCA5`は`False`を返します。

```mathematica
IsReversiblePCA5[rule]
InvertPCA5Rule[rule]
```

**例:**
```mathematica
If[IsReversiblePCA5[pca5Rule],
  inverseRule = InvertPCA5Rule[pca5Rule];
  (* 逆ルールで逆方向に進化させると元の状態列に戻る *)
  backEvolution = PCA5Evolve[graph, inverseRule, pca5Evolution[[-1]], 5];
];
```

## 可視化

### DrawCAState
セルオートマトンの状態を描画します。

```mathematica
DrawCAState[graph, state, colorFunc]
```

**例:**
```mathematica
DrawCAState[graph, newState, ColorData["Rainbow"]]
```

### DrawPCA5State
PCA5状態を描画します。

```mathematica
DrawPCA5State[graph, state]
DrawPCA5State[graph, state, partIndex]
```

**例:**
```mathematica
DrawPCA5State[graph, pca5Evolution[[-1]]]; (* 中心部分 *)
DrawPCA5State[graph, pca5Evolution[[-1]], 2]; (* 北方向部分 *)
```

### DrawTilingWithNeighborTypes / DrawTilingNeighborhood
近傍タイプ別着色および近傍ハイライト表示を行います。

```mathematica
DrawTilingWithNeighborTypes[graph]
DrawTilingNeighborhood[graph, tileIndex]
```

## インタラクティブ機能

### PenroseTilingDemo
ペンローズタイリングのインタラクティブデモを起動します。

```mathematica
PenroseTilingDemo[]
```

### CASimulator
統合されたファイルベースのCAシミュレーターを起動します。ジオメトリ（Square / RPT / KD）、ルールタイプ（GCA / Partitioned / PCA5）、配色は、指定したルールファイルの内容から自動検出されます。従来のグラフ・ルールを直接渡すレガシーインターフェース（スカラーCA専用）も引き続き利用できます。

```mathematica
CASimulator[cafile]
CASimulator[cafile, conffile]
CASimulator[graph, rule]  (* レガシー: グラフベースのスカラーCA用インターフェース *)
```

**例:**
```mathematica
(* ルールファイル(.txt)のみ指定 — 初期状態は空 *)
CASimulator["MyRule.txt"];

(* ルールファイル + 設定ファイル(.caconf) から初期状態を読み込んで起動 *)
CASimulator["MyRule.txt", "MyConfig.caconf"];

(* レガシーインターフェース：既存のグラフ・ルールから起動 *)
CASimulator[graph, rule]
```

シミュレーター画面には以下の操作が用意されています。

- ステップ実行ボタン（+10 / +50 のバッチ実行を含む）とリセット
- グリッド表示の切り替え（Gridチェックボックス）
- "Open Rule" / "Open Conf" によるルール・設定ファイルの読み込み（ファイル選択ダイアログ）
- "Save Conf" による現在の状態の`.caconf`エクスポート
- ステップ数・タイル数の表示、ジオメトリ種別（GCA/PCA5）の表示
- PNG/PDF/MP4への画面エクスポート

### PCA5Simulator
真の5近傍分割セルオートマトン（PCA5）専用のインタラクティブシミュレーターを起動します。初期状態、配色、エクスポート先フォルダ名を段階的に指定できます。

```mathematica
PCA5Simulator[graph, rule]
PCA5Simulator[graph, rule, initState]
PCA5Simulator[graph, rule, initState, colorAssoc]
PCA5Simulator[graph, rule, initState, colorAssoc, configName]
```

**例:**
```mathematica
(* 空の初期状態で起動 *)
PCA5Simulator[graph, pca5Rule];

(* 読み込んだ初期状態で起動 *)
PCA5Simulator[graph, pca5Rule, pca5Init];

(* 配色を指定 *)
PCA5Simulator[graph, pca5Rule, pca5Init, <|0 -> White, 1 -> Red|>];

(* configName を指定すると、PNG/PDF/MP4エクスポート先が
   NotebookDirectory[]/configName_<suffix>/ になる *)
PCA5Simulator[graph, pca5Rule, pca5Init, <|0 -> White, 1 -> Red|>, "myConfig"];
```

### $CAHistorySize
CAシミュレーター（`CASimulator`）の履歴用リングバッファのサイズを指定するグローバル定数です。デフォルトは500。`CASimulator`を呼び出す前に値を変更することで、保持するステップ履歴の長さを調整できます。

```mathematica
$CAHistorySize = 1000;
CASimulator["MyRule.txt"];
```

## ファイル入出力

### LoadiOSRuleFile / LoadiOSConfigFile
iOSアプリのルールファイルと設定ファイルを読み込みます。

```mathematica
LoadiOSRuleFile[path]
LoadiOSConfigFile[path, graph]
```

`LoadiOSRuleFile`はShift-JISエンコーディングを自動的に処理し、`"rule"`（`CreateCARule`または`CreatePCA5Rule`の結果）と`"metadata"`（ジオメトリ・配色・ルール名など）をキーに持つAssociationを返します。`LoadiOSConfigFile`は指定した`graph`に対応する初期状態を返します。PCA5ルールの場合は`{c, d1, d2, d3, d4}`ベクトルのリスト、スカラーCAの場合は整数のリストになります。

**例:**
```mathematica
ruleData = LoadiOSRuleFile["rule.txt"];
rule = ruleData["rule"];
initState = LoadiOSConfigFile["config.caconf", graph];
```

### SaveiOSRuleFile / SaveiOSConfigFile
iOSアプリ形式でファイルを保存します。

```mathematica
SaveiOSRuleFile[path, rule, metadata]
SaveiOSConfigFile[path, graph, state]
```

### InferCellRangeFromConfig
`.caconf`設定ファイルを読み込み、デフォルト値でないタイルの重心を計算して、それを中心とするセル範囲を返します。幅・高さを省略すると、設定ファイルの内容に合わせた最小のバウンディング範囲を返します。

```mathematica
InferCellRangeFromConfig[configPath, {width, height}]
InferCellRangeFromConfig[configPath]
```

**例:**
```mathematica
cellRange = InferCellRangeFromConfig["MyConfig.caconf", {20, 20}];
tiles = GeneratePenroseRhombs[cellRange, {0, 0, 0, 0, 0}];

(* 幅・高さを省略した場合 *)
minimalRange = InferCellRangeFromConfig["MyConfig.caconf"];
```

### ExportPCA5Steps
PCA5を`nSteps`ステップ進化させながら、各フレームをクリップされたPNGとして連番でエクスポートします。ファイルは`directory`内に`000.png`, `001.png`, ...として保存されます。すべてのノイマン近傍4方向を持つ内部タイルのみが描画されます。

```mathematica
ExportPCA5Steps[graph, rule, state, nSteps, directory, colorAssoc]
```

**例:**
```mathematica
ExportPCA5Steps[graph, pca5Rule, pca5Init, 50,
  FileNameJoin[{$packageDirectory, "output_frames"}],
  <|0 -> White, 1 -> Red|>];
```

### ParseRuleFile
テキストルールファイルを解析します。

```mathematica
ParseRuleFile[xmlString]
```

## 使用例

基本的なワークフロー：

```mathematica
(* 1. タイリング生成 *)
tiles = GeneratePenroseRhombs[{-10, -10, 20, 20}, {0, 0, 0, 0, 0}];

(* 2. 近傍グラフ構築 *)
graph = BuildTilingGraph[tiles];

(* 3. ルール作成 *)
rule = CreateCARule[<|
  "transitionRules" -> {{0, 3, 0, 0, 0} -> 1, {1, _, _, _, _} -> 0},
  "rotational" -> False,
  "undefinedDefault" -> 0,
  "defaultValue" -> 0
|>];

(* 4. 初期状態設定 *)
initState = Table[0, Length[graph["tiles"]]];
initState[[1]] = 1;

(* 5. シミュレーション実行 *)
evolution = CAEvolve[graph, rule, initState, 20];

(* 6. 結果可視化 *)
DrawCAState[graph, evolution[[-1]], ColorData["Rainbow"]]
```

Ammann-Beenkerタイリングを使ったワークフロー：

```mathematica
(* 1. マルチグリッドタイリング生成 *)
abTiles = GenerateABRhombs[{-10, -10, 20, 20}, {0, 0, 0, 0}];
DrawABTiling[abTiles]

(* 2. 近傍グラフ構築（ロンブタイリング共通のBuildTilingGraphが利用可能） *)
abGraph = BuildTilingGraph[abTiles];
```

iOSルールファイルから統合シミュレーターを起動するワークフロー：

```mathematica
(* ルールファイルと設定ファイルを指定するだけで、
   ジオメトリ・ルールタイプ・配色が自動検出される *)
CASimulator["MyRule.txt", "MyConfig.caconf"];
```