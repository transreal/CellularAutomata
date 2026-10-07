# CellularAutomata User Manual

[日本語](../user_manual.md) | **English**

## Overview

The CellularAutomata package provides cellular automaton simulation on Penrose rhombus tilings, generalized de Bruijn multigrid tilings (Ammann-Beenker, etc.), and square grids. It supports Penrose tiling generation by the de Bruijn pentagrid method, multigrid tiling generation for arbitrary symmetry order, neighborhood graph construction, and simulation of general cellular automata (GCA) and true partitioned cellular automata (PCA5).

## Tiling Generation

### Penrose Rhombus Tiling

#### GeneratePenroseRhombs
Generates a Penrose rhombus tiling.

```mathematica
GeneratePenroseRhombs[range, offset]
```

**Example:**
```mathematica
tiles = GeneratePenroseRhombs[{-5, -5, 10, 10}, {0, 0, 0, 0, 0}];
```

#### DrawPenroseTiling
Draws a tiling as graphics.

```mathematica
DrawPenroseTiling[tiles]
```

**Example:**
```mathematica
DrawPenroseTiling[tiles]
```

#### TileVertices / TileType
Gets the vertex coordinates and the type of a tile.

```mathematica
TileVertices[tile]
TileType[tile]
```

**Example:**
```mathematica
vertices = TileVertices[tiles[[1]]];
type = TileType[tiles[[1]]]; (* "Fat" or "Thin" *)
```

### Penrose Kite & Dart

#### GeneratePenroseKD
Generates a kite & dart tiling.

```mathematica
GeneratePenroseKD[range, offset]
```

**Example:**
```mathematica
kdTiles = GeneratePenroseKD[{-5, -5, 10, 10}, {0, 0, 0, 0, 0}];
```

#### DrawPenroseKD
Draws a kite & dart tiling.

```mathematica
DrawPenroseKD[tiles]
```

### Square Grid

#### GenerateSquareGrid
Generates a square grid tiling.

```mathematica
GenerateSquareGrid[cols, rows]
```

**Example:**
```mathematica
squareTiles = GenerateSquareGrid[20, 15];
```

#### DrawSquareGrid
Draws a square grid.

```mathematica
DrawSquareGrid[tiles]
```

### Generalized Multigrid Tilings (Ammann-Beenker, etc.)

A multigrid method that generalizes the de Bruijn pentagrid method to arbitrary symmetry order. For an odd symmetry order n, it uses n grid families placed at angles 2πk/n; for an even n, it uses n/2 grid families, and generates a rhombus tiling from them.

#### GenerateMultigridRhombs
Generates a rhombus tiling of the specified symmetry order using the de Bruijn multigrid method. The number of elements in `offset` must match the number of grid families (n for odd n, n/2 for even n).

```mathematica
GenerateMultigridRhombs[symOrder, range, offset]
```

**Example:**
```mathematica
(* symOrder = 5 is Penrose, 7 is heptagonal, 8 is Ammann-Beenker, 12 is dodecagonal tiling *)
heptaTiles = GenerateMultigridRhombs[7, {-5, -5, 10, 10}, ConstantArray[0, 7]];
abTiles = GenerateMultigridRhombs[8, {-5, -5, 10, 10}, ConstantArray[0, 4]];
dodecaTiles = GenerateMultigridRhombs[12, {-5, -5, 10, 10}, ConstantArray[0, 6]];
```

#### DrawMultigridTiling
Draws a multigrid rhombus tiling, automatically assigning colors by rhombus type (angle class).

```mathematica
DrawMultigridTiling[tiles]
```

**Example:**
```mathematica
DrawMultigridTiling[abTiles]
```

#### GenerateABRhombs / DrawABTiling
Shortcut functions dedicated to Ammann-Beenker tilings. They are equivalent to `GenerateMultigridRhombs[8, range, offset]` and `DrawMultigridTiling[tiles]`, respectively.

```mathematica
GenerateABRhombs[range, offset]
DrawABTiling[tiles]
```

