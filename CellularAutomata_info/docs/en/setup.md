# CellularAutomata Setup Guide

[日本語](../setup.md) | **English**

## Requirements

- **Wolfram Mathematica 12.0** or later (13.0 or later recommended)
- **OS**: Windows 11 (on macOS/Linux, adapt path separators and shell commands as needed)
- **Memory**: 8 GB or more recommended (for generating large tilings)

## Required Tools

This package runs on the Wolfram Language alone; no external tools are required.

## Installation

### 1. Place the package file

Place the CellularAutomata.wl file directly in `$packageDirectory`:

```mathematica
(* Check the package directory *)
$packageDirectory

(* Usually a location like the following *)
(* C:\Users\<user name>\AppData\Roaming\Mathematica\Applications *)
```

### 2. Set `$Path`

**Option A: If you use claudecode**
```mathematica
(* $Path is configured automatically *)
```

**Option B: Manual setup**
```mathematica
(* Run at Mathematica startup *)
AppendTo[$Path, $packageDirectory];
```

### 3. Load the package

```mathematica
(* Load with UTF-8 encoding *)
Block[{$CharacterEncoding = "UTF-8"},
  Needs["CellularAutomata`", "CellularAutomata.wl"]
];
```

## Verifying the Installation

### Basic Penrose tiling generation

```mathematica
(* Generate a tiling over a small range *)
tiles = GeneratePenroseRhombs[{-5, -5, 10, 10}, {0, 0, 0, 0, 0}];

(* Check the number of tiles *)
Length[tiles]

(* Visualize *)
DrawPenroseTiling[tiles]
```

### Basic cellular automaton operation

```mathematica
(* Build the neighborhood graph *)
graph = BuildTilingGraph[tiles];

(* Create a simple CA rule *)
rule = CreateCARule[<|
  "transitionRules" -> {{0, 0, 0, 0, 0} -> 1, {1, _, _, _, _} -> 0},
  "rotational" -> False,
  "defaultValue" -> 0
|>];

(* Random initial state *)
initState = RandomInteger[1, Length[tiles]];

(* Run one step *)
newState = CAStep[graph, rule, initState];

(* Visualize the state *)
DrawCAState[graph, newState, ColorData["Rainbow"]]
```

### Verifying on a square grid

```mathematica
(* Generate a square grid *)
squareTiles = GenerateSquareGrid[10, 10];
squareGraph = BuildSquareGridGraph[squareTiles, 10, 10];

(* Conway's Game of Life rule *)
lifeRule = CreateCARule[<|
  "transitionRules" -> {
    {0, 3} -> 1,    (* birth *)
    {1, 2|3} -> 1,  (* survival *)
    {_, _} -> 0     (* death *)
  },
  "rotational" -> False,
  "defaultValue" -> 0,
  "neighborhood" -> "Moore"
|>];

(* Glider pattern *)
initSquareState = Table[0, Length[squareTiles]];
initSquareState[[{12, 23, 31, 32, 33}]] = 1; (* glider on a 5x5 grid *)

(* Evolve for 10 steps *)
evolution = CAEvolve[squareGraph, lifeRule, initSquareState, 10];

(* Show the final state *)
DrawCAState[squareGraph, Last[evolution], ColorData["RedBlueTones"]]
```

## Interactive Demos

### Penrose tiling demo

```mathematica
(* Interactive visualization *)
PenroseTilingDemo[]
```

### CA simulator

```mathematica
(* Launch the unified simulator from a rule file (.txt) (recommended) *)
(* Geometry (Square/RPT/KD), rule type (GCA/Partitioned/PCA5), and colors are detected automatically *)
CASimulator[cafile]

(* Also load an initial configuration file (.caconf) *)
CASimulator[cafile, conffile]

(* Legacy: pass a graph and a rule directly (scalar CA only) *)
CASimulator[graph, rule]
```

The size of the simulator's history (the ring buffer used for Undo) can be adjusted with `$CAHistorySize` (default 500). To change it, set it before calling `CASimulator`.

```mathematica
$CAHistorySize = 1000;
```

## Troubleshooting

### Package not found

```mathematica
(* Check that the package exists *)
FileExistsQ[FileNameJoin[{$packageDirectory, "CellularAutomata.wl"}]]

(* Check $Path *)
MemberQ[$Path, $packageDirectory]
```

### Out-of-memory errors

When generating large tilings, use a smaller range:

```mathematica
(* Recommended range size *)
tiles = GeneratePenroseRhombs[{-10, -10, 20, 20}, {0, 0, 0, 0, 0}]; (* good *)
(* tiles = GeneratePenroseRhombs[{-100, -100, 200, 200}, {0, 0, 0, 0, 0}]; (* heavy *) *)
```

### Garbled characters

```mathematica
(* Always load with UTF-8 *)
Block[{$CharacterEncoding = "UTF-8"},
  Get["CellularAutomata.wl"]
];
```

## Next Steps

Once setup is complete, try these advanced features:

- **Kite & dart tiling**: `GeneratePenroseKD[]`
- **Generalized de Bruijn multigrid tiling**: `GenerateMultigridRhombs[symOrder, range, offset]` (supports arbitrary symmetry orders such as Ammann–Beenker, heptagonal, and dodecagonal; `GenerateABRhombs[]`/`DrawABTiling[]` are Ammann–Beenker-specific wrappers)
- **True Partitioned CA (PCA5)**: `CreatePCA5Rule[]`
- **Reversibility check and inverse-rule generation for PCA5**: `IsReversiblePCA5[]` / `InvertPCA5Rule[]`
- **Unified file-based simulator**: `CASimulator[cafile]` (automatically detects geometry and rule type; experiments with complex multi-state rules such as SR8, and with worm and loop structures on de Bruijn geometry (RPT), can also be loaded through this interface)
- **Compatibility with the iOS simulator**: `LoadiOSRuleFile[]`

For details, see each function's help (`?FunctionName`) or the documentation on [GitHub](https://github.com/transreal/CellularAutomata).
