[日本語](../api.md) | **English**

## Tile Generation

### GeneratePenroseRhombs[range, offset] → List
Generates Penrose rhombus tiles using the de Bruijn pentagrid method.
`range = {xmin, ymin, width, height}`, `offset = {g0, g1, g2, g3, g4}`
Each tile is an Association of the form `<|"label"->, "type"->"Fat"|"Thin", "vertices"->List(4 points), "vertexKeys"->List(4 five-dimensional integer keys)|>`.

### GeneratePenroseKD[range, offset] → List
Generates kite & dart tiles by subdividing the rhombi. Each tile has the keys `"label"`, `"type"->"Kite"|"Dart"`, `"vertices"`, and `"vertexKeys"`. The formats of `range` and `offset` are the same as for `GeneratePenroseRhombs`.

### GenerateSquareGrid[cols, rows] → List
### GenerateSquareGrid[cols, rows, x0, y0] → List
Generates square grid tiles. If `x0, y0` are omitted, generation starts from `{0, 0}` (specifying an offset shifts the origin of the grid). Each tile has `"label"->{c,r}`, `"type"->"Square"`, `"vertices"`, and `"vertexKeys"`. Supports the same graph structure as `BuildTilingGraph`.

### GenerateMultigridRhombs[symOrder, range, offset] → List
Generates a rhombus tiling with `symOrder`-fold symmetry using the de Bruijn multigrid method. An odd `n` uses `n` grid families at angles `2πk/n`; an even `n` uses `n/2` grid families. `offset` is required and must be a list with as many elements as there are grid families (`numGrids`); there is no default value. Examples: 5=Penrose, 7=heptagonal, 8=Ammann–Beenker, 12=dodecagonal. The return value uses the same tile format as `GeneratePenroseRhombs`.

### GenerateABRhombs[range, offset] → List
Generates Ammann–Beenker rhombus tiles. `offset` has 4 elements. Equivalent to `GenerateMultigridRhombs[8, range, offset]`.

### TileVertices[tile] → List
Returns the list of the tile's 4 vertex coordinates.

### TileType[tile] → String
Returns `"Fat"` or `"Thin"`. For KD tiles, returns `"Kite"` or `"Dart"`.

## Tile Drawing

### DrawPenroseTiling[tiles, opts] → Graphics
Draws a Penrose rhombus tiling, with Fat tiles colored ochre and Thin tiles colored blue.

### DrawPenroseKD[tiles, opts] → Graphics
Draws a kite & dart tiling, color-coded by tile type.

### DrawSquareGrid[tiles, opts] → Graphics
Draws a square grid filled with white.

### DrawMultigridTiling[tiles, opts] → Graphics
Draws a multigrid rhombus tiling, with colors assigned automatically per rhombus type.

### DrawABTiling[tiles, opts] → Graphics
Draws an Ammann–Beenker tiling. Equivalent to `DrawMultigridTiling[tiles, opts]`.

### PenroseTilingDemo[] → DynamicModule
Displays an interactive Penrose tiling demo. The size and offset can be adjusted with sliders.

## Neighborhood Graph Construction

### BuildTilingGraph[tiles] → Association
Builds vertex-sharing and edge-sharing neighborhood data for all tiles.
Keys of the return value:
- `"tiles"` — the input tile list
- `"vertexToTiles"` — vertex key → list of tile indices
- `"mooreNeighbors"` — tile index → list of Moore neighbor indices
- `"neumannNeighbors"` — tile index → list of Neumann neighbor indices
- `"neumannDirections"` — tile index → Association (neighbor index → direction value)
- `"neighborTypes"` — tile index → neighborType (0-10, 15)

### BuildKDTilingGraph[tiles] → Association
Builds the neighborhood graph of a kite & dart tiling. Same structure as `BuildTilingGraph`.

### BuildSquareGridGraph[tiles, cols, rows] → Association
### BuildSquareGridGraph[tiles, cols, rows, x0, y0] → Association
Builds the neighborhood graph of a square grid. `x0, y0` must match the offset passed to `GenerateSquareGrid` (`{0, 0}` when omitted). Moore = 8 neighbors, Neumann = 4 neighbors (NSEW). Direction values: E=0, S=2, W=4, N=6.

## Neighborhood Accessors

### MooreNeighbors[graph, tileIndex] → List
Returns the list of Moore neighbor (vertex-sharing) indices of the specified tile.

### NeumannNeighbors[graph, tileIndex] → List
Returns the list of Neumann neighbor (edge-sharing) indices of the specified tile.