**Example:**
```mathematica
abTiles = GenerateABRhombs[{-5, -5, 10, 10}, {0, 0, 0, 0}];
DrawABTiling[abTiles]
```

## Neighborhood Graph Construction

### BuildTilingGraph
Builds a neighborhood graph from a tiling.

```mathematica
BuildTilingGraph[tiles]
```

**Example:**
```mathematica
graph = BuildTilingGraph[tiles];
```

### BuildKDTilingGraph / BuildSquareGridGraph
Builds neighborhood graphs for kite & dart tilings and square grids. `BuildSquareGridGraph` optionally accepts the grid origin indices `x0, y0` (0, 0 when omitted).

```mathematica
BuildKDTilingGraph[tiles]
BuildSquareGridGraph[tiles, cols, rows]
BuildSquareGridGraph[tiles, cols, rows, x0, y0]
```

**Example:**
```mathematica
kdGraph = BuildKDTilingGraph[kdTiles];
squareGraph = BuildSquareGridGraph[squareTiles, 20, 15];

(* To offset the origin *)
offsetGraph = BuildSquareGridGraph[squareTiles, 20, 15, 5, 5];
```

### MooreNeighbors / NeumannNeighbors
Gets the Moore neighborhood and the von Neumann neighborhood.

```mathematica
MooreNeighbors[graph, tileIndex]
NeumannNeighbors[graph, tileIndex]
```

**Example:**
```mathematica
mooreNbrs = MooreNeighbors[graph, 1];
neumannNbrs = NeumannNeighbors[graph, 1];
```

### NeighborType / NeumannDirection
Gets the neighborType and the direction.

```mathematica
NeighborType[graph, tileIndex]
NeumannDirection[graph, tileIndex, neighborIndex]
```

## Cellular Automaton Rules

### CreateCARule
Creates a general cellular automaton rule.

```mathematica
CreateCARule[ruleSpec]
```

**Example:**
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
Creates a true five-neighbor partitioned cellular automaton rule.

```mathematica
CreatePCA5Rule[spec]
```

**Example:**
```mathematica
pca5Rule = CreatePCA5Rule[<|
  "transitionRules" -> {{0,0,0,0,0} -> {1,0,1,0,1}},
  "rotational" -> True,
  "numStates" -> 2,
  "defaultValue" -> {0,0,0,0,0}
|>];
```

## Running Simulations

### CAStep / CAEvolve
Performs a single step or a multi-step evolution.

```mathematica
CAStep[graph, rule, state]
CAEvolve[graph, rule, initState, steps]
```

**Example:**
```mathematica
initState = Table[0, Length[graph["tiles"]]];
initState[[1]] = 1;
newState = CAStep[graph, rule, initState];
evolution = CAEvolve[graph, rule, initState, 10];
```

### PCA5Step / PCA5Evolve
Runs a PCA5 simulation.

```mathematica
PCA5Step[graph, rule, state]
PCA5Evolve[graph, rule, initState, steps]
```

**Example:**
```mathematica
pca5Init = Table[{0,0,0,0,0}, Length[graph["tiles"]]];
pca5Init[[1]] = {1,0,0,0,0};
pca5Evolution = PCA5Evolve[graph, pca5Rule, pca5Init, 5];
```

### IsReversiblePCA5 / InvertPCA5Rule
Determines whether a PCA5 rule is reversible (i.e., its local transition function is bijective), and if it is, generates the inverse rule by exhaustively swapping inputs and outputs. For GCA rules and non-reversible PCA5 rules, `IsReversiblePCA5` returns `False`.

```mathematica
IsReversiblePCA5[rule]
InvertPCA5Rule[rule]
```

**Example:**
```mathematica
If[IsReversiblePCA5[pca5Rule],
  inverseRule = InvertPCA5Rule[pca5Rule];
  (* Evolving backward with the inverse rule returns to the original sequence of states *)
  backEvolution = PCA5Evolve[graph, inverseRule, pca5Evolution[[-1]], 5];
];
```

