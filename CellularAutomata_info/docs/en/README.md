# CellularAutomata

[日本語](../README.md) | **English**

A package for simulating cellular automata on Penrose tilings and square grids.

## Design Philosophy and Implementation Overview

The CellularAutomata package is designed to enable research on complex cellular automata over aperiodic tilings, balancing a sound geometric foundation with computational efficiency.

### Core Design Principles

**Unified graph abstraction**: A common neighborhood-graph structure is provided for different tilings (Penrose rhombs, kite & dart, square grids, and generalized multigrids), so the same CA rule engine runs on all of them. This makes it possible to compare CA behavior across tilings without worrying about geometric differences.

**Generalization of the de Bruijn method to multigrids**: Penrose tilings were originally generated with the mathematically rigorous de Bruijn pentagrid method; this has been extended to a multigrid method generalized to arbitrary symmetry orders. Using n grid families placed at angles 2πk/n for odd n, and n/2 grid families for even n, the same framework quickly generates not only Penrose (5) but also heptagonal (7), Ammann–Beenker (8), and dodecagonal (12) tilings.

**Multi-level neighborhood definitions**: Both Moore neighborhoods (vertex-sharing) and Neumann neighborhoods (edge-sharing) are supported. In addition, a neighborType classification specific to Penrose tilings (neighborType 0–10, 15) lets you design CA rules that take local geometric structure into account.

### Implementation Highlights

**True partitioned cellular automata (PCA5)**: In contrast to conventional single-state cells, an advanced CA form is implemented in which each cell has a center part and four directional parts `{c, d1, d2, d3, d4}`. This allows simulation of complex dynamics that involve particle flow and directionality.

**Automatic expansion of rotational symmetry**: Setting `rotational: True` on a partitioned CA rule automatically generates four rotationally symmetric rules from a single rule, enabling compact rule descriptions that exploit the symmetry of the tiling.

**Reversibility check and inverse-rule generation for PCA5**: `IsReversiblePCA5` determines whether the local transition function is bijective, and if it is reversible, `InvertPCA5Rule` automatically generates the inverse rule by exhaustively swapping inputs and outputs. This enables time-reversed simulation that exploits the properties of reversible CA.

**Unified file-based simulator**: Simply pass a rule file (.txt) to `CASimulator`, and it automatically detects the geometry (Square/RPT/KD), the rule type (GCA/Partitioned/PCA5), and the color scheme, then runs the simulation in a single UI. The legacy interface that takes a graph and a rule directly is still available.

**Compatibility with the iOS CA Simulator**: Rule files (.txt) created with the mobile app can be loaded, so existing research results and pattern libraries can be used directly.

With this design, researchers can concentrate on exploring emergent patterns and computation theory without being constrained by geometric limitations.

## Details

### Requirements

- **Wolfram Mathematica 12.0** or later (13.0 or later recommended)
- **OS**: Windows 11 (on macOS/Linux, adapt path separators and shell commands as needed)
- **Memory**: 8 GB or more recommended (for generating large tilings)

### Installation

Place the CellularAutomata.wl file directly in `$packageDirectory`.

**Setting `$Path`**:
```mathematica
(* If you use claudecode, $Path is configured automatically *)
(* For manual setup: *)
AppendTo[$Path, $packageDirectory];
```

**Loading the package**:
```mathematica
Block[{$CharacterEncoding = "UTF-8"},
  Needs["CellularAutomata`", "CellularAutomata.wl"]];
```

### Quick Start

```mathematica
(* 1. Generate a Penrose tiling *)
tiles = GeneratePenroseRhombs[{-5, -5, 10, 10}, {0, 0, 0, 0, 0}];
DrawPenroseTiling[tiles]

(* 2. Build the neighborhood graph *)
graph = BuildTilingGraph[tiles];

(* 3. Create a Game-of-Life-like CA rule *)
rule = CreateCARule[<|
  "transitionRules" -> {{0, 3} -> 1, {1, 2|3} -> 1, {_, _} -> 0},
  "rotational" -> False,
  "defaultValue" -> 0,
  "neighborhood" -> "Moore"
|>];

(* 4. Run the simulation *)
initState = RandomInteger[1, Length[tiles]];
evolution = CAEvolve[graph, rule, initState, 10];

(* 5. Visualize the result *)
DrawCAState[graph, Last[evolution]]

(* 6. Interactive simulator (legacy style: pass a graph and a rule directly) *)
CASimulator[graph, rule]