### NeighborType[graph, tileIndex] → Integer
Returns the neighborType value (0-10 or 15). 15 indicates a boundary tile.

### NeumannDirection[graph, tileIndex, neighborIndex] → Integer
Returns the direction index of the neighbor tile as seen from the tile. On a square grid, E=0, S=2, W=4, N=6.

## Neighborhood Graph Drawing

### DrawTilingWithNeighborTypes[graph, opts] → Graphics
Draws the tiles color-coded by neighborType. The type distribution is shown in the PlotLabel as a legend.

### DrawTilingNeighborhood[graph, tileIndex, opts] → Graphics
Highlights the specified tile and its neighbors. Moore neighbors = light blue, Neumann neighbors = blue, target tile = red.

## CA Rules

### CreateCARule[ruleSpec] → Association
Creates a CA rule from a ruleSpec Association.
Keys of `ruleSpec`:
- `"type"` — `"GCA"` (default) or `"Partitioned"`
- `"transitionRules"` — list of rules (format below)
- `"rotational"` — `True`/`False` (default `False`)
- `"undefinedDefault"` — output value when no rule matches, or `"same"` to keep the original value
- `"defaultValue"` — initial cell state (integer)
- `"numStates"` — number of states (if omitted, inferred as the maximum output value of the rules + 1)
- `"neighborhood"` — `"Moore"` (default) or `"Neumann"` (GCA only)

GCA rule format: `{centerState, count_state1, ..., count_stateN} -> newState`. Counts are taken over the Moore 8-neighborhood (square grid) or the vertex-sharing neighborhood (RPT). For Neumann, the edge-sharing 4-neighborhood is used.

Partitioned rule format: `{centerState, nwState, neState, seState, swState} -> newState`. With `rotational->True`, 4 rotational variants are generated automatically from each rule. Partitioned CA always uses Neumann directions.

Example:
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
Applies the CA rule for one step and returns the new state list. Calls `gcaStep` if `rule["type"]` is `"GCA"` and `partitionedStep` if it is `"Partitioned"` (`gcaStep` for any other value or when unspecified).

### CAEvolve[graph, rule, initState, steps] → List
Evolves the CA for steps steps and returns the list of all states (length steps+1).

### ParseRuleFile[xmlString] → Association
Parses a `.txt` rule file string from the iOS app and returns a rule specification Association.

## CA Drawing

### DrawCAState[graph, state] → Graphics
Draws the CA state using the default color function.

### DrawCAState[graph, state, colorFunc, opts] → Graphics
Draws the tiles colored by `colorFunc` (integer → color).

### CASimulator[cafile] → DynamicModule
### CASimulator[cafile, conffile] → DynamicModule
Launches the unified file-based CA simulator. `cafile` is an iOS-format `.txt` rule file (loaded with `LoadiOSRuleFile`). The geometry (Square/RPT/KD/AB/multigrid), rule type (GCA/Partitioned/PCA5), and colors are detected automatically. If `conffile` (`.caconf`) is omitted, the simulation starts from the zero state. UI: Step/x10/x50; -10/-50/Back for reverse playback (the history is kept in a ring buffer of size `$CAHistorySize`; for PCA5 when `IsReversiblePCA5` holds, rewinding uses the inverse rule, otherwise states are restored from the saved history); Reset/Center Seed/Clear; Load Conf/Save Conf (read/write `.caconf`); Open Rule/Open Conf (open the original file in the OS default app); Grid (toggles display of the de Bruijn grid lines, available only for RPT/AB/multigrid); Save PNG/PDF/MP4 (evolves for `Steps` steps and exports). There is no `Random` button.

### CASimulator[graph, rule] → DynamicModule
Legacy interface that takes a graph and a rule directly. Scalar CA only. UI with Step/x10/x50/Reset/Random/Center Seed buttons.

### $CAHistorySize
Type: Integer, initial value: 500
Size of the ring buffer used for the CA simulator history. Change this setting before calling `CASimulator`.

## PCA5 (True Five-Neighbor Partitioned CA)

### CreatePCA5Rule[spec] → Association
Creates a true five-neighbor partitioned CA rule. Each cell state is a vector `{c, d1, d2, d3, d4}` (c = center part, d1..d4 = directional parts). The return value always has `"type"->"PCA5"` set (`IsReversiblePCA5`/`InvertPCA5Rule` rely on this key for their checks).
Keys of `spec`:
- `"transitionRules"` — list in the form `{c_in,d1_in,d2_in,d3_in,d4_in} -> {c_out,d1_out,d2_out,d3_out,d4_out}`
- `"rotational"` — `True`/`False` (default `False`). If `True`, 4 variants are generated automatically by cyclically shifting both the input and output directional parts (Definition 2.4)
- `"numStates"` — number of states
- `"defaultValue"` — initial value