## Visualization

### DrawCAState
Draws a cellular automaton state.

```mathematica
DrawCAState[graph, state, colorFunc]
```

**Example:**
```mathematica
DrawCAState[graph, newState, ColorData["Rainbow"]]
```

### DrawPCA5State
Draws a PCA5 state.

```mathematica
DrawPCA5State[graph, state]
DrawPCA5State[graph, state, partIndex]
```

**Example:**
```mathematica
DrawPCA5State[graph, pca5Evolution[[-1]]]; (* center part *)
DrawPCA5State[graph, pca5Evolution[[-1]], 2]; (* north directional part *)
```

### DrawTilingWithNeighborTypes / DrawTilingNeighborhood
Colors tiles by neighborType and highlights a neighborhood.

```mathematica
DrawTilingWithNeighborTypes[graph]
DrawTilingNeighborhood[graph, tileIndex]
```

## Interactive Features

### PenroseTilingDemo
Launches an interactive demo of Penrose tilings.

```mathematica
PenroseTilingDemo[]
```

### CASimulator
Launches the unified, file-based CA simulator. The geometry (Square / RPT / KD), rule type (GCA / Partitioned / PCA5), and color scheme are detected automatically from the contents of the specified rule file. The legacy interface, which takes a graph and a rule directly (scalar CAs only), is still available.

```mathematica
CASimulator[cafile]
CASimulator[cafile, conffile]
CASimulator[graph, rule]  (* Legacy: graph-based interface for scalar CAs *)
```

**Example:**
```mathematica
(* Specify only a rule file (.txt) — the initial state is empty *)
CASimulator["MyRule.txt"];

(* Launch with the initial state loaded from a rule file + configuration file (.caconf) *)
CASimulator["MyRule.txt", "MyConfig.caconf"];

(* Legacy interface: launch from an existing graph and rule *)
CASimulator[graph, rule]
```

The simulator screen provides the following controls:

- Step buttons (including +10 / +50 batch runs) and reset
- Grid display toggle (Grid checkbox)
- Loading rule and configuration files with "Open Rule" / "Open Conf" (file selection dialog)
- Exporting the current state to `.caconf` with "Save Conf"
- Display of the step count, tile count, and geometry type (GCA/PCA5)
- Exporting the view to PNG/PDF/MP4

### PCA5Simulator
Launches an interactive simulator dedicated to true five-neighbor partitioned cellular automata (PCA5). The initial state, color scheme, and export folder name can be specified step by step.

```mathematica
PCA5Simulator[graph, rule]
PCA5Simulator[graph, rule, initState]
PCA5Simulator[graph, rule, initState, colorAssoc]
PCA5Simulator[graph, rule, initState, colorAssoc, configName]
```

**Example:**
```mathematica
(* Launch with an empty initial state *)
PCA5Simulator[graph, pca5Rule];

(* Launch with a loaded initial state *)
PCA5Simulator[graph, pca5Rule, pca5Init];

(* Specify the color scheme *)
PCA5Simulator[graph, pca5Rule, pca5Init, <|0 -> White, 1 -> Red|>];

(* When configName is specified, the PNG/PDF/MP4 export destination
   becomes NotebookDirectory[]/configName_<suffix>/ *)
PCA5Simulator[graph, pca5Rule, pca5Init, <|0 -> White, 1 -> Red|>, "myConfig"];
```

### $CAHistorySize
A global constant that specifies the size of the history ring buffer of the CA simulator (`CASimulator`). The default is 500. By changing the value before calling `CASimulator`, you can adjust how many steps of history are kept.

```mathematica
$CAHistorySize = 1000;
CASimulator["MyRule.txt"];
```

## File I/O

### LoadiOSRuleFile / LoadiOSConfigFile
Loads rule files and configuration files of the iOS app.

```mathematica
LoadiOSRuleFile[path]
LoadiOSConfigFile[path, graph]
```

