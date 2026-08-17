# CellularAutomata セットアップガイド

## 動作環境

- **Wolfram Mathematica 12.0** 以上（推奨: 13.0以上）
- **OS**: Windows 11（macOS/Linux ではパス区切りやシェルコマンドを適宜読み替えてください）
- **メモリ**: 8GB 以上推奨（大規模タイリング生成時）

## 必要なツール

このパッケージは Wolfram Language のみで動作し、外部ツールは不要です。

## インストール

### 1. パッケージファイルの配置

CellularAutomata.wl ファイルを `$packageDirectory` に直接配置してください：

```mathematica
(* パッケージディレクトリの確認 *)
$packageDirectory

(* 通常は以下のような場所 *)
(* C:\Users\ユーザー名\AppData\Roaming\Mathematica\Applications *)
```

### 2. $Path の設定

**Option A: claudecode を使用している場合**
```mathematica
(* $Path は自動的に設定されます *)
```

**Option B: 手動設定の場合**
```mathematica
(* Mathematica起動時に実行 *)
AppendTo[$Path, $packageDirectory];
```

### 3. パッケージの読み込み

```mathematica
(* UTF-8エンコーディングで読み込み *)
Block[{$CharacterEncoding = "UTF-8"},
  Needs["CellularAutomata`", "CellularAutomata.wl"]
];
```

## 動作確認

### 基本的なペンローズタイリング生成

```mathematica
(* 小さな範囲でタイリングを生成 *)
tiles = GeneratePenroseRhombs[{-5, -5, 10, 10}, {0, 0, 0, 0, 0}];

(* タイル数の確認 *)
Length[tiles]

(* 可視化 *)
DrawPenroseTiling[tiles]
```

### セルオートマトンの基本動作

```mathematica
(* 近傍グラフの構築 *)
graph = BuildTilingGraph[tiles];

(* シンプルなCAルールを作成 *)
rule = CreateCARule[<|
  "transitionRules" -> {{0, 0, 0, 0, 0} -> 1, {1, _, _, _, _} -> 0},
  "rotational" -> False,
  "defaultValue" -> 0
|>];

(* ランダムな初期状態 *)
initState = RandomInteger[1, Length[tiles]];

(* 1ステップ実行 *)
newState = CAStep[graph, rule, initState];

(* 状態の可視化 *)
DrawCAState[graph, newState, ColorData["Rainbow"]]
```

### 正方格子での動作確認

```mathematica
(* 正方格子の生成 *)
squareTiles = GenerateSquareGrid[10, 10];
squareGraph = BuildSquareGridGraph[squareTiles, 10, 10];

(* Conway's Game of Lifeルール *)
lifeRule = CreateCARule[<|
  "transitionRules" -> {
    {0, 3} -> 1,    (* 誕生 *)
    {1, 2|3} -> 1,  (* 生存 *)
    {_, _} -> 0     (* 死亡 *)
  },
  "rotational" -> False,
  "defaultValue" -> 0,
  "neighborhood" -> "Moore"
|>];

(* グライダーパターン *)
initSquareState = Table[0, Length[squareTiles]];
initSquareState[[{12, 23, 31, 32, 33}]] = 1; (* 5x5グリッドでのグライダー *)

(* 10ステップ進化 *)
evolution = CAEvolve[squareGraph, lifeRule, initSquareState, 10];

(* 最終状態の表示 *)
DrawCAState[squareGraph, Last[evolution], ColorData["RedBlueTones"]]
```

## インタラクティブデモ

### ペンローズタイリングデモ

```mathematica
(* インタラクティブな可視化 *)
PenroseTilingDemo[]
```

### CAシミュレーター

```mathematica
(* ルールファイル（.txt）から統一シミュレーターを起動（推奨） *)
(* ジオメトリ（Square/RPT/KD）、ルール種別（GCA/Partitioned/PCA5）、色は自動判定される *)
CASimulator[cafile]

(* 初期配置ファイル（.caconf）も併せて読み込む場合 *)
CASimulator[cafile, conffile]

(* レガシー: グラフとルールを直接渡す方式（スカラーCA限定） *)
CASimulator[graph, rule]
```

シミュレーターの履歴（Undo用リングバッファ）のサイズは `$CAHistorySize`（デフォルト500）で調整できます。変更する場合は `CASimulator` を呼び出す前に設定してください。

```mathematica
$CAHistorySize = 1000;
```

## よくある問題

### パッケージが見つからない場合

```mathematica
(* パッケージの存在確認 *)
FileExistsQ[FileNameJoin[{$packageDirectory, "CellularAutomata.wl"}]]

(* $Path の確認 *)
MemberQ[$Path, $packageDirectory]
```

### メモリ不足エラー

大規模なタイリングを生成する際は、範囲を小さくしてください：

```mathematica
(* 推奨範囲サイズ *)
tiles = GeneratePenroseRhombs[{-10, -10, 20, 20}, {0, 0, 0, 0, 0}]; (* 良い *)
(* tiles = GeneratePenroseRhombs[{-100, -100, 200, 200}, {0, 0, 0, 0, 0}]; (* 重い *) *)
```

### 文字化け

```mathematica
(* 必ずUTF-8で読み込んでください *)
Block[{$CharacterEncoding = "UTF-8"},
  Get["CellularAutomata.wl"]
];
```

## 次のステップ

セットアップが完了したら、以下の高度な機能もお試しください：

- **Kite & Dart タイリング**: `GeneratePenroseKD[]`
- **一般化 de Bruijn 多重格子タイリング**: `GenerateMultigridRhombs[symOrder, range, offset]`（Ammann–Beenker・七角形・十二角形など任意の対称次数に対応。`GenerateABRhombs[]`/`DrawABTiling[]` はAmmann–Beenker専用のラッパー）
- **True Partitioned CA (PCA5)**: `CreatePCA5Rule[]`
- **PCA5 の可逆性判定と逆ルール生成**: `IsReversiblePCA5[]` / `InvertPCA5Rule[]`
- **統一ファイルベースシミュレーター**: `CASimulator[cafile]`（ジオメトリとルール種別を自動判定）
- **iOS シミュレーターとの互換**: `LoadiOSRuleFile[]`

詳細は各関数のヘルプ（`?関数名`）または [GitHub](https://github.com/transreal/CellularAutomata) のドキュメントをご参照ください。