Slot correspondence on the square grid: `{c, N, E, S, W}` = indices `{1,2,3,4,5}`.
On RPT/KD, slots are determined automatically by edge matching. Inputs that match no rule always return the quiescent state `{0,0,0,0,0}` (there is no key equivalent to `undefinedDefault`).

Example:
```mathematica
rule = CreatePCA5Rule[<|
  "transitionRules" -> {{0,0,0,1,0} -> {0,1,0,0,0}},
  "rotational" -> True,
  "numStates" -> 2
|>]
```

### PCA5Step[graph, rule, state] → List
Applies one PCA5 step. state is a list of 5-element vectors.

### PCA5Evolve[graph, rule, initState, steps] → List
Evolves the PCA5 for steps steps and returns the list of all states.

### DrawPCA5State[graph, state] → Graphics
Draws a PCA5 state colored by the value of the center part (slot 1).

### DrawPCA5State[graph, state, partIndex] → Graphics
Colors the tiles by the value of the slot specified by `partIndex` (1-5).

### PCA5Simulator[graph, rule] → DynamicModule
Launches the PCA5 simulator with an empty initial state.

### PCA5Simulator[graph, rule, initState] → DynamicModule
Launches the PCA5 simulator with the specified initial state.

### PCA5Simulator[graph, rule, initState, colorAssoc] → DynamicModule
Launches the PCA5 simulator with a custom color Association.

### PCA5Simulator[graph, rule, initState, colorAssoc, configName] → DynamicModule
Sets `configName` as the base name of the export folder. PNG/PDF/MP4 files are saved to `NotebookDirectory[]/configName_<suffix>/`.

### IsReversiblePCA5[rule] → True|False
Returns whether the PCA5 rule is reversible (its local transition function is bijective). Returns `False` if `rule["type"]` is not `"PCA5"` or if the rule is not reversible. The check tests whether the outputs (RHS) of the explicitly defined transition rules are all distinct (undefined inputs need not be considered, because they can always be assigned outputs that preserve bijectivity).

### InvertPCA5Rule[rule] → Association
Generates the inverse rule of a PCA5 rule by enumerating all input/output pairs and swapping LHS and RHS. Valid only when `IsReversiblePCA5[rule]` is `True`. The return value has the form `<|"invLookup"->Association, "type"->"PCA5"|>`.

## iOS File I/O

### LoadiOSRuleFile[path] → Association
Loads a `.txt` rule file from the iOS app. Shift-JIS encoding is handled automatically.
Keys of the return value:
- `"rule"` — the result of `CreatePCA5Rule` or `CreateCARule`
- `"metadata"` — an Association containing `"geometryType"`, `"cellRange"`, `"offsetValues"`, `"stateColors"`, `"ruleType"`, `"name"`, etc.

### LoadiOSConfigFile[path, graph] → List
Loads an iOS `.caconf` configuration file and returns the initial state list corresponding to the given graph: a list of `{c,d1,d2,d3,d4}` vectors for PCA5, or a list of integers for scalar CA.

### SaveiOSRuleFile[path, rule, metadata]
### SaveiOSRuleFile[path, rule]
Saves the rule to an iOS-format `.txt` file. `metadata` is optional (default `{}`). The rule type is taken from `metadata["ruleType"]` if present, otherwise from `rule["type"]`.

### SaveiOSConfigFile[path, graph, state]
Saves the state in the iOS `.caconf` format.

### InferCellRangeFromConfig[configPath, {width, height}] → List
Loads a `.caconf` file and returns a `cellRange` `{xmin, ymin, width, height}` centered on the centroid of the non-default tiles.

### InferCellRangeFromConfig[configPath] → List
Returns the `cellRange` of the minimal bounding range.

### ExportPCA5Steps[graph, rule, state, nSteps, directory] → String
### ExportPCA5Steps[graph, rule, state, nSteps, directory, colorAssoc] → String
Evolves the PCA5 for nSteps steps and saves each frame as a clipped PNG image. File names are `000.png`, `001.png`, ... (nSteps+1 images in total). `colorAssoc` is optional (defaults to the standard CA color palette). Only interior tiles with all 4 Neumann neighbors present are drawn. Returns the path of the output directory.