`LoadiOSRuleFile` handles Shift-JIS encoding automatically and returns an Association with the keys `"rule"` (the result of `CreateCARule` or `CreatePCA5Rule`) and `"metadata"` (geometry, color scheme, rule name, etc.). `LoadiOSConfigFile` returns the initial state corresponding to the given `graph`: a list of `{c, d1, d2, d3, d4}` vectors for PCA5 rules, or a list of integers for scalar CAs.

**Example:**
```mathematica
ruleData = LoadiOSRuleFile["rule.txt"];
rule = ruleData["rule"];
initState = LoadiOSConfigFile["config.caconf", graph];
```

### SaveiOSRuleFile / SaveiOSConfigFile
Saves files in the iOS app format.

```mathematica
SaveiOSRuleFile[path, rule, metadata]
SaveiOSConfigFile[path, graph, state]
```

### InferCellRangeFromConfig
Reads a `.caconf` configuration file, computes the centroid of the tiles whose values are not the default, and returns a cell range centered on it. If the width and height are omitted, it returns the smallest bounding range that fits the contents of the configuration file.

```mathematica
InferCellRangeFromConfig[configPath, {width, height}]
InferCellRangeFromConfig[configPath]
```

**Example:**
```mathematica
cellRange = InferCellRangeFromConfig["MyConfig.caconf", {20, 20}];
tiles = GeneratePenroseRhombs[cellRange, {0, 0, 0, 0, 0}];

(* When the width and height are omitted *)
minimalRange = InferCellRangeFromConfig["MyConfig.caconf"];
```

### ExportPCA5Steps
Evolves a PCA5 for `nSteps` steps while exporting each frame as a clipped PNG with sequential numbering. The files are saved in `directory` as `000.png`, `001.png`, .... Only interior tiles that have all four Neumann-neighborhood directions are drawn.

```mathematica
ExportPCA5Steps[graph, rule, state, nSteps, directory, colorAssoc]
```

**Example:**
```mathematica
ExportPCA5Steps[graph, pca5Rule, pca5Init, 50,
  FileNameJoin[{$packageDirectory, "output_frames"}],
  <|0 -> White, 1 -> Red|>];
```

### ParseRuleFile
Parses a text rule file.

```mathematica
ParseRuleFile[xmlString]
```

## Usage Examples

Basic workflow:

```mathematica
(* 1. Generate a tiling *)
tiles = GeneratePenroseRhombs[{-10, -10, 20, 20}, {0, 0, 0, 0, 0}];

(* 2. Build the neighborhood graph *)
graph = BuildTilingGraph[tiles];

(* 3. Create a rule *)
rule = CreateCARule[<|
  "transitionRules" -> {{0, 3, 0, 0, 0} -> 1, {1, _, _, _, _} -> 0},
  "rotational" -> False,
  "undefinedDefault" -> 0,
  "defaultValue" -> 0
|>];

(* 4. Set the initial state *)
initState = Table[0, Length[graph["tiles"]]];
initState[[1]] = 1;

(* 5. Run the simulation *)
evolution = CAEvolve[graph, rule, initState, 20];

(* 6. Visualize the result *)
DrawCAState[graph, evolution[[-1]], ColorData["Rainbow"]]
```

Workflow using an Ammann-Beenker tiling:

```mathematica
(* 1. Generate a multigrid tiling *)
abTiles = GenerateABRhombs[{-10, -10, 20, 20}, {0, 0, 0, 0}];
DrawABTiling[abTiles]

(* 2. Build the neighborhood graph (BuildTilingGraph, shared by all rhombus tilings, can be used) *)
abGraph = BuildTilingGraph[abTiles];
```

Workflow for launching the unified simulator from an iOS rule file:

```mathematica
(* Just by specifying a rule file and a configuration file,
   the geometry, rule type, and color scheme are detected automatically *)
CASimulator["MyRule.txt", "MyConfig.caconf"];
```

### SR8 Ribbon Worm / Loop Experiments (Loading Pre-designed Rules with CASimulator)

