# 使用例

このドキュメントでは、CellularAutomataパッケージの主要な機能を実際の使用例で紹介します。

## 1. ペンローズ菱形タイリングの生成と描画

基本的なペンローズタイリングを生成して可視化します。

```mathematica
tiles = GeneratePenroseRhombs[{0, 0, 800, 600}, {0, 0, 0, 0, 0}];
DrawPenroseTiling[tiles]
```

約400-600個のタイルからなるペンローズタイリングのGraphicsオブジェクトが生成されます。

## 2. 近傍グラフの構築と解析

タイリングから近傍関係を構築し、各タイルの近傍タイプを分類します。

```mathematica
graph = BuildTilingGraph[tiles];
neighborTypes = Table[NeighborType[graph, i], {i, Length[tiles]}];
Counts[neighborTypes]
```

各近傍タイプの出現回数が Association として返されます（例: <|0 -> 45, 1 -> 78, ...|>）。

## 3. セルラーオートマトンルールの作成と進化

Conwayのライフゲーム風のルールを作成して実行します。

```mathematica
rule = CreateCARule[<|"transitionRules" -> {{0, 3} -> 1, {1, 2} -> 1, {1, 3} -> 1}, 
  "rotational" -> False, "undefinedDefault" -> 0, "defaultValue" -> 0|>];
initState = RandomChoice[{0, 1}, Length[tiles]];
evolution = CAEvolve[graph, rule, initState, 10];
```

10ステップの進化結果がリストで返されます（各ステップは長さLengthの配列）。

## 4. カイト&ダートタイリングの生成

ペンローズタイリングをカイト・ダート形式で生成します。

```mathematica
kdTiles = GeneratePenroseKD[{0, 0, 600, 450}, {0, 0, 0, 0, 0}];
DrawPenroseKD[kdTiles]
```

カイト（青）とダート（赤）で色分けされたGraphicsオブジェクトが生成されます。

## 5. 正方格子での近傍グラフ構築

正方格子を生成し、ムーア近傍とノイマン近傍を構築します。

```mathematica
squareTiles = GenerateSquareGrid[10, 8];
squareGraph = BuildSquareGridGraph[squareTiles, 10, 8];
MooreNeighbors[squareGraph, 45]
```

タイル45のムーア近傍（8方向）のインデックスリストが返されます。

## 6. 真の5近傍分割セルラーオートマトン

各セルが中心と4つの方向成分を持つPCA5ルールを作成します。

```mathematica
pca5Rule = CreatePCA5Rule[<|"transitionRules" -> {
  {0, 0, 0, 0, 0} -> {1, 0, 0, 0, 0}, {1, 1, 1, 1, 1} -> {0, 0, 0, 0, 0}}, 
  "rotational" -> True, "numStates" -> 2, "defaultValue" -> {0, 0, 0, 0, 0}|>];
initState = Table[{RandomChoice[{0, 1}], 0, 0, 0, 0}, Length[squareTiles]];
```

各セルが{中心, 北, 東, 南, 西}の5成分を持つ初期状態が生成されます。

## 7. iOSアプリのルールファイル読み込み

iOS CA Simulatorアプリのルールファイルを読み込みます。

```mathematica
ruleData = LoadiOSRuleFile["example.txt"];
rule = ruleData["rule"];
metadata = ruleData["metadata"]
```

ルールオブジェクトと、几何学タイプ、色設定、名前などのメタデータが返されます。

## 8. インタラクティブシミュレーター

CAシミュレーターを起動して対話的に実行します。

```mathematica
CASimulator[graph, rule]
```

再生/一時停止ボタン、ステップ実行、初期状態リセット機能を持つDynamicModuleが表示されます。