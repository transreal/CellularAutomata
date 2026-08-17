# CellularAutomata

ペンローズタイリングと正方格子上でのセルラーオートマトンシミュレーションパッケージです。

## 設計思想と実装の概要

CellularAutomataパッケージは、非周期タイリング上での複雑なセルラーオートマトン研究を可能にするため、幾何学的基盤と計算効率を両立させた設計思想で開発されています。

### 核心的設計理念

**統一的なグラフ抽象化**: 異なるタイリング（ペンローズ菱形・カイト&ダート・正方格子・一般化マルチグリッド）に対して共通の近傍グラフ構造を提供し、同一のCA規則エンジンで動作させることができます。これにより、幾何学の違いを意識することなく、様々なタイリング間でのCA挙動比較が可能になります。

**de Bruijnマルチグリッド法への一般化**: ペンローズタイリングの生成には、数学的に厳密なde Bruijn五角格子法を採用していましたが、これを任意の対称位数に一般化したマルチグリッド法へと拡張しました。奇数の対称位数nでは角度2πk/nに配置されたn本のグリッド族、偶数のnではn/2本のグリッド族を用いることで、ペンローズ（5）だけでなく七角形（7）、Ammann–Beenker（8）、十二角形（12）タイリングなども同一の枠組みで高速生成できます。

**多層的な近傍定義**: Moore近傍（頂点共有）とNeumann近傍（辺共有）の両方をサポートし、さらにペンローズタイリング特有の近傍タイプ分類（neighborType 0-10, 15）により、局所的な幾何学構造を考慮したCA規則設計が可能です。

### 実装の革新性

**真の分割セルラーオートマトン（PCA5）**: 従来の単一状態セルに対し、各セルが中心部分と4つの方向成分`{c, d1, d2, d3, d4}`を持つ高度なCA形式を実装しています。これにより、粒子の流れや方向性を考慮した複雑な動力学をシミュレートできます。

**回転対称性の自動展開**: 分割CA規則に`rotational: True`を設定することで、単一の規則から4つの回転対称規則が自動生成され、タイリングの対称性を活用した効率的な規則記述が可能です。

**PCA5の可逆性判定と逆ルール生成**: `IsReversiblePCA5`により局所遷移関数が全単射かどうかを判定し、可逆であれば`InvertPCA5Rule`で入出力を総当たりで入れ替えた逆ルールを自動生成できます。これにより、可逆CAの性質を利用した時間反転シミュレーションが可能になります。

**統一ファイルベースシミュレーター**: `CASimulator`にルールファイル（.txt）を渡すだけで、ジオメトリ（Square/RPT/KD）・ルール種別（GCA/Partitioned/PCA5）・配色を自動判定し、単一のUIでシミュレーションを実行できます。グラフとルールを直接渡すレガシーインターフェースも引き続き利用可能です。

**iOS CA Simulatorとの互換性**: モバイルアプリで作成された規則ファイル（.txt）の読み込み機能により、既存の研究成果やパターンライブラリを直接活用できます。

この設計により、研究者は幾何学的制約に縛られることなく、創発的パターンや計算理論の探索に集中できる環境を提供しています。

## 詳細説明

### 動作環境

- **Wolfram Mathematica 12.0** 以上（推奨: 13.0以上）
- **OS**: Windows 11（macOS/Linux ではパス区切りやシェルコマンドを適宜読み替えてください）
- **メモリ**: 8GB 以上推奨（大規模タイリング生成時）

### インストール

CellularAutomata.wl ファイルを `$packageDirectory` に直接配置してください。

**$Path の設定**:
```mathematica
(* claudecode を使用している場合、$Path は自動設定されます *)
(* 手動設定の場合: *)
AppendTo[$Path, $packageDirectory];
```

**パッケージの読み込み**:
```mathematica
Block[{$CharacterEncoding = "UTF-8"},
  Needs["CellularAutomata`", "CellularAutomata.wl"]];
```

### クイックスタート

```mathematica
(* 1. ペンローズタイリングの生成 *)
tiles = GeneratePenroseRhombs[{-5, -5, 10, 10}, {0, 0, 0, 0, 0}];
DrawPenroseTiling[tiles]

(* 2. 近傍グラフの構築 *)
graph = BuildTilingGraph[tiles];

(* 3. ライフゲーム風のCA規則を作成 *)
rule = CreateCARule[<|
  "transitionRules" -> {{0, 3} -> 1, {1, 2|3} -> 1, {_, _} -> 0},
  "rotational" -> False,
  "defaultValue" -> 0,
  "neighborhood" -> "Moore"
|>];

(* 4. シミュレーションの実行 *)
initState = RandomInteger[1, Length[tiles]];
evolution = CAEvolve[graph, rule, initState, 10];

(* 5. 結果の可視化 *)
DrawCAState[graph, Last[evolution]]

(* 6. インタラクティブシミュレーター（グラフ/ルールを直接渡すレガシー方式） *)
CASimulator[graph, rule]