Because `CASimulator` automatically detects the geometry, rule type, and color scheme from just a rule file (.txt) and a configuration file (.caconf), pre-designed research rule sets can be loaded and replayed as-is. The package includes example experiments with "SR8"-family scalar CA rules that run along the de Bruijn ribbon structure on RPT (the Penrose rhombus tiling).

**Rule files:**

| File | Contents |
|---|---|
| `sr8RPT-ribbonworms.txt` | Worms of at least 3 cells that travel straight along de Bruijn ribbons. Depending on the signal pair read at the head, they behave as follows: (A,A) = go straight, (B,B) = two-way branch, (B,A) = three-way branch. |
| `sr8RPT-ribbonworms-large.txt` | A version that extends the above worm/branch/loop structures to larger boards and longer bodies (e.g., an 8-cell version). |
| `sr8RPTx.txt` | SR8 auto-completed only for the inputs actually reached. Its defined behavior is the same as SR8, but it is extended so that the former crashes on undefined inputs solidify into compact static debris instead of leading to annihilation. It closes the local map while keeping it reversible-extendable. |
| `sr8RPTd.txt` | A designed extension to 9 states that adds state 8 (trace marker) and state 3 (photon). It implements splice-and-cut docking (when a wire cell touches the head, the upstream bond is cut and the replacing cell becomes the new head). The same rule can also convert worms into loops. Markers pass through or are deflected by wires, and fly freely through empty-cell regions. |

**Configuration files (initial configurations):** `sr8RPT-ribbonworm-straight.caconf` (straight worm), `sr8RPT-ribbonworm-branch2.caconf` / `sr8RPT-ribbonworm-branch2-L8.caconf` (two-way branch; self-replicates in a comb-like pattern), `sr8RPT-ribbonworm-branch3.caconf` / `sr8RPT-ribbonworm-branch3-L8.caconf` (three-way branch; an exponentially growing tree structure that eventually self-collides), `sr8RPT-loop-deg4-DB.caconf` (loop on a degree-4 vertex, "AA gene").

**Example:**
```mathematica
(* Replay straight and branching worms on RPT *)
CASimulator["sr8RPT-ribbonworms.txt", "sr8RPT-ribbonworm-straight.caconf"];
CASimulator["sr8RPT-ribbonworms.txt", "sr8RPT-ribbonworm-branch2.caconf"];
CASimulator["sr8RPT-ribbonworms.txt", "sr8RPT-ribbonworm-branch3.caconf"];

(* Replay branching worms on larger boards with 8-cell bodies using the extended rule *)
CASimulator["sr8RPT-ribbonworms-large.txt", "sr8RPT-ribbonworm-branch2-L8.caconf"];
CASimulator["sr8RPT-ribbonworms-large.txt", "sr8RPT-ribbonworm-branch3-L8.caconf"];
CASimulator["sr8RPT-ribbonworms-large.txt", "sr8RPT-loop-deg4-DB.caconf"];

(* Replay loops with the auto-completed version (sr8RPTx) and the designed 9-state version (sr8RPTd) *)
CASimulator["sr8RPTx.txt", "sr8RPT-loop-deg4-DB.caconf"];
CASimulator["sr8RPTx.txt", "sr8RPT-ribbonworm-branch3.caconf"];
CASimulator["sr8RPTd.txt", "sr8RPT-loop-deg4-DB.caconf"];
```

Typical behaviors observed in these examples: on the square grid the branch2 structure self-replicates, whereas on RPT the exponentially branching branch3 series eventually self-collides (the second generation of branch3 collides at about 26 steps; the 8-cell branch3-L8 grows without collision for about 234 steps, i.e., 4 generations; the 8-cell branch2-L8 keeps growing without collision for more than 800 steps). On RPTd, the loop on a degree-4 vertex absorbs returning wanderers (wandering substructures) and emits small worms while the parent structure stays intact. The rule table reaches 765+4804=5569 rules on the RPT side, and its injectivity (reversibility) has been verified mechanically. Use `sr8RPTx_generator.wl` to regenerate or extend the rule sets.