(* 7. Unified simulator from a rule file (recommended; geometry and rule type are detected automatically) *)
CASimulator[cafile]
```

### Main Features

**Tiling generation**:
- `GeneratePenroseRhombs` - rhombus tiling by the de Bruijn pentagrid method
- `GeneratePenroseKD` - kite & dart tiling
- `GenerateSquareGrid` - square-grid tiling (origin offset `x0, y0` can be specified)
- `GenerateMultigridRhombs` - de Bruijn multigrid tiling of arbitrary symmetry order (heptagonal, Ammann–Beenker, dodecagonal, etc.)
- `GenerateABRhombs` - shortcut dedicated to the Ammann–Beenker tiling
- `TileVertices` / `TileType` - get a tile's vertex coordinates and type

**Neighborhood graph construction**:
- `BuildTilingGraph` / `BuildKDTilingGraph` - Moore/Neumann neighborhoods and neighborType classification
- `BuildSquareGridGraph` - square-grid neighborhood graph (origin offset `x0, y0` can be specified)
- `MooreNeighbors` / `NeumannNeighbors` - get neighboring tiles
- `NeighborType` - local geometric structure classification (0–10, 15)
- `NeumannDirection` - get the direction index toward a neighboring tile

**Cellular automata**:
- `CreateCARule` - create general CA rules (GCA/Partitioned)
- `CreatePCA5Rule` - create true five-neighbor partitioned CA rules
- `CAStep` / `CAEvolve` - run GCA/Partitioned CA simulations
- `PCA5Step` / `PCA5Evolve` - run PCA5 simulations
- `IsReversiblePCA5` / `InvertPCA5Rule` - reversibility check and inverse-rule generation for PCA5 rules
- `CASimulator` - unified interactive environment that auto-detects settings from a rule file (also supports the legacy direct graph/rule interface)
- `$CAHistorySize` - size of the simulator's history ring buffer

**File I/O**:
- `LoadiOSRuleFile` - load rule files from the iOS CA Simulator
- `ParseRuleFile` - parse XML-format rules

**Visualization**:
- `DrawPenroseTiling` / `DrawPenroseKD` / `DrawSquareGrid` - draw tilings
- `DrawMultigridTiling` / `DrawABTiling` - draw multigrid tilings
- `DrawCAState` / `DrawPCA5State` - visualize CA states
- `DrawTilingWithNeighborTypes` - show the neighborType distribution
- `DrawTilingNeighborhood` - highlight a given tile and its neighbors

**Interactive features**:
- `PenroseTilingDemo` - interactive Penrose tiling demo with sliders for size and offset

### Documentation

- **[api.md](api.md)** - complete API reference
- **[example.md](examples/example.md)** - collection of practical usage examples
- **[setup.md](setup.md)** - detailed setup guide
- **[user_manual.md](user_manual.md)** - comprehensive user manual

## Usage Examples and Demos

**Basic Penrose CA**:
```mathematica
tiles = GeneratePenroseRhombs[{0, 0, 20, 15}, {0, 0.1, -0.1, 0.2, -0.2}];
graph = BuildTilingGraph[tiles];
rule = CreateCARule[<|"transitionRules" -> {{0, 3} -> 1, {1, 2} -> 1, {1, 3} -> 1}, 
  "rotational" -> False, "undefinedDefault" -> 0, "defaultValue" -> 0|>];
CASimulator[graph, rule]
```

**PCA5 particle-flow simulation**:
```mathematica
squareTiles = GenerateSquareGrid[15, 15];
squareGraph = BuildSquareGridGraph[squareTiles, 15, 15];
pca5Rule = CreatePCA5Rule[<|"transitionRules" -> {
  {0, 1, 0, 0, 0} -> {0, 0, 1, 0, 0}, {0, 0, 1, 0, 0} -> {0, 0, 0, 1, 0}}, 
  "rotational" -> False, "numStates" -> 2, "defaultValue" -> {0, 0, 0, 0, 0}|>];
PCA5Evolve[squareGraph, pca5Rule, Table[{0, 0, 0, 0, 0}, Length[squareTiles]], 10];
```

**Generating an Ammann–Beenker tiling**:
```mathematica
abTiles = GenerateABRhombs[{-5, -5, 10, 10}, {0, 0, 0, 0}];
DrawABTiling[abTiles]
```

**Interactive Penrose tiling demo**:
```mathematica
PenroseTilingDemo[]
```

For more sample code and explanations, see [example.md](examples/example.md).

Repository: https://github.com/transreal/CellularAutomata

---

## Disclaimer

This software is provided "as is", without warranty of any kind, express or implied.
The authors accept no liability for any damages arising from the use of, or inability to use, this software.
Updates to keep it working in the future are not guaranteed.
Nearly all of this software and its documentation were generated by generative AI.
It is intended to run on Windows 11; it has not been tested at all with Mathematica on macOS or Linux (adapting it with generative AI should be feasible).

---

## License

```
MIT License

Copyright (c) 2026 Takahiro Hatsuda and Katsunobu Imai

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