(* 7. ルールファイルからの統一シミュレーター（推奨、ジオメトリ/ルール種別を自動判定） *)
CASimulator[cafile]
```

### 主な機能

**タイリング生成**:
- `GeneratePenroseRhombs` - de Bruijn五角格子法による菱形タイリング
- `GeneratePenroseKD` - カイト&ダートタイリング
- `GenerateSquareGrid` - 正方格子タイリング（原点オフセット`x0, y0`指定可）
- `GenerateMultigridRhombs` - 任意対称位数のde Bruijnマルチグリッドタイリング（七角形・Ammann–Beenker・十二角形など）
- `GenerateABRhombs` - Ammann–Beenkerタイリング専用ショートカット

**近傍グラフ構築**:
- `BuildTilingGraph` / `BuildKDTilingGraph` - Moore/Neumann近傍とneighborType分類
- `BuildSquareGridGraph` - 正方格子近傍グラフ（原点オフセット`x0, y0`指定可）
- `MooreNeighbors` / `NeumannNeighbors` - 近傍タイル取得
- `NeighborType` - 局所幾何学構造分類（0-10, 15）
- `NeumannDirection` - 近傍タイルへの方向インデックス取得

**セルラーオートマトン**:
- `CreateCARule` - 一般CA規則（GCA）作成
- `CreatePCA5Rule` - 真の5近傍分割CA規則作成
- `CAStep` / `CAEvolve` - GCA/PartitionedCAのシミュレーション実行
- `PCA5Step` / `PCA5Evolve` - PCA5専用のシミュレーション実行
- `IsReversiblePCA5` / `InvertPCA5Rule` - PCA5規則の可逆性判定と逆規則生成
- `CASimulator` - ルールファイルから自動判定する統一インタラクティブ環境（レガシーのグラフ/ルール直接指定にも対応）
- `$CAHistorySize` - シミュレーター履歴リングバッファのサイズ設定

**ファイル入出力**:
- `LoadiOSRuleFile` - iOS CA Simulatorの規則ファイル読み込み
- `ParseRuleFile` - XML形式規則解析

**可視化**:
- `DrawPenroseTiling` / `DrawPenroseKD` / `DrawSquareGrid` - タイリング描画
- `DrawMultigridTiling` / `DrawABTiling` - マルチグリッドタイリング描画
- `DrawCAState` / `DrawPCA5State` - CA状態の可視化
- `DrawTilingWithNeighborTypes` - neighborType分布表示
- `DrawTilingNeighborhood` - 指定タイルとその近傍のハイライト表示

### ドキュメント一覧

- **api.md** - 完全API リファレンス
- **example.md** - 実用的な使用例集
- **setup.md** - 詳細セットアップガイド  
- **user_manual.md** - 包括的ユーザーマニュアル

## 使用例・デモ

**基本的なペンローズCA**:
```mathematica
tiles = GeneratePenroseRhombs[{0, 0, 20, 15}, {0, 0.1, -0.1, 0.2, -0.2}];
graph = BuildTilingGraph[tiles];
rule = CreateCARule[<|"transitionRules" -> {{0, 3} -> 1, {1, 2} -> 1, {1, 3} -> 1}, 
  "rotational" -> False, "undefinedDefault" -> 0, "defaultValue" -> 0|>];
CASimulator[graph, rule]
```

**PCA5粒子流シミュレーション**:
```mathematica
squareTiles = GenerateSquareGrid[15, 15];
squareGraph = BuildSquareGridGraph[squareTiles, 15, 15];
pca5Rule = CreatePCA5Rule[<|"transitionRules" -> {
  {0, 1, 0, 0, 0} -> {0, 0, 1, 0, 0}, {0, 0, 1, 0, 0} -> {0, 0, 0, 1, 0}}, 
  "rotational" -> False, "numStates" -> 2, "defaultValue" -> {0, 0, 0, 0, 0}|>];
PCA5Evolve[squareGraph, pca5Rule, Table[{0, 0, 0, 0, 0}, Length[squareTiles]], 10];
```

**Ammann–Beenkerタイリング生成**:
```mathematica
abTiles = GenerateABRhombs[{-5, -5, 10, 10}, {0, 0, 0, 0}];
DrawABTiling[abTiles]
```

**ペンローズタイリングインタラクティブデモ**:
```mathematica
PenroseTilingDemo[]
```

詳細なサンプルコードと解説は [example.md](example.md) をご参照ください。

リポジトリ: https://github.com/transreal/CellularAutomata

---

## 免責事項

本ソフトウェアは "as is"（現状有姿）で提供されており、明示・黙示を問わずいかなる保証もありません。
本ソフトウェアの使用または使用不能から生じるいかなる損害についても責任を負いません。
今後の動作保証のための更新が行われるとは限りません。
本ソフトウェアとドキュメントはほぼすべてが生成AIによって生成されたものです。
Windows 11上での実行を想定しており、MacOS, LinuxのMathematicaでの動作検証は一切していません(生成AIの処理で対応可能と想定されます)。

---

## ライセンス

```
MIT License

Copyright (c) 2026 Katsunobu Imai

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
