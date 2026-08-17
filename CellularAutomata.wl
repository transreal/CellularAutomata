(* ::Package:: *)
(* ============================================================ *)
(*  Penrose Rhomb Tiling — de Bruijn Pentagrid Method           *)
(*  Stage 1: Tiling Generation & Visualization                  *)
(*  Stage 2: Neighborhood Graph & neighborType Classification   *)
(*  Ported from CellularAutomaton (iOS) — RhombPTFactory        *)
(* ============================================================ *)

BeginPackage["CellularAutomata`"];

(* --- Public symbols: Stage 1 --- *)
GeneratePenroseRhombs::usage = 
  "GeneratePenroseRhombs[range, offset] generates Penrose rhomb tiles \
using the de Bruijn pentagrid method. range = {xmin, ymin, width, height}, \
offset = {g0, g1, g2, g3, g4}.";

DrawPenroseTiling::usage = 
  "DrawPenroseTiling[tiles] renders the tiling as a Graphics object.";

TileVertices::usage = 
  "TileVertices[tile] returns the 4 vertex coordinates of a tile.";

TileType::usage = 
  "TileType[tile] returns \"Fat\" or \"Thin\".";

PenroseTilingDemo::usage = 
  "PenroseTilingDemo[] shows an interactive demonstration.";

(* --- Public symbols: Stage 2 --- *)
BuildTilingGraph::usage = 
  "BuildTilingGraph[tiles] builds vertex-sharing and edge-sharing \
neighbor data for all tiles. Returns an Association with keys: \
\"tiles\", \"vertexToTiles\", \"mooreNeighbors\", \"neumannNeighbors\", \
\"neumannDirections\", \"neighborTypes\".";

MooreNeighbors::usage = 
  "MooreNeighbors[graph, tileIndex] returns the Moore neighbor indices.";

NeumannNeighbors::usage = 
  "NeumannNeighbors[graph, tileIndex] returns the Neumann neighbor indices.";

NeighborType::usage = 
  "NeighborType[graph, tileIndex] returns the neighborType (0-10, or 15).";

DrawTilingWithNeighborTypes::usage = 
  "DrawTilingWithNeighborTypes[graph] draws tiles colored by neighborType.";

DrawTilingNeighborhood::usage = 
  "DrawTilingNeighborhood[graph, tileIndex] highlights a tile and its neighbors.";

NeumannDirection::usage = 
  "NeumannDirection[graph, tileIndex, neighborIndex] returns direction index.";

(* --- Public symbols: Stage 3 --- *)
CreateCARule::usage = 
  "CreateCARule[ruleSpec] creates a CA rule from a specification. \
ruleSpec is an Association with keys: \
\"transitionRules\" (list of rules), \"rotational\" (True/False), \
\"undefinedDefault\" (default output), \"defaultValue\" (initial state), \
\"neighborhood\" (\"Moore\" or \"Neumann\", default \"Moore\"; GCA only). \
For GCA with Moore, key = {center, count_state1, ..., count_stateN} \
where counts are over 8 neighbors (square) or vertex-sharing (Penrose). \
For GCA with Neumann, counts are over 4 neighbors (square) or \
edge-sharing (Penrose). Partitioned CA always uses Neumann directions.";

CAStep::usage = 
  "CAStep[graph, rule, state] applies one step of the cellular automaton \
rule to the given state. Returns new state (list of values).";

CAEvolve::usage = 
  "CAEvolve[graph, rule, initState, steps] evolves the CA for the given \
number of steps. Returns list of states.";

DrawCAState::usage = 
  "DrawCAState[graph, state, colorFunc] draws tiles colored by state values.";

CASimulator::usage = 
  "CASimulator[cafile] launches a unified CA simulator from a rule file (.txt). \
Geometry (Square/RPT/KD), rule type (GCA/Partitioned/PCA5), and colors are \
auto-detected. CASimulator[cafile, conffile] additionally loads an initial \
configuration from a .caconf file. \
CASimulator[graph, rule] is the legacy graph-based interface for scalar CA.";

ParseRuleFile::usage = 
  "ParseRuleFile[xmlString] parses a .txt rule file from the iOS app \
and returns a rule specification Association.";

(* --- Public symbols: Stage 5 --- *)
GeneratePenroseKD::usage = 
  "GeneratePenroseKD[range, offset] generates Penrose kite & dart tiles \
from rhomb decomposition. Returns list of tile Associations with keys \
\"label\", \"type\" (\"Kite\"|\"Dart\"), \"vertices\", \"vertexKeys\".";

DrawPenroseKD::usage = 
  "DrawPenroseKD[tiles] draws kite & dart tiling with type-based coloring.";

BuildKDTilingGraph::usage = 
  "BuildKDTilingGraph[tiles] builds neighborhood graph for KD tiling. \
Same structure as BuildTilingGraph.";

(* --- Public symbols: Square Grid --- *)
GenerateSquareGrid::usage = 
  "GenerateSquareGrid[cols, rows] generates a square grid tiling. \
Returns list of tile Associations compatible with BuildTilingGraph.";

DrawSquareGrid::usage = 
  "DrawSquareGrid[tiles] draws the square grid.";

BuildSquareGridGraph::usage = 
  "BuildSquareGridGraph[tiles, cols, rows] builds neighborhood graph \
for the square grid. Moore = 8 neighbors, Neumann = 4 (NSEW). \
Directions: 0=E, 2=S, 4=W, 6=N.";

(* --- Public symbols: Ammann-Beenker & Generalized Multigrid Tiling --- *)
GenerateMultigridRhombs::usage = 
  "GenerateMultigridRhombs[symOrder, range, offset] generates a rhomb tiling \
using the de Bruijn multigrid method for the given symmetry order. \
For odd n: n grid families at angles 2\[Pi]k/n. \
For even n: n/2 grid families at angles 2\[Pi]k/n. \
offset has numGrids elements. \
Examples: 5=Penrose, 7=heptagonal, 8=Ammann\[Dash]Beenker, 12=dodecagonal.";

DrawMultigridTiling::usage = 
  "DrawMultigridTiling[tiles] renders a multigrid rhomb tiling \
with automatic coloring by rhomb type.";

GenerateABRhombs::usage = 
  "GenerateABRhombs[range, offset] generates Ammann\[Dash]Beenker rhomb tiles. \
Equivalent to GenerateMultigridRhombs[8, range, offset].";

DrawABTiling::usage = 
  "DrawABTiling[tiles] renders the Ammann\[Dash]Beenker tiling. \
Equivalent to DrawMultigridTiling[tiles].";

(* --- Public symbols: True Partitioned CA --- *)
CreatePCA5Rule::usage = 
  "CreatePCA5Rule[spec] creates a true 5-neighborhood partitioned CA rule. \
Each cell state is a vector {c, d1, d2, d3, d4} where c=center, d1..d4=directional parts. \
Rule format: {c_in, d1_in, d2_in, d3_in, d4_in} -> {c_out, d1_out, d2_out, d3_out, d4_out}. \
For square grid: parts = {c, N, E, S, W}. Input d_i comes from the facing part of neighbor i. \
With rotational->True, both input and output directional parts rotate (Definition 2.4). \
Keys: \"transitionRules\", \"rotational\" (True/False), \"numStates\", \"defaultValue\".";

PCA5Step::usage = 
  "PCA5Step[graph, rule, state] applies one step of the true 5-neighborhood \
partitioned CA. State is a list of 5-element vectors.";

PCA5Evolve::usage = 
  "PCA5Evolve[graph, rule, initState, steps] evolves the PCA5.";

DrawPCA5State::usage = 
  "DrawPCA5State[graph, state] draws the PCA5 state, coloring by center part. \
Optional second argument: part index (1-5) to display.";

PCA5Simulator::usage = 
  "PCA5Simulator[graph, rule] — empty initial state. \
PCA5Simulator[graph, rule, initState] — with loaded initial state. \
PCA5Simulator[graph, rule, initState, colorAssoc] — with custom colors. \
PCA5Simulator[graph, rule, initState, colorAssoc, configName] — \
configName sets export folder base name. \
Save PNG/PDF/MP4 export to NotebookDirectory[]/configName_<suffix>/.";

(* --- Public symbols: iOS File I/O --- *)
LoadiOSRuleFile::usage = 
  "LoadiOSRuleFile[path] loads an iOS CA simulator rule file (.txt). \
Returns an Association with keys: \"rule\" (CreatePCA5Rule or CreateCARule result), \
\"metadata\" (geometry, colors, name, etc). \
Handles Shift-JIS encoding automatically.";

LoadiOSConfigFile::usage = 
  "LoadiOSConfigFile[path, graph] loads an iOS .caconf configuration file \
and returns the initial state matching the given graph. \
For PCA5: returns list of {c,d1,d2,d3,d4} vectors. \
For scalar CA: returns list of integers.";

SaveiOSRuleFile::usage = 
  "SaveiOSRuleFile[path, rule, metadata] saves a rule to iOS format.";

SaveiOSConfigFile::usage = 
  "SaveiOSConfigFile[path, graph, state] saves state to iOS .caconf format.";

InferCellRangeFromConfig::usage = 
  "InferCellRangeFromConfig[configPath, {width, height}] reads a .caconf file, \
computes the centroid of non-default tiles, and returns a cellRange \
{xmin, ymin, width, height} centered on the config tiles. \
InferCellRangeFromConfig[configPath] returns a minimal bounding range.";

ExportPCA5Steps::usage = 
  "ExportPCA5Steps[graph, rule, state, nSteps, directory, colorAssoc] \
evolves the PCA5 for nSteps and exports each frame as a clipped PNG. \
Files are saved as 000.png, 001.png, ... in the given directory. \
Only interior tiles (with all 4 Neumann neighbors) are drawn.";

(* --- Public symbols: Reversibility & History --- *)
IsReversiblePCA5::usage = 
  "IsReversiblePCA5[rule] returns True if the PCA5 rule is reversible \
(i.e. the local transition function is a bijection). Returns False for \
non-PCA5 rules or non-reversible PCA5 rules.";

InvertPCA5Rule::usage = 
  "InvertPCA5Rule[rule] creates the inverse PCA5 rule by enumerating all \
input/output pairs and swapping them. Only valid if IsReversiblePCA5[rule] is True.";

$CAHistorySize::usage = 
  "$CAHistorySize is the ring buffer size for CA simulator history. \
Default is 500. Set before calling CASimulator to change.";

$CAHistorySize = 500;

Begin["`Private`"];

(* Capture package directory at load time *)
$caPackageDir = DirectoryName[$InputFileName];

(* ============================================================ *)
(*  Constants                                                    *)
(* ============================================================ *)

\[Theta] = N[\[Pi]/5];
eVec = Table[N@{Cos[2 i \[Theta]], Sin[2 i \[Theta]]}, {i, 0, 4}];
projectTo2D[k_List] := k.eVec;

sVal = Table[N@Sin[2 i \[Theta]], {i, 0, 4}];
cVal = Table[N@Cos[2 i \[Theta]], {i, 0, 4}];
tVal = Table[N@Tan[2 i \[Theta]], {i, 0, 4}];

gridIntersection[i_, m_, j_, n_, offset_] := 
  Module[{x, y, oi, oj, ci, si, cj, sj, ti, tj},
    oi = offset[[i + 1]]; oj = offset[[j + 1]];
    ci = cVal[[i + 1]]; si = sVal[[i + 1]];
    cj = cVal[[j + 1]]; sj = sVal[[j + 1]];
    ti = tVal[[i + 1]]; tj = tVal[[j + 1]];
    If[i == 0,
      x = m + oi;
      y = -x/tj + (oj + n)/sj;
      ,
      x = ((oi + m) sj - (oj + n) si) / (ci cj (tj - ti));
      y = -x/tj + (oj + n)/sj;
    ];
    {x, y}
  ];

classifyTile[{k0_, k1_, k2_, k3_, k4_, r_, s_}] := 
  If[Mod[s - r, 5] == 1, "Fat", "Thin"];

computeVertices[{k0_, k1_, k2_, k3_, k4_, r_, s_}] := 
  Module[{v0, v1, v2, v3, kk},
    kk = {k0, k1, k2, k3, k4};
    v0 = projectTo2D[kk];
    kk[[r + 1]] += 1;
    v1 = projectTo2D[kk];
    kk[[s + 1]] += 1;
    v2 = projectTo2D[kk];
    kk[[r + 1]] -= 1;
    v3 = projectTo2D[kk];
    If[Mod[Total[{k0, k1, k2, k3, k4}] + 1, 5] == 2,
      {v2, v3, v0, v1},
      {v0, v1, v2, v3}
    ]
  ];

(* Compute vertex keys (5D integer coords) for a tile label *)
(* Returns 4 keys in same order as computeVertices *)
vertexKeys[{k0_, k1_, k2_, k3_, k4_, r_, s_}] := 
  Module[{kk, keys},
    kk = {k0, k1, k2, k3, k4};
    keys = {kk};
    kk = ReplacePart[kk, (r + 1) -> kk[[r + 1]] + 1];
    AppendTo[keys, kk];
    kk = ReplacePart[kk, (s + 1) -> kk[[s + 1]] + 1];
    AppendTo[keys, kk];
    kk = ReplacePart[kk, (r + 1) -> kk[[r + 1]] - 1];
    AppendTo[keys, kk];
    If[Mod[Total[{k0, k1, k2, k3, k4}] + 1, 5] == 2,
      {keys[[3]], keys[[4]], keys[[1]], keys[[2]]},
      keys
    ]
  ];

(* ============================================================ *)
(*  Stage 1: Main generation function                            *)
(* ============================================================ *)

GeneratePenroseRhombs[
    range : {xmin_, ymin_, width_, height_}, 
    offset : {g0_, g1_, g2_, g3_, g4_}
  ] := 
  Module[{kRange, tiles, x, y, i, j, m, n, kk, label, r, s,
          xmax = xmin + width, ymax = ymin + height},
    kRange = {
      {Ceiling[xmin - g0],           Ceiling[xmax - g0]},
      {Ceiling[xmin cVal[[2]] + ymin sVal[[2]] - g1], 
       Ceiling[xmax cVal[[2]] + ymax sVal[[2]] - g1]},
      {Ceiling[xmax cVal[[3]] + ymin sVal[[3]] - g2], 
       Ceiling[xmin cVal[[3]] + ymax sVal[[3]] - g2]},
      {Ceiling[xmax cVal[[4]] + ymax sVal[[4]] - g3], 
       Ceiling[xmin cVal[[4]] + ymin sVal[[4]] - g3]},
      {Ceiling[xmin cVal[[5]] + ymax sVal[[5]] - g4], 
       Ceiling[xmax cVal[[5]] + ymin sVal[[5]] - g4]}
    };
    tiles = Association[];
    Do[
      Do[
        Do[
          {x, y} = gridIntersection[i, m, j, n, offset];
          If[xmin <= x <= xmax && ymin <= y <= ymax,
            kk = Table[
              If[l == i, m, If[l == j, n, 
                Ceiling[cVal[[l + 1]] x + sVal[[l + 1]] y - offset[[l + 1]]]]],
              {l, 0, 4}
            ];
            {r, s} = {i, j};
            If[s - r == 4 || s - r == 3, {r, s} = {j, i}];
            label = Append[kk, r] ~Append~ s;
            If[!KeyExistsQ[tiles, label],
              tiles[label] = <|
                "label" -> label,
                "type" -> classifyTile[label],
                "vertices" -> computeVertices[label],
                "vertexKeys" -> vertexKeys[label]
              |>;
            ];
          ];
          , {n, kRange[[j + 1, 1]], kRange[[j + 1, 2]]}
        ];
        , {m, kRange[[i + 1, 1]], kRange[[i + 1, 2]]}
      ];
      , {i, 0, 3}, {j, i + 1, 4}
    ];
    Values[tiles]
  ];

(* ============================================================ *)
(*  Stage 1: Accessors & Drawing                                 *)
(* ============================================================ *)

TileVertices[tile_Association] := tile["vertices"];
TileType[tile_Association] := tile["type"];

fatColor  = RGBColor[0.85, 0.75, 0.45, 0.85];
thinColor = RGBColor[0.35, 0.55, 0.80, 0.85];

DrawPenroseTiling[tiles_List, opts___] := 
  Graphics[
    {EdgeForm[{GrayLevel[0.3], Thickness[0.001]}],
     Map[
       {If[#["type"] === "Fat", fatColor, thinColor],
        Polygon[#["vertices"]]} &,
       tiles
     ]
    },
    opts,
    AspectRatio -> Automatic,
    PlotRange -> All
  ];

PenroseTilingDemo[] := 
  DynamicModule[{tiles, range, offset, size = 8},
    offset = {0, 0.1, -0.1, 0.2, -0.2};
    Manipulate[
      range = {-1, -1, size, size};
      tiles = GeneratePenroseRhombs[range, offset];
      Column[{
        Style[Row[{"Tiles: ", Length[tiles], 
          "  (Fat: ", Count[tiles, t_ /; t["type"] === "Fat"], 
          ", Thin: ", Count[tiles, t_ /; t["type"] === "Thin"], ")"}], 
          FontFamily -> "Helvetica", FontSize -> 12],
        DrawPenroseTiling[tiles, ImageSize -> 600]
      }],
      {{size, 8, "Tiling size"}, 3, 40, 1, Appearance -> "Labeled"},
      {{offset, {0, 0.1, -0.1, 0.2, -0.2}, "Offsets (g0..g4)"}, 
        ControlType -> InputField}
    ]
  ];

(* ============================================================ *)
(*  Generalized de Bruijn Multigrid Rhomb Tiling                 *)
(*  symOrder = symmetry order of the tiling:                     *)
(*    odd n:  n grid families at angles 2\[Pi]k/n (n-fold)      *)
(*    even n: n/2 grid families at angles 2\[Pi]k/n (n-fold)    *)
(*  Examples: 5=Penrose, 7=heptagonal, 8=AB, 12=dodecagonal     *)
(* ============================================================ *)

(* Compute number of grid families from symmetry order *)
mgNumGrids[symOrder_Integer] := If[OddQ[symOrder], symOrder, symOrder/2];

(* Grid direction vectors *)
mgEVec[symOrder_Integer] := 
  Table[N@{Cos[2 Pi k/symOrder], Sin[2 Pi k/symOrder]}, 
    {k, 0, mgNumGrids[symOrder] - 1}];

(* Rhomb class: the "thinness index" from grid pair (r,s) *)
mgRhombClass[r_, s_, numGrids_] := 
  Module[{d = Mod[s - r, numGrids]}, Min[d, numGrids - d]];

(* Acute angle of rhomb class d for given symmetry order *)
mgAcuteAngle[d_, symOrder_] := Min[2. Pi d/symOrder, Pi - 2. Pi d/symOrder];

(* Default offsets chosen to avoid near-singularities *)
(* These values have been tested to produce gap-free tilings *)
mgDefaultOffsets[5]  = {0, 0.1, -0.1, 0.2, -0.2};
mgDefaultOffsets[7]  = {0, 0.1, -0.1, 0.2, -0.2, 0.15, -0.15};
mgDefaultOffsets[8]  = {0, 0.1, -0.1, 0.2};
mgDefaultOffsets[12] = {0, 0.13, -0.09, 0.21, -0.17, 0.11};
mgDefaultOffsets[symOrder_Integer] := 
  Module[{ng = mgNumGrids[symOrder]},
    (* Golden-ratio based irrational offsets to avoid near-singularities *)
    Table[0.1 FractionalPart[k GoldenRatio] (-1)^k, {k, 0, ng - 1}]
  ];

(* Build type name from rhomb class *)
mgTypeName[cls_, sortedClasses_List] := 
  If[Length[sortedClasses] <= 2,
    If[cls === sortedClasses[[1]], "Thin",
      If[Length[sortedClasses] == 2 && cls === sortedClasses[[2]], "Fat", "Fat"]],
    "Rhomb" <> ToString[First[FirstPosition[sortedClasses, cls]]]
  ];

(* Color palette for multigrid tilings *)
mgColorPalette[nTypes_Integer] := 
  Module[{hues},
    If[nTypes <= 2,
      {RGBColor[0.35, 0.55, 0.80, 0.85],   (* Thin *)
       RGBColor[0.85, 0.75, 0.45, 0.85]},   (* Fat *)
      hues = Table[Hue[k/nTypes, 0.6, 0.85, 0.85], {k, 0, nTypes - 1}];
      hues
    ]
  ];

GenerateMultigridRhombs[symOrder_Integer, 
    range : {xmin_, ymin_, width_, height_}, 
    offset_List] := 
  Module[{numGrids, eV, cV, sV, kRange, tiles,
          x, y, i, j, m, nn, kk, label, r, s,
          xmax = xmin + width, ymax = ymin + height,
          corners, vals, det, ci, si, cj, sj, oi, oj,
          allClasses, sortedClasses, swp, verts, vkeys, cls, tp,
          v0, kr, ks, v1, v3, cross, kk2, keys,
          pad},
    
    numGrids = mgNumGrids[symOrder];
    eV = mgEVec[symOrder];
    cV = eV[[All, 1]]; sV = eV[[All, 2]];
    
    (* Determine all possible rhomb classes *)
    allClasses = Union[Table[
      mgRhombClass[i, j, numGrids],
      {i, 0, numGrids - 2}, {j, i + 1, numGrids - 1}] // Flatten];
    (* Remove class 0 (parallel grids, no intersection) *)
    allClasses = DeleteCases[allClasses, 0];
    (* Also remove if angle \[TildeTilde] \[Pi] (det \[TildeTilde] 0) *)
    allClasses = Select[allClasses, mgAcuteAngle[#, symOrder] > 0.01 &];
    sortedClasses = SortBy[allClasses, mgAcuteAngle[#, symOrder] &];
    
    (* Padding: thin rhombs have vertices far from their grid intersection *)
    pad = 2.0;
    
    (* Grid index ranges from bounding box — padded *)
    corners = {{xmin - pad, ymin - pad}, {xmax + pad, ymin - pad}, 
               {xmax + pad, ymax + pad}, {xmin - pad, ymax + pad}};
    kRange = Table[
      vals = (cV[[k + 1]] #[[1]] + sV[[k + 1]] #[[2]]) & /@ corners;
      {Ceiling[Min[vals] - offset[[k + 1]]] - 1, 
       Ceiling[Max[vals] - offset[[k + 1]]] + 1},
      {k, 0, numGrids - 1}
    ];
    
    tiles = Association[];
    Do[
      Do[
        Do[
          (* Grid intersection via Cramer's rule *)
          ci = cV[[i + 1]]; si = sV[[i + 1]]; oi = offset[[i + 1]];
          cj = cV[[j + 1]]; sj = sV[[j + 1]]; oj = offset[[j + 1]];
          det = ci sj - cj si;
          If[Abs[det] < 1.0*^-10, Continue[]];
          x = ((m + oi) sj - (nn + oj) si) / det;
          y = ((nn + oj) ci - (m + oi) cj) / det;
          If[xmin - pad <= x <= xmax + pad && 
             ymin - pad <= y <= ymax + pad,
            (* Compute grid indices; handle near-integer values *)
            Module[{rawVals, baseK, variants, tol = 1.0*^-6, variantSets},
              rawVals = Table[
                cV[[l + 1]] x + sV[[l + 1]] y - offset[[l + 1]], 
                {l, 0, numGrids - 1}];
              (* For intersection grids i,j: value is exact integer *)
              (* For other grids: check if near integer boundary *)
              variantSets = Table[
                If[l == i || l == j, 
                  {If[l == i, m, nn]},
                  Module[{rv = rawVals[[l + 1]], k},
                    k = Ceiling[rv];
                    If[Abs[rv - k] < tol || Abs[rv - (k - 1)] < tol,
                      DeleteDuplicates[{k, k - 1}],
                      {k}
                    ]
                  ]
                ],
                {l, 0, numGrids - 1}
              ];
              variants = Tuples[variantSets];
              Do[
                kk = var;
                {r, s} = {i, j};
                If[Mod[s - r, numGrids] > numGrids / 2, {r, s} = {j, i}];
                label = Join[kk, {r, s}];
                If[!KeyExistsQ[tiles, label],
                  (* Swap detection via cross product *)
                  v0 = kk.eV;
                  kr = kk; kr[[r + 1]] += 1; v1 = kr.eV;
                  ks = kk; ks[[s + 1]] += 1; v3 = ks.eV;
                  cross = (v1 - v0)[[1]] (v3 - v0)[[2]] - 
                          (v1 - v0)[[2]] (v3 - v0)[[1]];
                  swp = cross < 0;
                  (* Vertices *)
                  kk2 = kk;
                  v0 = kk2.eV;
                  kk2[[r + 1]] += 1; v1 = kk2.eV;
                  kk2[[s + 1]] += 1; verts = kk2.eV;
                  kk2[[r + 1]] -= 1; v3 = kk2.eV;
                  verts = If[swp, {verts, v3, v0, v1}, {v0, v1, verts, v3}];
                  (* Vertex keys *)
                  keys = {kk};
                  kk2 = ReplacePart[kk, r + 1 -> kk[[r + 1]] + 1];
                  AppendTo[keys, kk2];
                  kk2 = ReplacePart[kk2, s + 1 -> kk2[[s + 1]] + 1];
                  AppendTo[keys, kk2];
                  kk2 = ReplacePart[kk2, r + 1 -> kk2[[r + 1]] - 1];
                  AppendTo[keys, kk2];
                  vkeys = If[swp, 
                    {keys[[3]], keys[[4]], keys[[1]], keys[[2]]}, keys];
                  (* Classify *)
                  cls = mgRhombClass[r, s, numGrids];
                  tp = mgTypeName[cls, sortedClasses];
                  tiles[label] = <|
                    "label" -> label, "type" -> tp,
                    "vertices" -> verts, "vertexKeys" -> vkeys,
                    "swapped" -> swp, "rhombClass" -> cls,
                    "numGrids" -> numGrids, "symOrder" -> symOrder
                  |>;
                ];
                , {var, variants}
              ];
            ];
          ];
          , {nn, kRange[[j + 1, 1]], kRange[[j + 1, 2]]}
        ];
        , {m, kRange[[i + 1, 1]], kRange[[i + 1, 2]]}
      ];
      , {i, 0, numGrids - 2}, {j, i + 1, numGrids - 1}
    ];
    Values[tiles]
  ];

(* Drawing with auto-coloring by rhomb class *)
DrawMultigridTiling[tiles_List, opts___] := 
  Module[{classes, sortedClasses, symOrder, colors, colorMap},
    If[Length[tiles] == 0, Return[Graphics[{}]]];
    symOrder = Lookup[tiles[[1]], "symOrder", 
      2 * tiles[[1]]["numGrids"]];
    classes = Union[Lookup[tiles, "rhombClass"]];
    sortedClasses = SortBy[classes, mgAcuteAngle[#, symOrder] &];
    colors = mgColorPalette[Length[sortedClasses]];
    colorMap = AssociationThread[sortedClasses, colors];
    Graphics[
      {EdgeForm[{GrayLevel[0.3], Thickness[0.001]}],
       Map[
         {Lookup[colorMap, #["rhombClass"], GrayLevel[0.5]],
          Polygon[#["vertices"]]} &,
         tiles
       ]
      },
      opts,
      AspectRatio -> Automatic,
      PlotRange -> All
    ]
  ];

(* --- Backward-compatible wrappers --- *)
GenerateABRhombs[range : {_, _, _, _}, offset : {_, _, _, _}] := 
  GenerateMultigridRhombs[8, range, offset];

DrawABTiling[tiles_List, opts___] := DrawMultigridTiling[tiles, opts];

(* ============================================================ *)
(*  Stage 2: Build Neighborhood Graph                            *)
(* ============================================================ *)

BuildTilingGraph[tiles_List] := 
  Module[{nTiles, vertexToTiles, mooreNbrs, neumannNbrs, neumannDirs,
          nbrTypes, vkeys, vk, edgeToTiles, edgeKey, a, b, tileList,
          center, v2pt, theta0, theta1, dirIdx, nbrCenter, nbr},
    
    nTiles = Length[tiles];
    
    (* --- Step 1: Build vertex -> tile index mapping --- *)
    vertexToTiles = Association[];
    Do[
      vkeys = tiles[[i]]["vertexKeys"];
      Do[
        vk = vkeys[[j]];
        If[KeyExistsQ[vertexToTiles, vk],
          AppendTo[vertexToTiles[vk], i],
          vertexToTiles[vk] = {i}
        ];
        , {j, 1, 4}
      ];
      , {i, 1, nTiles}
    ];
    
    (* --- Step 2: Moore neighbors (vertex-sharing) --- *)
    mooreNbrs = Association[];
    Do[
      vkeys = tiles[[i]]["vertexKeys"];
      mooreNbrs[i] = DeleteCases[
        Union @@ (Lookup[vertexToTiles, vkeys, {}]),
        i
      ];
      , {i, 1, nTiles}
    ];
    
    (* --- Step 3: Neumann neighbors (edge-sharing) --- *)
    edgeToTiles = Association[];
    Do[
      vkeys = tiles[[i]]["vertexKeys"];
      Do[
        edgeKey = Sort[{vkeys[[j]], vkeys[[Mod[j, 4] + 1]]}];
        If[KeyExistsQ[edgeToTiles, edgeKey],
          AppendTo[edgeToTiles[edgeKey], i],
          edgeToTiles[edgeKey] = {i}
        ];
        , {j, 1, 4}
      ];
      , {i, 1, nTiles}
    ];
    
    neumannNbrs = Association[];
    Do[neumannNbrs[i] = {}, {i, 1, nTiles}];
    Scan[
      Function[{edgeKey},
        tileList = edgeToTiles[edgeKey];
        If[Length[tileList] == 2,
          {a, b} = tileList;
          neumannNbrs[a] = Union[neumannNbrs[a], {b}];
          neumannNbrs[b] = Union[neumannNbrs[b], {a}];
        ];
      ],
      Keys[edgeToTiles]
    ];
    
    (* --- Step 4: Neumann directions --- *)
    (* Direction relative to v0->v2 axis, mapped to 0,2,4,6 *)
    (* Matches RhombPTFactory.setNeumannCells *)
    neumannDirs = Association[];
    Do[
      neumannDirs[i] = Association[];
      center = Mean[{tiles[[i]]["vertices"][[1]], 
                      tiles[[i]]["vertices"][[3]]}];
      v2pt = tiles[[i]]["vertices"][[3]];
      theta0 = ArcTan @@ (v2pt - center);
      Do[
        nbrCenter = Mean[{tiles[[nbr]]["vertices"][[1]], 
                          tiles[[nbr]]["vertices"][[3]]}];
        theta1 = ArcTan @@ (nbrCenter - center);
        dirIdx = Floor[Mod[theta1 - theta0 + 2.5 Pi, 2 Pi] / Pi * 2];
        neumannDirs[i][nbr] = dirIdx * 2;
        , {nbr, neumannNbrs[i]}
      ];
      , {i, 1, nTiles}
    ];
    
    (* --- Step 5: neighborType classification --- *)
    nbrTypes = Association[];
    Do[
      nbrTypes[i] = classifyNeighborType[i, tiles, mooreNbrs, neumannNbrs, vertexToTiles];
      , {i, 1, nTiles}
    ];
    
    <|
      "tiles" -> tiles,
      "vertexToTiles" -> vertexToTiles,
      "mooreNeighbors" -> mooreNbrs,
      "neumannNeighbors" -> neumannNbrs,
      "neumannDirections" -> neumannDirs,
      "neighborTypes" -> nbrTypes
    |>
  ];

(* ============================================================ *)
(*  neighborType classification                                  *)
(*  Ported from RhombPTFactory.checkNeighborType                 *)
(* ============================================================ *)

classifyNeighborType[idx_, tiles_, mooreNbrs_, neumannNbrs_, vertexToTiles_] := 
  Module[{tile, moore, neumann, v13Nbrs, 
          nMooreThin, nNeumannFat, nV13Thin, nTile,
          vkeys, v1tiles, v3tiles, result = 15},
    
    tile = tiles[[idx]];
    moore = mooreNbrs[idx];
    neumann = neumannNbrs[idx];
    nTile = Length[moore];
    
    nMooreThin = Count[tiles[[#]]["type"] & /@ moore, "Thin"];
    nNeumannFat = Count[tiles[[#]]["type"] & /@ neumann, "Fat"];
    
    (* v1,v3 neighbors: tiles sharing vertex 1 or vertex 3 *)
    vkeys = tile["vertexKeys"];
    v1tiles = Lookup[vertexToTiles, Key[vkeys[[2]]], {}];
    v3tiles = Lookup[vertexToTiles, Key[vkeys[[4]]], {}];
    v13Nbrs = DeleteCases[Union[v1tiles, v3tiles], idx];
    nV13Thin = Count[tiles[[#]]["type"] & /@ v13Nbrs, "Thin"];
    
    Which[
      nTile == 11 && nV13Thin == 4,  result = 10,
      nTile == 11 && nV13Thin == 3,  result = 9,
      nTile == 10 && tile["type"] === "Fat" && nMooreThin == 4 && nV13Thin == 4,
        result = 4,
      nTile == 10 && tile["type"] === "Fat" && nMooreThin == 4 && nV13Thin == 3,
        result = 6,
      nTile == 10 && tile["type"] === "Fat" && nMooreThin == 4 && nV13Thin == 2,
        result = 5,
      tile["type"] === "Thin" && nNeumannFat == 4 && nTile == 9,
        result = 3,
      tile["type"] === "Thin" && nTile == 9 && nMooreThin == 2,
        result = 2,
      tile["type"] === "Fat" && nTile == 7 && nV13Thin == 2 && nNeumannFat == 2,
        result = 0,
      tile["type"] === "Fat" && nTile == 8 && nV13Thin == 2 && nNeumannFat == 2,
        result = 1,
      tile["type"] === "Thin" && nTile == 10,
        result = classifyThinType78[idx, tiles, moore],
      True, result = 15
    ];
    result
  ];

(* Distinguish Thin with 10 Moore neighbors: type 7 vs 8 *)
classifyThinType78[idx_, tiles_, moore_] := 
  Module[{tile, v1, v3, result = 7, nbrTile, mid, det},
    tile = tiles[[idx]];
    v1 = tile["vertices"][[2]];
    v3 = tile["vertices"][[4]];
    Do[
      nbrTile = tiles[[nbr]];
      If[nbrTile["type"] === "Thin",
        mid = Mean[{nbrTile["vertices"][[2]], nbrTile["vertices"][[4]]}];
        det = Abs[(v1[[1]] - mid[[1]]) (v3[[2]] - mid[[2]]) - 
                   (v3[[1]] - mid[[1]]) (v1[[2]] - mid[[2]])];
        If[det < 0.0001,
          result = 8;
          Break[];
        ];
      ];
      , {nbr, moore}
    ];
    result
  ];

(* ============================================================ *)
(*  Stage 2: Accessors                                           *)
(* ============================================================ *)

MooreNeighbors[graph_Association, idx_Integer] := 
  graph["mooreNeighbors"][idx];

NeumannNeighbors[graph_Association, idx_Integer] := 
  graph["neumannNeighbors"][idx];

NeighborType[graph_Association, idx_Integer] := 
  graph["neighborTypes"][idx];

NeumannDirection[graph_Association, idx_Integer, nbrIdx_Integer] := 
  graph["neumannDirections"][idx][nbrIdx];

(* ============================================================ *)
(*  Stage 2: Drawing                                             *)
(* ============================================================ *)

neighborTypeColors = <|
  0  -> RGBColor[0.8, 0.2, 0.2],
  1  -> RGBColor[0.9, 0.5, 0.1],
  2  -> RGBColor[0.9, 0.8, 0.1],
  3  -> RGBColor[0.5, 0.8, 0.1],
  4  -> RGBColor[0.1, 0.7, 0.3],
  5  -> RGBColor[0.1, 0.7, 0.7],
  6  -> RGBColor[0.2, 0.4, 0.9],
  7  -> RGBColor[0.4, 0.2, 0.8],
  8  -> RGBColor[0.7, 0.2, 0.8],
  9  -> RGBColor[0.9, 0.3, 0.6],
  10 -> RGBColor[0.5, 0.5, 0.5],
  15 -> RGBColor[1, 1, 1, 0.3]
|>;

DrawTilingWithNeighborTypes[graph_Association, opts___] := 
  Module[{tiles, nbrTypes, legends, usedTypes},
    tiles = graph["tiles"];
    nbrTypes = graph["neighborTypes"];
    usedTypes = Sort@DeleteDuplicates[Values[nbrTypes]];
    Graphics[{
      EdgeForm[{GrayLevel[0.4], Thickness[0.0005]}],
      Table[
        {Lookup[neighborTypeColors, nbrTypes[i], White],
         Polygon[tiles[[i]]["vertices"]]},
        {i, 1, Length[tiles]}
      ]},
      opts,
      AspectRatio -> Automatic,
      PlotRange -> All,
      PlotLabel -> Row[{"neighborType distribution: ", 
        Counts[Values[nbrTypes]]}]
    ]
  ];

DrawTilingNeighborhood[graph_Association, idx_Integer, opts___] := 
  Module[{tiles, moore, neumann, nbrTypes, center, tile, 
          nbrDirs, nbr, nbrCenter, dir, allNbrs, plotRange,
          ctr, radius},
    tiles = graph["tiles"];
    moore = graph["mooreNeighbors"][idx];
    neumann = graph["neumannNeighbors"][idx];
    nbrTypes = graph["neighborTypes"];
    nbrDirs = graph["neumannDirections"][idx];
    tile = tiles[[idx]];
    center = Mean[{tile["vertices"][[1]], tile["vertices"][[3]]}];
    
    (* Compute a local plot range around the tile *)
    allNbrs = Union[moore, {idx}];
    ctr = Mean[Flatten[tiles[[#]]["vertices"] & /@ allNbrs, 1]];
    radius = Max[Norm[# - ctr] & /@ Flatten[tiles[[#]]["vertices"] & /@ allNbrs, 1]] + 0.5;
    plotRange = {{ctr[[1]] - radius, ctr[[1]] + radius}, 
                 {ctr[[2]] - radius, ctr[[2]] + radius}};
    
    Graphics[{
      EdgeForm[{GrayLevel[0.7], Thickness[0.0005]}],
      GrayLevel[0.92],
      Polygon[#["vertices"]] & /@ tiles,
      
      (* Moore neighbors *)
      EdgeForm[{GrayLevel[0.3], Thickness[0.001]}],
      RGBColor[0.7, 0.85, 1],
      Polygon[tiles[[#]]["vertices"]] & /@ moore,
      
      (* Neumann neighbors *)
      RGBColor[0.3, 0.5, 0.9],
      Polygon[tiles[[#]]["vertices"]] & /@ neumann,
      
      (* Selected tile *)
      RGBColor[0.9, 0.2, 0.2],
      Polygon[tile["vertices"]],
      
      (* Direction labels *)
      Black, FontSize -> 9, FontFamily -> "Helvetica",
      Table[
        Module[{nc, d},
          nc = Mean[{tiles[[nbr]]["vertices"][[1]], 
                      tiles[[nbr]]["vertices"][[3]]}];
          d = nbrDirs[nbr];
          Text[
            Switch[d, 0, "SE", 2, "SW", 4, "NW", 6, "NE", _, ToString[d]],
            nc
          ]
        ],
        {nbr, neumann}
      ],
      
      (* Info label *)
      White, FontSize -> 10,
      Text[
        Column[{
          Style[Row[{"#", idx}], Bold],
          Row[{"nT=", nbrTypes[idx]}],
          Row[{tile["type"]}]
        }, Alignment -> Center],
        center
      ]
    },
    opts,
    AspectRatio -> Automatic,
    PlotRange -> plotRange,
    ImageSize -> 600,
    PlotLabel -> Style[
      Row[{"Tile #", idx, " | type=", tile["type"], 
           " | neighborType=", nbrTypes[idx],
           " | Moore=", Length[moore], 
           " | Neumann=", Length[neumann]}],
      FontSize -> 11, FontFamily -> "Helvetica"
    ]
    ]
  ];

(* ============================================================ *)
(*  Stage 3: Rule Engine                                         *)
(*  Two rule types:                                              *)
(*    "GCA"  — General CA: hash(center, countMoore) -> value     *)
(*    "Partitioned" — Partitioned CA: hash(center, NE,SE,SW,NW)  *)
(*             with rotational symmetry                          *)
(* ============================================================ *)

(*
  Rule data structure:
  <|
    "type"              -> "GCA" | "Partitioned",
    "transitionRules"   -> list of pattern->value rules,
    "rotational"        -> True | False,
    "undefinedDefault"   -> integer | "same",
    "defaultValue"      -> integer (initial cell state),
    "numStates"         -> integer,
    "compiledRules"     -> (internal, set by CreateCARule)
  |>
  
  GCA transition rule format:
    {centerState, count1, count2, ...} -> newState
    where countN = number of Moore neighbors with state N
    Use _ for wildcard.
    
  Partitioned transition rule format:
    {centerState, neState, seState, swState, nwState} -> newState
    (or {centerState, nwState, neState, seState, swState} 
     matching the iOS app convention)
    Use _ for wildcard.
    If rotational=True, each rule generates 4 rotated variants automatically.
*)

CreateCARule[spec_Association] := 
  Module[{rules, rotRules, type, rotational, numStates},
    type = Lookup[spec, "type", "GCA"];
    rotational = Lookup[spec, "rotational", False];
    rules = spec["transitionRules"];
    numStates = Lookup[spec, "numStates", 
      Max[Cases[rules, (lhs_ -> rhs_) :> rhs, Infinity]] + 1];
    
    (* If rotational, expand each rule into 4 rotated versions *)
    If[rotational && type === "Partitioned",
      rotRules = Flatten[expandRotational /@ rules, 1];
      ,
      rotRules = rules;
    ];
    
    Append[spec, 
      "compiledRules" -> rotRules
    ] // Append[#, "expandedRules" -> rotRules] &
  ];

(* Expand a partitioned rule into 4 rotations *)
(* Input: {c, ne, se, sw, nw} -> val *)
(* Rotations cycle the directional components *)
expandRotational[rule : (lhs_List -> rhs_)] := 
  Module[{c, dirs, rotated},
    c = lhs[[1]];
    dirs = lhs[[2 ;;]];
    Table[
      Prepend[RotateLeft[dirs, k], c] -> rhs,
      {k, 0, Length[dirs] - 1}
    ] // DeleteDuplicates
  ];

(* Apply the first matching rule from a list of rules to a key.       *)
(* Each rule is  pattern_List -> value.                                *)
(* Pattern elements: integer = exact match, _ (Blank) = wildcard.     *)
(* Returns value of first matching rule, or default if none matches.  *)
applyFirstRule[key_List, rules_List, default_] := 
  Module[{result = default, i = 1, n = Length[rules], r},
    While[i <= n,
      r = rules[[i]];
      If[MatchQ[key, r[[1]]],
        result = r[[2]];
        i = n + 1;  (* break *)
        ,
        i++
      ];
    ];
    result
  ];

(* ============================================================ *)
(*  GCA step: General Cellular Automaton                         *)
(*  neighborhood: "Moore" (default) or "Neumann"                 *)
(* ============================================================ *)

gcaStep[graph_, rule_, state_] := 
  Module[{neighbors, nTiles, numStates, newState, 
          center, counts, key, undef, ruleList, nbrType},
    nbrType = Lookup[rule, "neighborhood", "Moore"];
    neighbors = If[nbrType === "Neumann", 
      graph["neumannNeighbors"], 
      graph["mooreNeighbors"]
    ];
    nTiles = Length[graph["tiles"]];
    numStates = rule["numStates"];
    undef = rule["undefinedDefault"];
    ruleList = rule["compiledRules"];
    
    newState = Table[
      center = state[[i]];
      counts = Table[0, {numStates}];
      Do[counts[[state[[nbr]] + 1]] += 1, {nbr, neighbors[i]}];
      key = Prepend[counts[[2 ;;]], center];
      applyFirstRule[key, ruleList, If[undef === "same", center, undef]],
      {i, 1, nTiles}
    ];
    newState
  ];

(* ============================================================ *)
(*  Partitioned CA step                                          *)
(*  Each cell reads its 4 Neumann neighbors' states              *)
(*  Direction mapping: NE=6, SE=0, SW=2, NW=4                   *)
(* ============================================================ *)

partitionedStep[graph_, rule_, state_] := 
  Module[{neumann, neumannDirs, nTiles, newState,
          center, ne, se, sw, nw, key, undef, ruleList,
          nbrs, dirs, nbrState, dir},
    neumann = graph["neumannNeighbors"];
    neumannDirs = graph["neumannDirections"];
    nTiles = Length[graph["tiles"]];
    undef = rule["undefinedDefault"];
    ruleList = rule["compiledRules"];
    
    newState = Table[
      center = state[[i]];
      ne = 0; se = 0; sw = 0; nw = 0;
      nbrs = neumann[i];
      dirs = neumannDirs[i];
      Do[
        dir = dirs[nbr];
        nbrState = state[[nbr]];
        Switch[dir, 6, ne = nbrState, 0, se = nbrState,
                    2, sw = nbrState, 4, nw = nbrState];
        , {nbr, nbrs}
      ];
      key = {center, nw, ne, se, sw};
      applyFirstRule[key, ruleList, If[undef === "same", center, undef]],
      {i, 1, nTiles}
    ];
    newState
  ];

(* ============================================================ *)
(*  Unified step function                                        *)
(* ============================================================ *)

CAStep[graph_Association, rule_Association, state_List] := 
  Switch[rule["type"],
    "GCA", gcaStep[graph, rule, state],
    "Partitioned", partitionedStep[graph, rule, state],
    _, gcaStep[graph, rule, state]
  ];

CAEvolve[graph_Association, rule_Association, initState_List, steps_Integer] := 
  NestList[CAStep[graph, rule, #] &, initState, steps];

(* ============================================================ *)
(*  True 5-Neighborhood Partitioned CA (PCA5)                    *)
(*  Thesis Definition 2.3, Figures 2.5-2.8                       *)
(*                                                               *)
(*  Cell state = {c, d1, d2, d3, d4}                             *)
(*    c  = center part                                           *)
(*    di = directional part (one per Neumann neighbor)           *)
(*                                                               *)
(*  For square grid: {c, N, E, S, W} = indices {1,2,3,4,5}      *)
(*  Graph directions: E=0, S=2, W=4, N=6                        *)
(*  Dir-to-slot: 6->2, 0->3, 2->4, 4->5 (1-based)              *)
(*  Facing: N(6)->S-part(4), E(0)->W-part(5),                    *)
(*          S(2)->N-part(2), W(4)->E-part(3)                     *)
(*                                                               *)
(*  Input construction for cell X:                               *)
(*    input[[1]] = X's center part                               *)
(*    input[[k]] = neighbor_in_dir_d's state[[facingSlot[d]]]    *)
(*  where k = dirToSlot[d]                                       *)
(*                                                               *)
(*  Rotational symmetry (Def 2.4):                               *)
(*    f(c,u,r,d,l)=(c',u',r',d',l')                             *)
(*    => f(c,r,d,l,u)=(c',r',d',l',u')                          *)
(* ============================================================ *)

(* Direction-to-slot mapping: graph direction -> 1-based part index *)
(* Slot 1=center, 2..5=directional parts *)
dirToSlot[d_] := Switch[d, 6, 2, 0, 3, 2, 4, 4, 5, _, 0];

(* Facing slot: which part of neighbor in direction d faces us *)
(* = slot of the opposite direction *)
facingSlot[d_] := dirToSlot[Mod[d + 4, 8]];

(* Expand PCA5 rule with rotational symmetry *)
(* Both input AND output directional parts rotate cyclically *)
expandRotationalPCA[lhs_List -> rhs_List] := 
  Module[{cIn, dirsIn, cOut, dirsOut},
    cIn = lhs[[1]]; dirsIn = lhs[[2 ;;]];
    cOut = rhs[[1]]; dirsOut = rhs[[2 ;;]];
    DeleteDuplicates[
      Table[
        Prepend[RotateLeft[dirsIn, k], cIn] -> 
          Prepend[RotateLeft[dirsOut, k], cOut],
        {k, 0, 3}
      ]
    ]
  ];

CreatePCA5Rule[spec_Association] := 
  Module[{rules, rotRules, rotational},
    rotational = Lookup[spec, "rotational", False];
    rules = spec["transitionRules"];
    
    If[rotational,
      rotRules = Flatten[expandRotationalPCA /@ rules, 1],
      rotRules = rules
    ];
    
    Join[spec, <|
      "compiledRules" -> rotRules,
      "expandedRules" -> rotRules,
      "type" -> "PCA5"
    |>]
  ];

(* PCA5 step function - edge-based with swap awareness *)
pca5Step[graph_, rule_, state_] := 
  Module[{neumann, nTiles, newState, ruleList, 
          inp, quiescent, pmap, slots},
    neumann = graph["neumannNeighbors"];
    nTiles = Length[graph["tiles"]];
    ruleList = rule["compiledRules"];
    quiescent = ConstantArray[0, 5];
    pmap = graph["pca5Map"];
    
    newState = Table[
      inp = ConstantArray[0, 5];
      inp[[1]] = state[[i, 1]];
      Do[
        slots = pmap[i][nbr];
        inp[[slots[[1]]]] = state[[nbr, slots[[2]]]];
        , {nbr, neumann[i]}
      ];
      applyFirstRule[inp, ruleList, quiescent],
      {i, 1, nTiles}
    ];
    newState
  ];

(* ============================================================ *)
(*  Edge-based PCA5 map with vertex-swap awareness               *)
(*  computeVertices swaps {v0,v1,v2,v3} -> {v2,v3,v0,v1}        *)
(*  when Mod[Total[k]+1, 5] == 2 (matching iOS setCellFromCellLabel). *)
(*  After swap fix, edgeToSlot = edge+1 for all RPT tiles.       *)
(* ============================================================ *)

isTileSwapped[tile_Association] := 
  If[KeyExistsQ[tile, "swapped"],
    tile["swapped"],
    Module[{label = tile["label"]},
      If[Length[label] >= 7,
        Mod[Total[label[[1 ;; 5]]] + 1, 5] == 2,
        False
      ]
    ]
  ];

(* Convert geometric edge index (1-4) to PCA5 computation slot (2-5) *)
(* Square grid vertices: {(c,r),(c+1,r),(c+1,r+1),(c,r+1)} *)
(*   edge 1=S, edge 2=E, edge 3=N, edge 4=W *)
(*   Computation: slot2=N, slot3=E, slot4=S, slot5=W *)
(*   So: edge1(S)->slot4, edge2(E)->slot3, edge3(N)->slot2, edge4(W)->slot5 *)
(* RPT/KD: edge+1 is correct *)
squareEdgeToSlot = {4, 3, 2, 5};

edgeToComputeSlot[edgeIdx_Integer, isSquare_] := 
  If[TrueQ[isSquare], squareEdgeToSlot[[edgeIdx]], edgeIdx + 1];

(* Build PCA5 map using edge matching — find both edge indices *)
buildPCA5MapEdge[graph_Association] := 
  Module[{tiles, neumann, nTiles, pmap, isSquare},
    tiles = graph["tiles"];
    neumann = graph["neumannNeighbors"];
    nTiles = Length[tiles];
    isSquare = (tiles[[1]]["type"] === "Square" && Length[tiles[[1]]["label"]] <= 2);
    pmap = Association[];
    Do[
      pmap[i] = Association[];
      Do[
        Module[{myVkeys, nbrVkeys, myEdge = -1, nbrEdge = -1, 
                mySlot, nbrSlot},
          myVkeys = tiles[[i]]["vertexKeys"];
          nbrVkeys = tiles[[nbr]]["vertexKeys"];
          (* Find which edge of tile i faces tile nbr *)
          Do[
            Module[{ek1 = myVkeys[[ej]], ek2 = myVkeys[[Mod[ej, 4] + 1]]},
              If[MemberQ[nbrVkeys, ek1] && MemberQ[nbrVkeys, ek2],
                myEdge = ej
              ];
            ];
            , {ej, 1, 4}
          ];
          (* Find which edge of tile nbr faces tile i *)
          Do[
            Module[{ek1 = nbrVkeys[[ej]], ek2 = nbrVkeys[[Mod[ej, 4] + 1]]},
              If[MemberQ[myVkeys, ek1] && MemberQ[myVkeys, ek2],
                nbrEdge = ej
              ];
            ];
            , {ej, 1, 4}
          ];
          If[myEdge > 0 && nbrEdge > 0,
            mySlot = edgeToComputeSlot[myEdge, isSquare];
            nbrSlot = edgeToComputeSlot[nbrEdge, isSquare];
            pmap[i][nbr] = {mySlot, nbrSlot}
          ];
        ];
        , {nbr, neumann[i]}
      ];
      , {i, 1, nTiles}
    ];
    pmap
  ];

(* Auto-detect and build pca5Map *)
ensureFacingMap[graph_Association] := 
  Module[{},
    If[KeyExistsQ[graph, "pca5Map"], Return[graph]];
    Append[graph, "pca5Map" -> buildPCA5MapEdge[graph]]
  ];

PCA5Step[graph_Association, rule_Association, state_List] := 
  Module[{g},
    g = ensureFacingMap[graph];
    pca5Step[g, rule, state]
  ];

PCA5Evolve[graph_Association, rule_Association, initState_List, steps_Integer] := 
  Module[{g},
    g = ensureFacingMap[graph];
    NestList[pca5Step[g, rule, #] &, initState, steps]
  ];

(* ============================================================ *)
(*  PCA5 Reversibility Check & Inverse Step                      *)
(* ============================================================ *)

(* Check if PCA5 rule is reversible: *)
(* A partitioned CA is reversible iff all RHS of defined transition *)
(* rules are distinct. Undefined inputs can always be assigned *)
(* outputs to maintain bijectivity, so only explicit rules matter. *)
IsReversiblePCA5[rule_Association] := 
  Module[{compiledRules, rhsList},
    If[Lookup[rule, "type", ""] =!= "PCA5", Return[False]];
    compiledRules = rule["compiledRules"];
    If[Length[compiledRules] == 0, Return[True]];
    rhsList = compiledRules[[All, 2]];
    Length[DeleteDuplicates[rhsList]] === Length[rhsList]
  ];

(* Create inverse PCA5 rule by swapping LHS<->RHS of defined rules. *)
(* Stored as Association for O(1) lookup. Undefined outputs map to quiescent. *)
InvertPCA5Rule[rule_Association] := 
  Module[{compiledRules, invAssoc},
    compiledRules = rule["compiledRules"];
    invAssoc = AssociationThread[
      compiledRules[[All, 2]], compiledRules[[All, 1]]];
    <|"invLookup" -> invAssoc, "type" -> "PCA5"|>
  ];

(* Inverse PCA5 step: apply inverse rule locally, then gather from neighbors *)
(* Forward = gather-then-transform; Inverse = transform-then-gather *)
pca5InverseStep[graph_, invRule_, state_] := 
  Module[{neumann, nTiles, temp, invLookup, quiescent, pmap, slots},
    neumann = graph["neumannNeighbors"];
    nTiles = Length[graph["tiles"]];
    invLookup = invRule["invLookup"];
    quiescent = ConstantArray[0, 5];
    pmap = graph["pca5Map"];
    
    (* Step 1: Apply inverse rule to each cell via Association lookup *)
    temp = Table[
      Lookup[invLookup, Key[state[[i]]], quiescent],
      {i, 1, nTiles}
    ];
    
    (* Step 2: Gather directional parts from neighbors *)
    Table[
      Module[{prev = ConstantArray[0, 5]},
        prev[[1]] = temp[[i, 1]];
        Do[
          slots = pmap[i][nbr];
          prev[[slots[[1]]]] = temp[[nbr, slots[[2]]]];
          , {nbr, neumann[i]}
        ];
        prev
      ],
      {i, 1, nTiles}
    ]
  ];

(* Drawing PCA5 state — all 5 parts visible simultaneously *)
(* Each square cell is divided into: center diamond + 4 trapezoidal direction parts *)
(* Layout:  N=top, E=right, S=bottom, W=left, c=center diamond *)

(* Display slot: which computation slot to paint at each geometric edge *)
(* Square grid: vertices = {(c,r),(c+1,r),(c+1,r+1),(c,r+1)} *)
(*   edge 1=South, edge 2=East, edge 3=North, edge 4=West *)
(*   Computation: slot2=N, slot3=E, slot4=S, slot5=W *)
(*   So: edge1(S)->slot4, edge2(E)->slot3, edge3(N)->slot2, edge4(W)->slot5 *)
(* RPT: edge+1 is correct *)
edgeToDisplaySlot[edgeIdx_Integer, swapped_, isRPT_] := 
  If[TrueQ[isRPT],
    edgeIdx + 1,
    {4, 3, 2, 5}[[edgeIdx]]  (* Square: S,E,N,W *)
  ];

(* Precompute 5-polygon decomposition *)
precomputePCA5Polygons[graph_Association] := 
  Module[{tiles, nTiles, f, tileType, isRPT},
    tiles = graph["tiles"];
    nTiles = Length[tiles];
    tileType = tiles[[1]]["type"];
    isRPT = (Length[tiles[[1]]["label"]] > 2);
    f = If[isRPT, 0.30, 0.33];
    Table[
      Module[{verts, ctr, ip, edgePolys, slotPolys, swapped},
        verts = tiles[[i]]["vertices"];
        ctr = Mean[verts];
        ip = Table[ctr + f (verts[[j]] - ctr), {j, 1, 4}];
        edgePolys = Table[
          {ip[[j]], verts[[j]], verts[[Mod[j, 4] + 1]], ip[[Mod[j, 4] + 1]]},
          {j, 1, 4}
        ];
        swapped = If[isRPT, isTileSwapped[tiles[[i]]], False];
        slotPolys = ConstantArray[{}, 5];
        slotPolys[[1]] = {ip[[1]], ip[[2]], ip[[3]], ip[[4]]};
        Do[slotPolys[[edgeToDisplaySlot[j, swapped, isRPT]]] = edgePolys[[j]], 
          {j, 1, 4}];
        slotPolys
      ],
      {i, 1, nTiles}
    ]
  ];


(* pca5Polys: 5-way decomposition for coloring *)
drawPCA5AllParts[pca5Polys_List, cellPolys_List, state_List, imageSize_Integer] := 
  Graphics[{
    (* 1. Fill the 5 parts with no edge *)
    EdgeForm[],
    Table[
      Module[{polys = pca5Polys[[i]], sv = state[[i]]},
        Table[
          {Lookup[defaultCAColorAssoc, sv[[p]], GrayLevel[0.5]],
           Polygon[polys[[p]]]},
          {p, 1, 5}
        ]
      ],
      {i, 1, Length[state]}
    ],
    (* 2. Partition lines (center diamond edges) — light, thin, blue-gray *)
    {RGBColor[0.6, 0.65, 0.75], AbsoluteThickness[0.3],
     Table[
       Line[Append[pca5Polys[[i, 1]], pca5Polys[[i, 1, 1]]]],
       {i, 1, Length[state]}
     ]
    },
    (* 3. Cell borders (de Bruijn grid) — darker, thicker, warm gray *)
    {RGBColor[0.35, 0.3, 0.25], AbsoluteThickness[0.7],
     Table[
       Line[Append[cellPolys[[i]], cellPolys[[i, 1]]]],
       {i, 1, Length[state]}
     ]
    }
  },
  AspectRatio -> Automatic,
  PlotRange -> All,
  ImageSize -> imageSize
  ];

DrawPCA5State[graph_Association, state_List, opts___] := 
  DrawPCA5State[graph, state, defaultCAColorAssoc, opts];

DrawPCA5State[graph_Association, state_List, colorAssoc_Association, opts___] := 
  Module[{pca5Polys, cellPolys, tiles, nTiles},
    tiles = graph["tiles"];
    nTiles = Length[tiles];
    pca5Polys = precomputePCA5Polygons[graph];
    cellPolys = Table[tiles[[i]]["vertices"], {i, nTiles}];
    Graphics[{
      EdgeForm[],
      Table[
        Module[{polys = pca5Polys[[i]], sv = state[[i]]},
          Table[
            {Lookup[colorAssoc, sv[[p]], GrayLevel[0.5]],
             Polygon[polys[[p]]]},
            {p, 1, 5}
          ]
        ],
        {i, 1, nTiles}
      ],
      {RGBColor[0.6, 0.65, 0.75], AbsoluteThickness[0.3],
       Table[Line[Append[pca5Polys[[i, 1]], pca5Polys[[i, 1, 1]]]],
         {i, 1, nTiles}]},
      {RGBColor[0.35, 0.3, 0.25], AbsoluteThickness[0.7],
       Table[Line[Append[cellPolys[[i]], cellPolys[[i, 1]]]],
         {i, 1, nTiles}]}
    },
    AspectRatio -> Automatic, PlotRange -> All, ImageSize -> 800
    ]
  ];

(* PCA5 Simulator with full 5-part visualization *)
(* 2-arg: PCA5Simulator[graph, rule] — empty state *)
(* 3-arg: PCA5Simulator[graph, rule, initState] *)
(* 4-arg: PCA5Simulator[graph, rule, initState, colorAssoc] *)
(* 5-arg: PCA5Simulator[graph, rule, initState, colorAssoc, configName] *)
(*   configName: base name for export folder (e.g. "sr8RPT130214003305") *)
(*   Save PNGs creates <NotebookDirectory>/<configName>_images/ *)
PCA5Simulator[graph_Association, rule_Association] := 
  PCA5Simulator[graph, rule, Automatic, defaultCAColorAssoc, ""];

PCA5Simulator[graph_Association, rule_Association, initState_] := 
  PCA5Simulator[graph, rule, initState, defaultCAColorAssoc, ""];

PCA5Simulator[graph_Association, rule_Association, initState_, colorAssoc_Association] := 
  PCA5Simulator[graph, rule, initState, colorAssoc, ""];

PCA5Simulator[graph_Association, rule_Association, initState_, 
    colorAssoc_Association, configName_String] := 
  Module[{g, tiles, centers, spatialCenter, centerIdx,
          pca5Polys, cellPolys, nTiles, compiledRule,
          initSt, interiorIdx, clipRange, cfgName},
    g = ensureFacingMap[graph];
    tiles = g["tiles"];
    nTiles = Length[tiles];
    pca5Polys = precomputePCA5Polygons[g];
    cellPolys = Table[tiles[[k]]["vertices"], {k, nTiles}];
    centers = Table[Mean[tiles[[i]]["vertices"]], {i, nTiles}];
    spatialCenter = Mean[centers];
    centerIdx = First[Ordering[Norm[# - spatialCenter] & /@ centers, 1]];
    interiorIdx = computeInteriorIndices[g];
    clipRange = computeClipRange[tiles, interiorIdx];
    cfgName = If[configName =!= "", configName, "PCA5_export"];
    
    initSt = If[initState === Automatic || initState === None,
      Table[{0, 0, 0, 0, 0}, nTiles], initState];
    
    With[{
      storedGraph = g, storedRule = rule,
      storedPolys = pca5Polys, storedCellPolys = cellPolys,
      storedN = nTiles, storedCenter = centerIdx,
      storedInit = initSt, storedColors = colorAssoc,
      storedInterior = interiorIdx, storedClipRange = clipRange,
      storedCfgName = cfgName
    },
      DynamicModule[{state = storedInit, step = 0, 
                     exportN = 50, exportStatus = ""},
        Column[{
          Row[{
            Button["Step", 
              state = pca5Step[storedGraph, storedRule, state]; step++,
              Method -> "Queued"],
            Spacer[5],
            Button["x10", 
              Do[state = pca5Step[storedGraph, storedRule, state]; step++, {10}],
              Method -> "Queued"],
            Spacer[5],
            Button["x50", 
              Do[state = pca5Step[storedGraph, storedRule, state]; step++, {50}],
              Method -> "Queued"],
            Spacer[15],
            Button["Reset", state = storedInit; step = 0],
            Spacer[5],
            Button["Center Seed",
              state = Table[{0, 0, 0, 0, 0}, storedN];
              state[[storedCenter]] = {0, 1, 1, 1, 1}; step = 0],
            Spacer[5],
            Button["Clear", 
              state = Table[{0, 0, 0, 0, 0}, storedN]; step = 0]
          }],
          Row[{
            "Steps:", Spacer[3],
            InputField[Dynamic[exportN], Number, FieldSize -> 4],
            Spacer[10],
            Button["Save PNG",
              Module[{dir, cs, img, fname},
                dir = caExportDir[storedCfgName, "_images"];
                If[!DirectoryQ[dir], CreateDirectory[dir]];
                exportStatus = "Exporting PNG..."; cs = state;
                Do[
                  img = renderPCA5Clipped[storedPolys, storedCellPolys, cs,
                    storedColors, storedInterior, storedClipRange, 1200];
                  fname = FileNameJoin[{dir,
                    StringPadLeft[ToString[t], 3, "0"] <> ".png"}];
                  Export[fname, img, "PNG"];
                  If[t < exportN, cs = pca5Step[storedGraph, storedRule, cs]];
                  , {t, 0, exportN}];
                exportStatus = ToString[exportN+1] <> " PNGs -> " <> dir;
              ], Method -> "Queued"],
            Spacer[5],
            Button["Save PDF",
              Module[{cs, frames, fname},
                exportStatus = "Rendering PDF..."; cs = state;
                frames = Table[
                  Module[{img},
                    img = renderPCA5Clipped[storedPolys, storedCellPolys, cs,
                      storedColors, storedInterior, storedClipRange, 1200];
                    If[t < exportN, cs = pca5Step[storedGraph, storedRule, cs]];
                    img],
                  {t, 0, exportN}];
                fname = caExportFile[storedCfgName, ".pdf"];
                Export[fname, frames, "PDF"];
                exportStatus = "PDF -> " <> fname;
              ], Method -> "Queued"],
            Spacer[5],
            Button["Save MP4",
              Module[{cs, frames, fname},
                exportStatus = "Rendering frames..."; cs = state;
                frames = Table[
                  Module[{img},
                    img = renderPCA5Clipped[storedPolys, storedCellPolys, cs,
                      storedColors, storedInterior, storedClipRange, 900];
                    If[t < exportN, cs = pca5Step[storedGraph, storedRule, cs]];
                    img],
                  {t, 0, exportN}];
                fname = caExportFile[storedCfgName, ".mp4"];
                exportStatus = "Encoding MP4...";
                Export[fname, frames, "MP4", "FrameRate" -> 4];
                exportStatus = "MP4 -> " <> fname;
              ], Method -> "Queued"]
          }],
          Dynamic[Style[Row[{"Step: ", step, "  Tiles: ", storedN, 
            "  Interior: ", Length[storedInterior],
            If[exportStatus =!= "", "  " <> exportStatus, ""]}], FontSize -> 11]],
          Dynamic[
            renderPCA5Clipped[storedPolys, storedCellPolys, state,
              storedColors, storedInterior, storedClipRange, 900]
          ]
        }, Spacings -> 0.5]
      ]
    ]
  ];

(* Compute indices of interior tiles — 2 layers inward from boundary *)
(* A tile is "interior" if ALL of its Moore neighbors also have 4 Neumann neighbors. *)
(* This ensures no partially-drawn tiles appear at edges. *)
computeInteriorIndices[graph_Association] := 
  Module[{neumann, moore, nTiles, layer1, layer1Set, result = {}},
    neumann = graph["neumannNeighbors"];
    moore = graph["mooreNeighbors"];
    nTiles = Length[graph["tiles"]];
    (* Layer 1: tiles with all 4 Neumann neighbors *)
    layer1 = Select[Range[nTiles], Length[neumann[#]] >= 4 &];
    layer1Set = Association[# -> True & /@ layer1];
    (* Layer 2: tiles in layer1 whose Moore neighbors are ALL in layer1 *)
    Do[
      If[AllTrue[moore[i], KeyExistsQ[layer1Set, #] &],
        AppendTo[result, i]],
      {i, layer1}
    ];
    result
  ];

(* Compute clipping PlotRange from interior tile vertices *)
computeClipRange[tiles_List, interiorIdx_List] := 
  Module[{allVerts, xs, ys, margin = 0.05},
    If[Length[interiorIdx] == 0, Return[All]];
    allVerts = Flatten[tiles[[#]]["vertices"] & /@ interiorIdx, 1];
    xs = allVerts[[All, 1]];
    ys = allVerts[[All, 2]];
    {{Min[xs] - margin, Max[xs] + margin}, 
     {Min[ys] - margin, Max[ys] + margin}}
  ];

(* Render PCA5 state — draw ALL tiles, clip by PlotRange *)
renderPCA5Clipped[pca5Polys_List, cellPolys_List, state_List,
    colorAssoc_Association, interiorIdx_List, clipRange_, imageSize_] := 
  Module[{nTiles = Length[state]},
    Graphics[{
      (* 1. Fill the 5 parts with no edge *)
      EdgeForm[],
      Table[
        Module[{polys = pca5Polys[[i]], sv = state[[i]]},
          Table[
            {Lookup[colorAssoc, sv[[p]], GrayLevel[0.5]],
             Polygon[polys[[p]]]},
            {p, 1, 5}
          ]
        ],
        {i, 1, nTiles}
      ],
      (* 2. Partition lines: center diamond edges + radial dividers *)
      {RGBColor[0.6, 0.65, 0.75], AbsoluteThickness[0.3],
       Table[
         Module[{ip = pca5Polys[[i, 1]], cv = cellPolys[[i]]},
           {Line[Append[ip, ip[[1]]]],
            Table[Line[{ip[[j]], cv[[j]]}], {j, 1, 4}]}
         ],
         {i, 1, nTiles}
       ]},
      (* 3. Cell borders *)
      {RGBColor[0.35, 0.3, 0.25], AbsoluteThickness[0.7],
       Table[Line[Append[cellPolys[[i]], cellPolys[[i, 1]]]],
         {i, 1, nTiles}]}
    },
    AspectRatio -> Automatic, PlotRange -> clipRange, 
    PlotRangePadding -> 0, ImageSize -> imageSize
    ]
  ];

(* Standalone export function *)
ExportPCA5Steps[graph_Association, rule_Association, initState_List, 
    nSteps_Integer, directory_String] := 
  ExportPCA5Steps[graph, rule, initState, nSteps, directory, defaultCAColorAssoc];

ExportPCA5Steps[graph_Association, rule_Association, initState_List, 
    nSteps_Integer, directory_String, colorAssoc_Association] := 
  Module[{g, tiles, nTiles, pca5Polys, cellPolys, interiorIdx, clipRange,
          state, img, fname},
    g = ensureFacingMap[graph];
    tiles = g["tiles"];
    nTiles = Length[tiles];
    pca5Polys = precomputePCA5Polygons[g];
    cellPolys = Table[tiles[[k]]["vertices"], {k, nTiles}];
    interiorIdx = computeInteriorIndices[g];
    clipRange = computeClipRange[tiles, interiorIdx];
    
    If[!DirectoryQ[directory], CreateDirectory[directory]];
    
    state = initState;
    Do[
      img = renderPCA5Clipped[pca5Polys, cellPolys, state, 
        colorAssoc, interiorIdx, clipRange, 1200];
      fname = FileNameJoin[{directory, 
        StringPadLeft[ToString[t], 3, "0"] <> ".png"}];
      Export[fname, img, "PNG"];
      If[t < nSteps,
        state = pca5Step[g, rule, state]];
      , {t, 0, nSteps}
    ];
    Print["Exported ", nSteps + 1, " images to ", directory];
    directory
  ];

(* Fallback: show error if arguments dont match *)
PCA5Simulator[args___] := 
  Module[{argTypes},
    argTypes = Head /@ {args};
    Print["PCA5Simulator: argument type mismatch."];
    Print["  Expected: PCA5Simulator[graph_Association, rule_Association, ...]"];
    Print["  Got types: ", argTypes];
    $Failed
  ];

(* ============================================================ *)
(*  Unified File-Based CASimulator                               *)
(*  CASimulator[cafile] or CASimulator[cafile, conffile]          *)
(*  Auto-detects: geometry, rule type, tiling, colors             *)
(*  Supports: Load Rule, Load Conf buttons for hot-reload         *)
(* ============================================================ *)

(* Compute de Bruijn grid lines for overlay display *)
(* Returns a list of Line primitives clipped to the given plotRange *)
computeDeBruijnGridLines[meta_Association, clipRange_] := 
  Module[{geom, symOrder, numGrids, off, cr, 
          eV, xmin, xmax, ymin, ymax, lines = {},
          ci, si, kMin, kMax, corners, vals,
          t0, t1, tClip, px, py, dx, dy, c},
    geom = meta["geometryType"];
    (* Square grid has no de Bruijn grid *)
    If[StringContainsQ[geom, "Square" | "square"], Return[{}]];
    
    (* Determine symmetry order *)
    symOrder = Which[
      StringContainsQ[geom, "ABT" | "Ammann" | "Beenker", IgnoreCase -> True], 8,
      StringMatchQ[geom, "MG" ~~ DigitCharacter ..],
        ToExpression[StringDrop[geom, 2]],
      StringContainsQ[geom, "Rhomb" | "RPT" | "Kite" | "KD", IgnoreCase -> True], 5,
      True, Return[{}]
    ];
    
    numGrids = mgNumGrids[symOrder];
    off = meta["offsetValues"];
    cr = meta["cellRange"];
    
    (* Use clipRange for plotting bounds *)
    {{xmin, xmax}, {ymin, ymax}} = clipRange;
    corners = {{xmin, ymin}, {xmax, ymin}, {xmax, ymax}, {xmin, ymax}};
    eV = mgEVec[symOrder];
    
    Do[
      ci = eV[[i + 1, 1]]; si = eV[[i + 1, 2]];
      (* Determine index range of grid lines visible in the clip region *)
      vals = (ci #[[1]] + si #[[2]]) & /@ corners;
      kMin = Floor[Min[vals] - off[[i + 1]]] - 1;
      kMax = Ceiling[Max[vals] - off[[i + 1]]] + 1;
      
      (* Direction along the line: perpendicular to (ci, si) *)
      dx = -si; dy = ci;
      
      Do[
        c = k + off[[i + 1]];  (* the constant: ci*x + si*y = c *)
        (* A point on the line: p = c * {ci, si} *)
        px = c * ci; py = c * si;
        (* Clip line segment to bounding box *)
        (* Parameterize: (px + t*dx, py + t*dy) *)
        (* Find t range where point is inside [xmin,xmax] x [ymin,ymax] *)
        t0 = -1000.; t1 = 1000.;
        If[Abs[dx] > 1.*^-10,
          Module[{ta = (xmin - px)/dx, tb = (xmax - px)/dx},
            t0 = Max[t0, Min[ta, tb]]; t1 = Min[t1, Max[ta, tb]]],
          If[px < xmin || px > xmax, t0 = 1.; t1 = 0.]  (* no intersection *)
        ];
        If[Abs[dy] > 1.*^-10,
          Module[{ta = (ymin - py)/dy, tb = (ymax - py)/dy},
            t0 = Max[t0, Min[ta, tb]]; t1 = Min[t1, Max[ta, tb]]],
          If[py < ymin || py > ymax, t0 = 1.; t1 = 0.]
        ];
        If[t0 < t1,
          AppendTo[lines, 
            Line[{{px + t0 dx, py + t0 dy}, {px + t1 dx, py + t1 dy}}]]
        ];
        , {k, kMin, kMax}
      ];
      , {i, 0, numGrids - 1}
    ];
    lines
  ];

(* Build tiling and graph from metadata *)
buildTilingAndGraph[meta_Association] := 
  Module[{geom, cr, off, tiles, graph, cols, rows},
    geom = meta["geometryType"];
    cr = meta["cellRange"];
    off = meta["offsetValues"];
    
    Which[
      StringContainsQ[geom, "ABT" | "Ammann" | "Beenker", IgnoreCase -> True],
        tiles = GenerateMultigridRhombs[8, cr, off];
        graph = BuildTilingGraph[tiles],
      StringMatchQ[geom, "MG" ~~ DigitCharacter ..],
        Module[{n = ToExpression[StringDrop[geom, 2]]},
          tiles = GenerateMultigridRhombs[n, cr, off];
          graph = BuildTilingGraph[tiles]],
      StringContainsQ[geom, "Rhomb" | "RPT", IgnoreCase -> True],
        tiles = GeneratePenroseRhombs[cr, off];
        graph = BuildTilingGraph[tiles],
      StringContainsQ[geom, "Kite" | "KD", IgnoreCase -> True],
        tiles = GeneratePenroseKD[cr, off];
        graph = BuildKDTilingGraph[tiles],
      True,  (* Square / default *)
        cols = cr[[3]]; rows = cr[[4]];
        tiles = GenerateSquareGrid[cols, rows, cr[[1]], cr[[2]]];
        graph = BuildSquareGridGraph[tiles, cols, rows, cr[[1]], cr[[2]]]
    ];
    {tiles, graph}
  ];

(* Initialize all simulator data into a symbol-based store *)
initSimData[sym_, cafile_String, conffile_String] := 
  Module[{data, rule, meta, tiles, graph, nTiles, isPCA5,
          pca5Polys, cellPolys, interiorIdx, clipRange, colors,
          initState, centers, spatialCenter},
    
    data = LoadiOSRuleFile[cafile];
    rule = data["rule"];
    meta = data["metadata"];
    
    (* Build tiling *)
    {tiles, graph} = buildTilingAndGraph[meta];
    nTiles = Length[tiles];
    isPCA5 = (meta["ruleType"] === "PCA5");
    
    (* Ensure facing map for PCA5 *)
    If[isPCA5, graph = ensureFacingMap[graph]];
    
    (* Precompute polygons *)
    pca5Polys = If[isPCA5, precomputePCA5Polygons[graph], {}];
    cellPolys = Table[tiles[[k]]["vertices"], {k, nTiles}];
    interiorIdx = computeInteriorIndices[graph];
    clipRange = computeClipRange[tiles, interiorIdx];
    
    (* Colors *)
    colors = If[Length[meta["stateColors"]] > 0,
      Join[defaultCAColorAssoc, meta["stateColors"]],
      defaultCAColorAssoc];
    
    (* Initial state *)
    initState = If[conffile =!= "" && FileExistsQ[conffile],
      LoadiOSConfigFile[conffile, graph],
      If[isPCA5,
        Table[{0, 0, 0, 0, 0}, nTiles],
        ConstantArray[0, nTiles]
      ]
    ];
    
    (* Center tile *)
    centers = Table[Mean[tiles[[i]]["vertices"]], {i, nTiles}];
    spatialCenter = Mean[centers];
    
    (* Store *)
    sym["rule"] = rule;
    sym["meta"] = meta;
    sym["graph"] = graph;
    sym["isPCA5"] = isPCA5;
    sym["nTiles"] = nTiles;
    sym["pca5Polys"] = pca5Polys;
    sym["cellPolys"] = cellPolys;
    sym["interiorIdx"] = interiorIdx;
    sym["clipRange"] = clipRange;
    sym["colors"] = colors;
    sym["initState"] = initState;
    sym["centerIdx"] = First[Ordering[Norm[# - spatialCenter] & /@ centers, 1]];
    sym["ruleFile"] = cafile;
    sym["confFile"] = conffile;
    sym["configName"] = FileBaseName[If[conffile =!= "", conffile, cafile]];
  ];

(* Step function dispatching *)
simStep[sym_, state_] := 
  If[TrueQ[sym["isPCA5"]],
    pca5Step[sym["graph"], sym["rule"], state],
    CAStep[sym["graph"], sym["rule"], state]
  ];

(* Render scalar CA — draw ALL tiles, clip by PlotRange *)
renderCAClipped[cellPolys_List, state_List,
    colorAssoc_Association, interiorIdx_List, clipRange_, imageSize_] := 
  Graphics[{
    EdgeForm[{GrayLevel[0.4], AbsoluteThickness[0.3]}],
    Table[
      {Lookup[colorAssoc, state[[i]], GrayLevel[0.5]],
       Polygon[cellPolys[[i]]]},
      {i, 1, Length[state]}
    ]},
    AspectRatio -> Automatic, PlotRange -> clipRange, 
    PlotRangePadding -> 0, ImageSize -> imageSize
  ];

(* Unified render dispatching *)
simRender[sym_, state_, imageSize_:900] := 
  If[TrueQ[sym["isPCA5"]],
    renderPCA5Clipped[sym["pca5Polys"], sym["cellPolys"], state,
      sym["colors"], sym["interiorIdx"], sym["clipRange"], imageSize],
    renderCAClipped[sym["cellPolys"], state,
      sym["colors"], sym["interiorIdx"], sym["clipRange"], imageSize]
  ];

(* Default/zero state *)
simDefaultState[sym_] := 
  If[TrueQ[sym["isPCA5"]],
    Table[{0, 0, 0, 0, 0}, sym["nTiles"]],
    ConstantArray[0, sym["nTiles"]]
  ];

(* Center seed state *)
simCenterSeed[sym_] := 
  Module[{state = simDefaultState[sym]},
    state[[sym["centerIdx"]]] = 
      If[TrueQ[sym["isPCA5"]], {0, 1, 1, 1, 1}, 1];
    state
  ];

(* --- File-based CASimulator helpers --- *)

(* Export directory: NotebookDirectory[]/cfgLabel<suffix>/ *)
caExportDir[cfgLabel_String, suffix_String] := 
  Quiet[Check[
    FileNameJoin[{NotebookDirectory[], cfgLabel <> suffix}],
    FileNameJoin[{$TemporaryDirectory, cfgLabel <> suffix}]
  ]];

(* Export single file: NotebookDirectory[]/cfgLabel<ext> *)
caExportFile[cfgLabel_String, ext_String] := 
  Quiet[Check[
    FileNameJoin[{NotebookDirectory[], cfgLabel <> ext}],
    FileNameJoin[{$TemporaryDirectory, cfgLabel <> ext}]
  ]];

(* One render frame *)
caRenderFrame[isPCA5_, pca5Polys_, cellPolys_, state_, 
    colors_, interiorIdx_, clipRange_, imageSize_] := 
  If[TrueQ[isPCA5],
    renderPCA5Clipped[pca5Polys, cellPolys, state,
      colors, interiorIdx, clipRange, imageSize],
    renderCAClipped[cellPolys, state,
      colors, interiorIdx, clipRange, imageSize]
  ];

(* One step *)
caStepOnce[isPCA5_, graph_, rule_, state_] := 
  If[TrueQ[isPCA5], pca5Step[graph, rule, state], CAStep[graph, rule, state]];

(* --- File-based CASimulator --- *)
(* Resolve rule/config filename: if not a full path, look in package rules dir *)
resolveRulesPath[name_String] := 
  If[name === "" || FileExistsQ[name], name,
    Module[{full},
      full = FileNameJoin[{$caPackageDir, "CellularAutomata_info", "rules", name}];
      If[FileExistsQ[full], full, name]
    ]
  ];

CASimulator[cafile_String] := CASimulator[cafile, ""];

CASimulator[cafile_String, conffile_String] := 
  Module[{data, rule, meta, tiles, graph, nTiles, isPCA5,
          pca5Polys, cellPolys, interiorIdx, clipRange, colors,
          initState, centers, spatialCenter, centerIdx, cfgName,
          isRev, invRuleObj, histSym,
          cafileFull, conffileFull},
    
    cafileFull = resolveRulesPath[cafile];
    conffileFull = resolveRulesPath[conffile];
    
    data = LoadiOSRuleFile[cafileFull];
    rule = data["rule"];
    meta = data["metadata"];
    {tiles, graph} = buildTilingAndGraph[meta];
    nTiles = Length[tiles];
    isPCA5 = (meta["ruleType"] === "PCA5");
    If[isPCA5, graph = ensureFacingMap[graph]];
    
    pca5Polys = If[isPCA5, precomputePCA5Polygons[graph], {}];
    cellPolys = Table[tiles[[k]]["vertices"], {k, nTiles}];
    interiorIdx = computeInteriorIndices[graph];
    clipRange = computeClipRange[tiles, interiorIdx];
    colors = If[Length[meta["stateColors"]] > 0,
      Join[defaultCAColorAssoc, meta["stateColors"]], defaultCAColorAssoc];
    
    initState = If[conffileFull =!= "" && FileExistsQ[conffileFull],
      LoadiOSConfigFile[conffileFull, graph],
      If[isPCA5, Table[{0,0,0,0,0}, nTiles], ConstantArray[0, nTiles]]];
    
    centers = Table[Mean[tiles[[i]]["vertices"]], {i, nTiles}];
    spatialCenter = Mean[centers];
    centerIdx = First[Ordering[Norm[# - spatialCenter] & /@ centers, 1]];
    cfgName = FileBaseName[If[conffileFull =!= "", conffileFull, cafileFull]];
    
    (* Reversibility check *)
    isRev = TrueQ[isPCA5 && IsReversiblePCA5[rule]];
    invRuleObj = If[isRev, InvertPCA5Rule[rule], None];
    
    (* History ring buffer on kernel side (not in DynamicModule/FE) *)
    (* Each slot stored as histSym[slotIndex] — avoids Part assignment issue *)
    histSym = Unique["caHist$"];
    histSym[1] = initState;
    histSym["min"] = 0;
    histSym["max"] = 0;
    
    With[{
      sGraph = graph, sRule = rule, sMeta = meta, sIsPCA5 = isPCA5,
      sN = nTiles, sPolys = pca5Polys, sCellPolys = cellPolys,
      sInterior = interiorIdx, sClipRange = clipRange, sColors = colors,
      sInit = initState, sCenter = centerIdx, sCfgName = cfgName,
      sRuleFile = cafileFull, sConfFile = conffileFull,
      sRulesDir = FileNameJoin[{$caPackageDir, "CellularAutomata_info", "rules"}],
      sGridLines = computeDeBruijnGridLines[meta, clipRange],
      sCenters = centers,
      sNearestFunc = Nearest[centers -> "Index"],
      sStateKeys = Sort[Keys[colors]],
      sIsReversible = isRev,
      sInvRule = invRuleObj,
      sBufSize = $CAHistorySize,
      sHist = histSym
    },
      DynamicModule[{state = sInit, step = 0,
                     exportN = 50, exportStatus = "", cfgLabel = sCfgName,
                     selectedState = 1, showGrid = False},
        Column[{
          (* Row 1: Step controls with back buttons *)
          Row[{
            Button["\[Minus]50",
              Do[
                If[step > sHist["min"],
                  step--;
                  state = sHist[Mod[step, sBufSize] + 1],
                  If[sIsReversible,
                    state = pca5InverseStep[sGraph, sInvRule, state];
                    step--;
                    sHist[Mod[step, sBufSize] + 1] = state;
                    sHist["min"] = step;
                    If[sHist["max"] - sHist["min"] >= sBufSize,
                      sHist["max"] = sHist["min"] + sBufSize - 1],
                    Break[]
                  ]
                ],
                {50}
              ], Method -> "Queued"],
            Spacer[5],
            Button["\[Minus]10",
              Do[
                If[step > sHist["min"],
                  step--;
                  state = sHist[Mod[step, sBufSize] + 1],
                  If[sIsReversible,
                    state = pca5InverseStep[sGraph, sInvRule, state];
                    step--;
                    sHist[Mod[step, sBufSize] + 1] = state;
                    sHist["min"] = step;
                    If[sHist["max"] - sHist["min"] >= sBufSize,
                      sHist["max"] = sHist["min"] + sBufSize - 1],
                    Break[]
                  ]
                ],
                {10}
              ], Method -> "Queued"],
            Spacer[5],
            Button["Back",
              If[step > sHist["min"],
                step--;
                state = sHist[Mod[step, sBufSize] + 1],
                If[sIsReversible,
                  state = pca5InverseStep[sGraph, sInvRule, state];
                  step--;
                  sHist[Mod[step, sBufSize] + 1] = state;
                  sHist["min"] = step;
                  If[sHist["max"] - sHist["min"] >= sBufSize,
                    sHist["max"] = sHist["min"] + sBufSize - 1]
                ]
              ], Method -> "Queued"],
            Spacer[5],
            Button["Step",
              If[step < sHist["max"],
                step++;
                state = sHist[Mod[step, sBufSize] + 1],
                state = If[sIsPCA5, pca5Step[sGraph, sRule, state],
                  CAStep[sGraph, sRule, state]];
                step++;
                sHist[Mod[step, sBufSize] + 1] = state;
                sHist["max"] = step;
                If[sHist["max"] - sHist["min"] >= sBufSize,
                  sHist["min"] = sHist["max"] - sBufSize + 1]
              ], Method -> "Queued"],
            Spacer[5],
            Button["x10",
              Do[
                If[step < sHist["max"],
                  step++;
                  state = sHist[Mod[step, sBufSize] + 1],
                  state = If[sIsPCA5, pca5Step[sGraph, sRule, state],
                    CAStep[sGraph, sRule, state]];
                  step++;
                  sHist[Mod[step, sBufSize] + 1] = state;
                  sHist["max"] = step;
                  If[sHist["max"] - sHist["min"] >= sBufSize,
                    sHist["min"] = sHist["max"] - sBufSize + 1]
                ],
                {10}
              ], Method -> "Queued"],
            Spacer[5],
            Button["x50",
              Do[
                If[step < sHist["max"],
                  step++;
                  state = sHist[Mod[step, sBufSize] + 1],
                  state = If[sIsPCA5, pca5Step[sGraph, sRule, state],
                    CAStep[sGraph, sRule, state]];
                  step++;
                  sHist[Mod[step, sBufSize] + 1] = state;
                  sHist["max"] = step;
                  If[sHist["max"] - sHist["min"] >= sBufSize,
                    sHist["min"] = sHist["max"] - sBufSize + 1]
                ],
                {50}
              ], Method -> "Queued"],
            Spacer[15],
            Button["Reset",
              state = sInit; step = 0;
              sHist[1] = sInit;
              sHist["min"] = 0; sHist["max"] = 0],
            Spacer[5],
            Button["Center Seed",
              state = If[sIsPCA5,
                Table[{0,0,0,0,0}, sN], ConstantArray[0, sN]];
              state[[sCenter]] = If[sIsPCA5, {0,1,1,1,1}, 1];
              step = 0;
              sHist[1] = state;
              sHist["min"] = 0; sHist["max"] = 0],
            Spacer[5],
            Button["Clear",
              state = If[sIsPCA5,
                Table[{0,0,0,0,0}, sN], ConstantArray[0, sN]];
              step = 0;
              sHist[1] = state;
              sHist["min"] = 0; sHist["max"] = 0]
          }],
          (* Row 2: Load/Save Conf + file info *)
          Row[{
            Button["Load Conf",
              Module[{f, newState},
                f = SystemDialogInput["FileOpen",
                  {sRulesDir, 
                   {"Config (*.caconf)" -> {"*.caconf"}, "All" -> {"*"}}}];
                If[StringQ[f] && FileExistsQ[f],
                  newState = LoadiOSConfigFile[f, sGraph];
                  state = newState; step = 0;
                  sHist[1] = state;
                  sHist["min"] = 0; sHist["max"] = 0;
                  cfgLabel = FileBaseName[f];
                  exportStatus = "Loaded: " <> FileNameTake[f];
                ];
              ], Method -> "Queued"],
            Spacer[5],
            Button["Save Conf",
              Module[{f},
                f = SystemDialogInput["FileSave",
                  {FileNameJoin[{sRulesDir, cfgLabel <> ".caconf"}], 
                   {"Config (*.caconf)" -> {"*.caconf"}, "All" -> {"*"}}}];
                If[StringQ[f],
                  If[!StringEndsQ[f, ".caconf"], f = f <> ".caconf"];
                  SaveiOSConfigFile[f, sGraph, state];
                  exportStatus = "Saved: " <> FileNameTake[f];
                ];
              ], Method -> "Queued"],
            If[Length[sGridLines] > 0,
              Row[{Spacer[5],
                Button[Dynamic[If[showGrid, "Grid \[Checkmark]", "Grid"]],
                  showGrid = !showGrid]}],
              Nothing],
            Spacer[5],
            Button["Open Rule", SystemOpen[sRuleFile], 
              Enabled -> (sRuleFile =!= "" && FileExistsQ[sRuleFile])],
            Spacer[5],
            Button["Open Conf", 
              Module[{cf},
                cf = FileNameJoin[{sRulesDir, cfgLabel <> ".caconf"}];
                If[FileExistsQ[cf], SystemOpen[cf]]],
              Enabled -> Dynamic[
                FileExistsQ[FileNameJoin[{sRulesDir, cfgLabel <> ".caconf"}]]]],
            Spacer[10],
            Style[Row[{"Rule: ", FileNameTake[sRuleFile], 
              "  Conf: ", If[sConfFile =!= "", FileNameTake[sConfFile], "(default)"]}],
              FontSize -> 10, GrayLevel[0.4]]
          }],
          (* Row 3: Export controls *)
          Row[{
            "Steps:", Spacer[3],
            InputField[Dynamic[exportN], Number, FieldSize -> 4],
            Spacer[10],
            Button["Save PNG",
              Module[{dir, cs, img, fname},
                dir = caExportDir[cfgLabel, "_images"];
                If[!DirectoryQ[dir], CreateDirectory[dir]];
                exportStatus = "Exporting PNG..."; cs = state;
                Do[
                  img = caRenderFrame[sIsPCA5, sPolys, sCellPolys, cs,
                    sColors, sInterior, sClipRange, 1200];
                  fname = FileNameJoin[{dir,
                    StringPadLeft[ToString[t], 3, "0"] <> ".png"}];
                  Export[fname, img, "PNG"];
                  If[t < exportN, cs = caStepOnce[sIsPCA5, sGraph, sRule, cs]];
                  , {t, 0, exportN}];
                exportStatus = ToString[exportN+1] <> " PNGs -> " <> dir;
              ], Method -> "Queued"],
            Spacer[5],
            Button["Save PDF",
              Module[{cs, frames, fname},
                exportStatus = "Rendering PDF..."; cs = state;
                frames = Table[
                  Module[{img},
                    img = caRenderFrame[sIsPCA5, sPolys, sCellPolys, cs,
                      sColors, sInterior, sClipRange, 1200];
                    If[t < exportN, cs = caStepOnce[sIsPCA5, sGraph, sRule, cs]];
                    img],
                  {t, 0, exportN}];
                fname = caExportFile[cfgLabel, ".pdf"];
                Export[fname, frames, "PDF"];
                exportStatus = "PDF -> " <> fname;
              ], Method -> "Queued"],
            Spacer[5],
            Button["Save MP4",
              Module[{cs, frames, fname},
                exportStatus = "Rendering frames..."; cs = state;
                frames = Table[
                  Module[{img},
                    img = caRenderFrame[sIsPCA5, sPolys, sCellPolys, cs,
                      sColors, sInterior, sClipRange, 900];
                    If[t < exportN, cs = caStepOnce[sIsPCA5, sGraph, sRule, cs]];
                    img],
                  {t, 0, exportN}];
                fname = caExportFile[cfgLabel, ".mp4"];
                exportStatus = "Encoding MP4...";
                Export[fname, frames, "MP4", "FrameRate" -> 4];
                exportStatus = "MP4 -> " <> fname;
              ], Method -> "Queued"]
          }],
          (* Status *)
          Dynamic[Style[Row[{"Step: ", step,
            "  [", sHist["min"], "..", sHist["max"], "]",
            "  Tiles: ", sN,
            "  Interior: ", Length[sInterior],
            If[sIsPCA5, 
              If[sIsReversible, " (Reversible PCA5)", " (PCA5)"], 
              " (GCA)"],
            If[exportStatus =!= "", "  " <> exportStatus, ""]}],
            FontSize -> 11]],
          (* Row: Color palette for cell editing *)
          Row[Prepend[
            Table[
              With[{sv = sStateKeys[[k]]},
                Button[
                  Framed[Graphics[{Lookup[sColors, sv, GrayLevel[0.5]], 
                    Rectangle[]}, ImageSize -> {20, 20}, 
                    PlotRangePadding -> 0],
                    FrameStyle -> Dynamic[
                      If[selectedState === sv, 
                        Directive[Thick, Red], GrayLevel[0.6]]],
                    FrameMargins -> 1],
                  selectedState = sv,
                  Appearance -> "Frameless"
                ]
              ],
              {k, Length[sStateKeys]}
            ],
            Style["Edit: ", FontSize -> 10]
          ], Spacer[2]],
          (* Graphics with click handler *)
          Dynamic[
            EventHandler[
              Module[{baseImg},
                baseImg = If[sIsPCA5,
                  renderPCA5Clipped[sPolys, sCellPolys, state,
                    sColors, sInterior, sClipRange, 900],
                  renderCAClipped[sCellPolys, state,
                    sColors, sInterior, sClipRange, 900]];
                If[showGrid && Length[sGridLines] > 0,
                  Show[baseImg, 
                    Graphics[{RGBColor[0.55, 0.40, 0.25, 0.45], 
                              AbsoluteThickness[0.5], sGridLines}]],
                  baseImg
                ]
              ],
              {"MouseClicked" :> 
                Module[{pt, idx},
                  pt = MousePosition["Graphics"];
                  If[pt =!= None,
                    idx = First[sNearestFunc[pt, 1], None];
                    If[idx =!= None && 1 <= idx <= sN,
                      If[sIsPCA5,
                        (* PCA5: find which of the 5 sub-parts was clicked *)
                        Module[{partCenters, partIdx, curVal},
                          partCenters = Table[
                            Mean[sPolys[[idx, p]]], {p, 1, 5}];
                          partIdx = First[Ordering[
                            Norm[# - pt] & /@ partCenters, 1]];
                          curVal = state[[idx, partIdx]];
                          If[curVal === selectedState,
                            state[[idx, partIdx]] = 0,
                            state[[idx, partIdx]] = selectedState
                          ];
                        ],
                        (* Scalar CA: toggle whole cell *)
                        If[state[[idx]] === selectedState,
                          state[[idx]] = 0,
                          state[[idx]] = selectedState
                        ]
                      ];
                      (* Update buffer and invalidate future *)
                      sHist[Mod[step, sBufSize] + 1] = state;
                      sHist["max"] = step;
                    ];
                  ];
                ]
              }
            ]
          ]
        }, Spacings -> 0.5]
      ]
    ]
  ];

(* ============================================================ *)
(*  Stage 3: Drawing CA state                                    *)
(* ============================================================ *)

(* Default color palette for discrete states *)
defaultCAColorAssoc = <|
  0  -> White,
  1  -> RGBColor[0, 1, 1],
  2  -> RGBColor[242/255, 216/255, 223/255],
  3  -> RGBColor[1, 0, 55/255],
  4  -> RGBColor[128/255, 100/255, 1],
  5  -> RGBColor[109/255, 224/255, 81/255],
  6  -> RGBColor[135/255, 0, 204/255],
  7  -> RGBColor[0, 0, 1],
  8  -> RGBColor[0.78, 0.63, 0.63],
  9  -> RGBColor[0, 1, 0],
  10 -> RGBColor[0.9, 0.8, 0.1]
|>;
defaultCAColorFunc[v_] := 
  Lookup[defaultCAColorAssoc, v, GrayLevel[0.5]];

DrawCAState[graph_Association, state_List, opts___] := 
  DrawCAState[graph, state, defaultCAColorFunc, opts];

DrawCAState[graph_Association, state_List, colorFunc_, opts___] := 
  Module[{tiles},
    tiles = graph["tiles"];
    Graphics[{
      EdgeForm[{GrayLevel[0.4], AbsoluteThickness[0.3]}],
      Table[
        {colorFunc[state[[i]]],
         Polygon[tiles[[i]]["vertices"]]},
        {i, 1, Length[tiles]}
      ]},
      opts,
      AspectRatio -> Automatic,
      PlotRange -> All,
      ImageSize -> 800
    ]
  ];

(* ============================================================ *)
(*  Stage 5: Kite & Dart Tiling                                  *)
(*  Ported from KiteAndDartFactory                               *)
(*  Each fat rhomb → 1 dart + 2 kites                            *)
(*  Each thin rhomb → 2 kites                                    *)
(* ============================================================ *)

(* Convert one rhomb label to list of KD labels *)
rhombToKDLabels[{k0_, k1_, k2_, k3_, k4_, r_, s_}] := 
  Module[{kk = {k0, k1, k2, k3, k4}, idx, isFat, labels = {}, temp,
          rD, sD, tD, uD},
    idx = Mod[Total[kk], 5];
    isFat = Mod[s - r, 5] == 1;
    rD = Mod[s + 1, 5]; sD = Mod[s + 2, 5]; 
    tD = Mod[s + 3, 5]; uD = Mod[r + 4, 5];
    
    If[isFat,
      If[idx == 1,
        AppendTo[labels, Join[kk, {r, s}]];
        temp = kk; temp[[r + 1]] += 1; temp[[s + 1]] += 1;
        AppendTo[labels, Join[temp, {rD, sD}]];
        AppendTo[labels, Join[temp, {sD, tD}]];
        ,
        (* idx == 2 *)
        AppendTo[labels, Join[kk, {rD, sD}]];
        AppendTo[labels, Join[kk, {sD, tD}]];
        temp = kk; temp[[r + 1]] += 1; temp[[s + 1]] += 1;
        AppendTo[labels, Join[temp, {r, s}]];
      ];
      ,
      (* Thin *)
      If[idx == 1,
        temp = kk; temp[[r + 1]] += 1;
        AppendTo[labels, Join[temp, {uD, r}]];
        temp = kk; temp[[s + 1]] += 1;
        AppendTo[labels, Join[temp, {s, Mod[s + 1, 5]}]];
        ,
        (* idx == 2 *)
        temp = kk; temp[[r + 1]] += 1;
        AppendTo[labels, Join[temp, {s, Mod[s + 1, 5]}]];
        temp = kk; temp[[s + 1]] += 1;
        AppendTo[labels, Join[temp, {uD, r}]];
      ];
    ];
    labels
  ];

(* Classify KD tile type from label *)
kdClassifyTile[label_List] := 
  If[MemberQ[{1, 4}, Mod[Total[label[[1 ;; 5]]], 5]], "Dart", "Kite"];

(* Compute 4 vertex keys for a KD tile *)
(* Vertex traversal uses changeComponent encoding from original code *)
kdVertexKeys[{k0_, k1_, k2_, k3_, k4_, r_, s_}] := 
  Module[{kk, idx, cc, tDir, tSign, keys},
    kk = {k0, k1, k2, k3, k4};
    idx = Mod[Total[kk], 5];
    tDir = Mod[s + 2, 5] + 1;  (* 1-based index *)
    
    (* Change components: {direction (0-based), delta (+1 or -1)} *)
    If[idx == 1 || idx == 4,
      cc = {{r, +1}, {s, +1}, {r, -1}};   (* DART pattern *)
      ,
      cc = {{r, -1}, {r, +1}, {s, -1}};   (* KITE pattern *)
    ];
    If[idx > 2,
      cc = {#[[1]], -#[[2]]} & /@ cc;      (* flip signs *)
    ];
    
    (* t-direction sign at vertex 2 *)
    tSign = If[OddQ[Quotient[idx - 1, 2]], -1, +1];
    
    keys = {kk};
    (* v1 *)
    kk = ReplacePart[kk, cc[[1, 1]] + 1 -> kk[[cc[[1, 1]] + 1]] + cc[[1, 2]]];
    AppendTo[keys, kk];
    (* v2 + t adjustment *)
    kk = ReplacePart[kk, cc[[2, 1]] + 1 -> kk[[cc[[2, 1]] + 1]] + cc[[2, 2]]];
    kk = ReplacePart[kk, tDir -> kk[[tDir]] + tSign];
    AppendTo[keys, kk];
    (* v3 + reverse t *)
    kk = ReplacePart[kk, cc[[3, 1]] + 1 -> kk[[cc[[3, 1]] + 1]] + cc[[3, 2]]];
    kk = ReplacePart[kk, tDir -> kk[[tDir]] - tSign];
    AppendTo[keys, kk];
    
    keys
  ];

(* Main generation function for Kite & Dart tiling *)
GeneratePenroseKD[
    range : {xmin_, ymin_, width_, height_},
    offset : {g0_, g1_, g2_, g3_, g4_}
  ] := 
  Module[{rhombLabels, kdLabels, kdTiles, kRange, x, y, kk, r, s, label,
          xmax = xmin + width, ymax = ymin + height},
    
    (* Step 1: Generate rhomb labels (reuse pentagrid method) *)
    kRange = {
      {Ceiling[xmin - g0], Ceiling[xmax - g0]},
      {Ceiling[xmin cVal[[2]] + ymin sVal[[2]] - g1],
       Ceiling[xmax cVal[[2]] + ymax sVal[[2]] - g1]},
      {Ceiling[xmax cVal[[3]] + ymin sVal[[3]] - g2],
       Ceiling[xmin cVal[[3]] + ymax sVal[[3]] - g2]},
      {Ceiling[xmax cVal[[4]] + ymax sVal[[4]] - g3],
       Ceiling[xmin cVal[[4]] + ymin sVal[[4]] - g3]},
      {Ceiling[xmin cVal[[5]] + ymax sVal[[5]] - g4],
       Ceiling[xmax cVal[[5]] + ymin sVal[[5]] - g4]}
    };
    
    rhombLabels = Association[];
    Do[
      Do[
        Do[
          {x, y} = gridIntersection[i, m, j, n, offset];
          If[xmin <= x <= xmax && ymin <= y <= ymax,
            kk = Table[
              If[l == i, m, If[l == j, n,
                Ceiling[cVal[[l + 1]] x + sVal[[l + 1]] y - offset[[l + 1]]]]],
              {l, 0, 4}
            ];
            {r, s} = {i, j};
            If[s - r == 4 || s - r == 3, {r, s} = {j, i}];
            label = Append[kk, r] ~Append~ s;
            rhombLabels[label] = True;
          ];
          , {n, kRange[[j + 1, 1]], kRange[[j + 1, 2]]}
        ];
        , {m, kRange[[i + 1, 1]], kRange[[i + 1, 2]]}
      ];
      , {i, 0, 3}, {j, i + 1, 4}
    ];
    
    (* Step 2: Convert each rhomb to KD labels *)
    kdLabels = Association[];
    Do[
      Do[
        If[!KeyExistsQ[kdLabels, kdl],
          kdLabels[kdl] = True
        ];
        , {kdl, rhombToKDLabels[rl]}
      ];
      , {rl, Keys[rhombLabels]}
    ];
    
    (* Step 3: Build tile data *)
    kdTiles = Table[
      <|
        "label" -> kdl,
        "type" -> kdClassifyTile[kdl],
        "vertices" -> (projectTo2D /@ kdVertexKeys[kdl]),
        "vertexKeys" -> kdVertexKeys[kdl]
      |>,
      {kdl, Keys[kdLabels]}
    ];
    
    kdTiles
  ];

(* Drawing for KD tiling *)
kiteColor = RGBColor[0.85, 0.75, 0.45, 0.85];
dartColor = RGBColor[0.35, 0.55, 0.80, 0.85];

DrawPenroseKD[tiles_List, opts___] := 
  Graphics[
    {EdgeForm[{GrayLevel[0.3], AbsoluteThickness[0.5]}],
     Map[
       {If[#["type"] === "Kite", kiteColor, dartColor],
        Polygon[#["vertices"]]} &,
       tiles
     ]
    },
    opts,
    AspectRatio -> Automatic,
    PlotRange -> All,
    ImageSize -> 800
  ];

(* Build neighborhood graph for KD tiling *)
(* Reuses the same structure as BuildTilingGraph but with KD-specific neighborType *)
BuildKDTilingGraph[tiles_List] := 
  Module[{nTiles, vertexToTiles, mooreNbrs, neumannNbrs, neumannDirs,
          nbrTypes, vkeys, vk, edgeToTiles, edgeKey, a, b, tileList,
          center, v2pt, theta0, theta1, dirIdx, nbrCenter, nbr,
          threshold},
    
    nTiles = Length[tiles];
    
    (* vertex -> tile index mapping *)
    vertexToTiles = Association[];
    Do[
      vkeys = tiles[[i]]["vertexKeys"];
      Do[
        vk = vkeys[[j]];
        If[KeyExistsQ[vertexToTiles, vk],
          AppendTo[vertexToTiles[vk], i],
          vertexToTiles[vk] = {i}
        ];
        , {j, 1, 4}
      ];
      , {i, 1, nTiles}
    ];
    
    (* Moore neighbors *)
    mooreNbrs = Association[];
    Do[
      vkeys = tiles[[i]]["vertexKeys"];
      mooreNbrs[i] = DeleteCases[
        Union @@ (Lookup[vertexToTiles, vkeys, {}]),
        i
      ];
      , {i, 1, nTiles}
    ];
    
    (* Neumann neighbors *)
    edgeToTiles = Association[];
    Do[
      vkeys = tiles[[i]]["vertexKeys"];
      Do[
        edgeKey = Sort[{vkeys[[j]], vkeys[[Mod[j, 4] + 1]]}];
        If[KeyExistsQ[edgeToTiles, edgeKey],
          AppendTo[edgeToTiles[edgeKey], i],
          edgeToTiles[edgeKey] = {i}
        ];
        , {j, 1, 4}
      ];
      , {i, 1, nTiles}
    ];
    
    neumannNbrs = Association[];
    Do[neumannNbrs[i] = {}, {i, 1, nTiles}];
    Scan[
      Function[{ek},
        tileList = edgeToTiles[ek];
        If[Length[tileList] == 2,
          {a, b} = tileList;
          neumannNbrs[a] = Union[neumannNbrs[a], {b}];
          neumannNbrs[b] = Union[neumannNbrs[b], {a}];
        ];
      ],
      Keys[edgeToTiles]
    ];
    
    (* Neumann directions — KD uses v0-v2 midpoint as center, *)
    (* angle relative to v2, with Kite/Dart-specific thresholds *)
    neumannDirs = Association[];
    Do[
      neumannDirs[i] = Association[];
      center = Mean[{tiles[[i]]["vertices"][[1]], tiles[[i]]["vertices"][[3]]}];
      v2pt = tiles[[i]]["vertices"][[3]];
      theta0 = ArcTan @@ (v2pt - center);
      threshold = If[tiles[[i]]["type"] === "Kite", 0.35 Pi, 0.3 Pi];
      Do[
        nbrCenter = Mean[{tiles[[nbr]]["vertices"][[1]], tiles[[nbr]]["vertices"][[3]]}];
        theta1 = Mod[ArcTan @@ (nbrCenter - center) - theta0, 2 Pi];
        dirIdx = Which[
          theta1 < threshold, 0,
          theta1 < Pi, 2,
          theta1 < 2 Pi - threshold, 4,
          True, 6
        ];
        (* Apply +6 mod 8 shift from original code *)
        neumannDirs[i][nbr] = Mod[dirIdx + 6, 8];
        , {nbr, neumannNbrs[i]}
      ];
      , {i, 1, nTiles}
    ];
    
    (* neighborType classification — KD specific *)
    nbrTypes = Association[];
    Do[
      nbrTypes[i] = classifyKDNeighborType[i, tiles, mooreNbrs, neumannNbrs];
      , {i, 1, nTiles}
    ];
    
    <|
      "tiles" -> tiles,
      "vertexToTiles" -> vertexToTiles,
      "mooreNeighbors" -> mooreNbrs,
      "neumannNeighbors" -> neumannNbrs,
      "neumannDirections" -> neumannDirs,
      "neighborTypes" -> nbrTypes
    |>
  ];

(* KD neighborType classification — from KiteAndDartFactory.checkNeighborType *)
classifyKDNeighborType[idx_, tiles_, mooreNbrs_, neumannNbrs_] := 
  Module[{tile, moore, neumann, nTile, nDart, nNeuDart, result = 15},
    tile = tiles[[idx]];
    moore = mooreNbrs[idx];
    neumann = neumannNbrs[idx];
    nTile = Length[moore];
    nDart = Count[tiles[[#]]["type"] & /@ moore, "Dart"];
    
    Which[
      nTile == 10,
        result = 7,
      nTile == 9 && nDart == 4,
        result = 4,
      nTile == 9 && nDart == 6,
        result = 5,
      nTile == 8 && nDart == 4,
        result = 1,
      nTile == 9 && nDart == 3,
        If[tile["type"] === "Dart", result = 6, result = 3],
      nTile == 8 && nDart == 2,
        nNeuDart = Count[tiles[[#]]["type"] & /@ neumann, "Dart"];
        If[nNeuDart == 2,
          If[tile["type"] === "Dart", result = 2, result = 0]
        ],
      True, result = 15
    ];
    result
  ];

(* ============================================================ *)
(*  Square Grid                                                  *)
(*  Generates tiles compatible with the same graph structure      *)
(*  so CAStep / CASimulator work directly.                        *)
(* ============================================================ *)

GenerateSquareGrid[cols_Integer, rows_Integer] := 
  GenerateSquareGrid[cols, rows, 0, 0];

GenerateSquareGrid[cols_Integer, rows_Integer, x0_Integer, y0_Integer] := 
  Module[{tiles = {}},
    Do[
      AppendTo[tiles, <|
        "label" -> {c, r},
        "type" -> "Square",
        "vertices" -> N@{{c, r}, {c + 1, r}, {c + 1, r + 1}, {c, r + 1}},
        "vertexKeys" -> {{c, r}, {c + 1, r}, {c + 1, r + 1}, {c, r + 1}}
      |>];
      , {r, y0, y0 + rows - 1}, {c, x0, x0 + cols - 1}
    ];
    tiles
  ];

DrawSquareGrid[tiles_List, opts___] := 
  Graphics[
    {EdgeForm[{GrayLevel[0.6], AbsoluteThickness[0.3]}],
     FaceForm[White],
     Polygon[#["vertices"]] & /@ tiles
    },
    opts,
    AspectRatio -> Automatic,
    PlotRange -> All,
    ImageSize -> 800
  ];

(* Build graph for square grid — direct (col,row) addressing *)
BuildSquareGridGraph[tiles_List, cols_Integer, rows_Integer] := 
  BuildSquareGridGraph[tiles, cols, rows, 0, 0];

BuildSquareGridGraph[tiles_List, cols_Integer, rows_Integer, x0_Integer, y0_Integer] := 
  Module[{nTiles, idx, mooreNbrs, neumannNbrs, neumannDirs, nbrTypes,
          c, r, ni, mooreOffsets, neumannOffsets, neumannDirMap,
          cMax = x0 + cols, rMax = y0 + rows},
    nTiles = cols * rows;
    
    (* (col, row) -> 1-based tile index *)
    idx[col_, row_] := (row - y0) * cols + (col - x0) + 1;
    
    (* Moore: 8 neighbors *)
    mooreOffsets = {{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}};
    (* Neumann: 4 neighbors  E=0, N=6, W=4, S=2 *)
    neumannOffsets = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}};
    neumannDirMap = {0, 6, 4, 2};
    
    mooreNbrs = Association[];
    neumannNbrs = Association[];
    neumannDirs = Association[];
    nbrTypes = Association[];
    
    Do[
      Module[{ti = idx[c, r], nbrs = {}, nnbrs = {}, dirs = Association[]},
        Do[
          Module[{nc = c + d[[1]], nr = r + d[[2]]},
            If[x0 <= nc < cMax && y0 <= nr < rMax,
              AppendTo[nbrs, idx[nc, nr]]
            ];
          ];
          , {d, mooreOffsets}
        ];
        mooreNbrs[ti] = nbrs;
        
        Do[
          Module[{nc = c + neumannOffsets[[k, 1]], nr = r + neumannOffsets[[k, 2]]},
            If[x0 <= nc < cMax && y0 <= nr < rMax,
              ni = idx[nc, nr];
              AppendTo[nnbrs, ni];
              dirs[ni] = neumannDirMap[[k]];
            ];
          ];
          , {k, 1, 4}
        ];
        neumannNbrs[ti] = nnbrs;
        neumannDirs[ti] = dirs;
        nbrTypes[ti] = If[Length[nbrs] == 8, 0, 15];
      ];
      , {r, y0, y0 + rows - 1}, {c, x0, x0 + cols - 1}
    ];
    
    <|
      "tiles" -> tiles,
      "vertexToTiles" -> Association[],
      "mooreNeighbors" -> mooreNbrs,
      "neumannNeighbors" -> neumannNbrs,
      "neumannDirections" -> neumannDirs,
      "neighborTypes" -> nbrTypes
    |>
  ];

(* ============================================================ *)
(*  Strategy: Store graph/rule in a unique global symbol to      *)
(*  avoid FrontEnd serialization of large Associations.          *)
(*  DynamicModule only holds the mutable state (list of ints).   *)
(* ============================================================ *)

(* Precompute polygon list for fast rendering *)
precomputePolygons[graph_Association] := 
  Module[{tiles = graph["tiles"]},
    Table[tiles[[i]]["vertices"], {i, Length[tiles]}]
  ];

(* Fast draw using precomputed polygons *)
drawStateFromPolygons[polygons_List, state_List, imageSize_Integer] := 
  Graphics[{
    EdgeForm[{GrayLevel[0.4], AbsoluteThickness[0.3]}],
    MapThread[
      {Lookup[defaultCAColorAssoc, #2, GrayLevel[0.5]], Polygon[#1]} &,
      {polygons, state}
    ]},
    AspectRatio -> Automatic,
    PlotRange -> All,
    ImageSize -> imageSize
  ];

CASimulator[graph_Association, rule_Association] := 
  With[{
    sym = Module[{s = Unique["PenroseCA"], tiles, centers, spatialCenter, centerIdx},
      tiles = graph["tiles"];
      s["graph"] = graph;
      s["rule"] = rule;
      s["polygons"] = precomputePolygons[graph];
      s["n"] = Length[tiles];
      s["defVal"] = rule["defaultValue"];
      s["nStates"] = rule["numStates"];
      (* Find tile closest to spatial center *)
      centers = Table[Mean[tiles[[i]]["vertices"]], {i, Length[tiles]}];
      spatialCenter = Mean[centers];
      centerIdx = First[Ordering[Norm[# - spatialCenter] & /@ centers, 1]];
      s["centerTile"] = centerIdx;
      s
    ]
  },
    DynamicModule[{state = ConstantArray[sym["defVal"], sym["n"]], step = 0},
      Column[{
        Row[{
          Button["Step", 
            state = CAStep[sym["graph"], sym["rule"], state]; step++,
            Method -> "Queued"],
          Spacer[5],
          Button["x10", 
            Do[state = CAStep[sym["graph"], sym["rule"], state]; step++, {10}],
            Method -> "Queued"],
          Spacer[5],
          Button["x50", 
            Do[state = CAStep[sym["graph"], sym["rule"], state]; step++, {50}],
            Method -> "Queued"],
          Spacer[15],
          Button["Reset", 
            state = ConstantArray[sym["defVal"], sym["n"]]; step = 0],
          Spacer[5],
          Button["Random", 
            state = RandomInteger[{0, sym["nStates"] - 1}, sym["n"]]; step = 0],
          Spacer[5],
          Button["Center Seed",
            state = ConstantArray[sym["defVal"], sym["n"]];
            state[[sym["centerTile"]]] = 1; step = 0]
        }],
        Dynamic[Style[Row[{"Step: ", step, "  Tiles: ", sym["n"]}], FontSize -> 12]],
        Dynamic[drawStateFromPolygons[sym["polygons"], state, 900]]
      }, Spacings -> 0.5]
    ]
  ];

(* 
  << PenroseTiling`
  
  tiles = GeneratePenroseRhombs[{-1, -1, 15, 15}, {0, 0.1, -0.1, 0.2, -0.2}];
  graph = BuildTilingGraph[tiles];
  
  (* 1. neighborType distribution *)
  Counts[Values[graph["neighborTypes"]]]
  
  (* 2. Draw tiles colored by neighborType *)
  DrawTilingWithNeighborTypes[graph, ImageSize -> 800]
  
  (* 3. Inspect a specific tile's neighborhood *)
  DrawTilingNeighborhood[graph, 100]
  
  (* 4. Query *)
  MooreNeighbors[graph, 100]
  NeumannNeighbors[graph, 100]
  NeighborType[graph, 100]
  NeumannDirection[graph, 100, #] & /@ NeumannNeighbors[graph, 100]
  
  (* --- Stage 3 examples --- *)
  
  (* 5. GCA: Growth rule with 6 states cycling *)
  (* Key format: {center, count_state1, count_state2, ..., count_stateN} *)
  (* State 0 with any state-1 neighbor becomes 1; others cycle 1->2->...->5->0 *)
  rule = CreateCARule[<|
    "type" -> "GCA",
    "transitionRules" -> {
      {0, 1, _, _, _, _} -> 1,
      {0, 2, _, _, _, _} -> 1,
      {0, 3, _, _, _, _} -> 1,
      {1, _, _, _, _, _} -> 2,
      {2, _, _, _, _, _} -> 3,
      {3, _, _, _, _, _} -> 4,
      {4, _, _, _, _, _} -> 5,
      {5, _, _, _, _, _} -> 0
    },
    "rotational" -> False,
    "undefinedDefault" -> 0,
    "defaultValue" -> 0,
    "numStates" -> 6
  |>];
  
  initState = ConstantArray[0, Length[tiles]];
  (* Find tile closest to spatial center *)
  seed = First[Nearest[
    Table[Mean[tiles[[i]]["vertices"]] -> i, {i, Length[tiles]}],
    Mean[Table[Mean[tiles[[i]]["vertices"]], {i, Length[tiles]}]]
  ]];
  initState[[seed]] = 1;
  
  states = CAEvolve[graph, rule, initState, 30];
  DrawCAState[graph, states[[-1]], ImageSize -> 800]
  
  (* Animate *)
  ListAnimate[DrawCAState[graph, #, ImageSize -> 500] & /@ states]
  
  (* 6. Partitioned CA (rotational rule from Rhomb-rotationalrule) *)
  (* Key format: {center, nw, ne, se, sw} *)
  pRule = CreateCARule[<|
    "type" -> "Partitioned",
    "transitionRules" -> {
      {0, 1, 0, 0, 0} -> 1,
      {0, 0, 1, 0, 0} -> 1,
      {1, _, _, _, _} -> 2,
      {2, _, _, _, _} -> 0
    },
    "rotational" -> True,
    "undefinedDefault" -> "same",
    "defaultValue" -> 0,
    "numStates" -> 3
  |>];
  
  initState2 = ConstantArray[0, Length[tiles]];
  initState2[[seed]] = 1;  (* reuse seed from above *)
  states2 = CAEvolve[graph, pRule, initState2, 50];
  DrawCAState[graph, states2[[-1]], ImageSize -> 800]
  
  (* 7. Interactive simulator *)
  CASimulator[graph, rule]
  
  (* --- Stage 5: Kite & Dart examples --- *)
  
  (* 8. Generate and draw KD tiling *)
  kdTiles = GeneratePenroseKD[{-1, -1, 15, 15}, {0, 0.1, -0.1, 0.2, -0.2}];
  DrawPenroseKD[kdTiles]
  
  (* 9. Build KD graph and run CA *)
  kdGraph = BuildKDTilingGraph[kdTiles];
  Counts[Values[kdGraph["neighborTypes"]]]
  
  (* 10. CA on KD tiling *)
  kdRule = CreateCARule[<|"type" -> "GCA",
    "transitionRules" -> {
      {0, 1, _, _, _, _} -> 1, {0, 2, _, _, _, _} -> 1,
      {1, _, _, _, _, _} -> 2, {2, _, _, _, _, _} -> 3,
      {3, _, _, _, _, _} -> 4, {4, _, _, _, _, _} -> 5,
      {5, _, _, _, _, _} -> 0},
    "rotational" -> False, "undefinedDefault" -> 0,
    "defaultValue" -> 0, "numStates" -> 6|>];
  CASimulator[kdGraph, kdRule]
  
  (* --- Square Grid examples --- *)
  
  (* 11. Generate square grid *)
  sqTiles = GenerateSquareGrid[80, 80];
  sqGraph = BuildSquareGridGraph[sqTiles, 80, 80];
  
  (* 12. GCA with Moore neighborhood (8 neighbors, default) *)
  (* Key: {center, count_state1, ..., count_stateN} *)
  (* counts are over 8 Moore neighbors *)
  sqMooreRule = CreateCARule[<|"type" -> "GCA",
    "neighborhood" -> "Moore",  (* default, can be omitted *)
    "transitionRules" -> {
      {0, 1, _, _, _, _} -> 1, {0, 2, _, _, _, _} -> 1,
      {1, _, _, _, _, _} -> 2, {2, _, _, _, _, _} -> 3,
      {3, _, _, _, _, _} -> 4, {4, _, _, _, _, _} -> 5,
      {5, _, _, _, _, _} -> 0},
    "rotational" -> False, "undefinedDefault" -> 0,
    "defaultValue" -> 0, "numStates" -> 6|>];
  CASimulator[sqGraph, sqMooreRule]
  
  (* 13. GCA with Neumann neighborhood (4 neighbors) *)
  (* Same key format, but counts are over 4 Neumann neighbors *)
  (* Max possible count for any state is 4, not 8 *)
  sqNeumannRule = CreateCARule[<|"type" -> "GCA",
    "neighborhood" -> "Neumann",
    "transitionRules" -> {
      {0, 1, _, _, _, _} -> 1, {0, 2, _, _, _, _} -> 1,
      {1, _, _, _, _, _} -> 2, {2, _, _, _, _, _} -> 3,
      {3, _, _, _, _, _} -> 4, {4, _, _, _, _, _} -> 5,
      {5, _, _, _, _, _} -> 0},
    "rotational" -> False, "undefinedDefault" -> 0,
    "defaultValue" -> 0, "numStates" -> 6|>];
  CASimulator[sqGraph, sqNeumannRule]
  
  (* 14. Partitioned CA on square grid *)
  (*                                                            *)
  (* Partitioned CA always uses Neumann (4-direction) neighbors *)
  (* Direction assignment for square grid:                      *)
  (*   E=0, S=2, W=4, N=6                                      *)
  (* Key order: {center, W, N, E, S}                            *)
  (*                                                            *)
  (* With "rotational" -> True, each rule is expanded to 4      *)
  (* rotations, so you only need to specify one orientation.    *)
  (* Example: {0, 1, _, _, _} -> 1  with rotational=True gives  *)
  (*   {0, 1, _, _, _} -> 1  (W=1)                              *)
  (*   {0, _, 1, _, _} -> 1  (N=1)                              *)
  (*   {0, _, _, 1, _} -> 1  (E=1)                              *)
  (*   {0, _, _, _, 1} -> 1  (S=1)                              *)
  (*                                                            *)
  (* iOS app format conversion:                                 *)
  (*   iOS: (center | d1, d2, d3, d4) => value                  *)
  (*   Mathematica: {center, d1, d2, d3, d4} -> value           *)
  
  (* 14a. Growth rule — from growth-rule.txt *)
  (* iOS format: (0 bar 1,any,any,any) => 1; (1 bar any,any,any,any) => 1; rotational=YES *)
  sqGrowth = CreateCARule[<|"type" -> "Partitioned",
    "transitionRules" -> {
      {0, 1, _, _, _} -> 1,
      {1, _, _, _, _} -> 1
    },
    "rotational" -> True,
    "undefinedDefault" -> "same",
    "defaultValue" -> 0, "numStates" -> 2|>];
  CASimulator[sqGraph, sqGrowth]
  
  (* 14b. Banks' CA — from Neumann-rotationalrule.txt *)
  (* iOS format: (1 bar 1,1,0,0)=>0; (0 bar 0,1,1,1)=>1; (0 bar 1,1,1,1)=>1; (1 bar any,any,any,any)=>1 *)
  (* rotational=YES *)
  sqBanks = CreateCARule[<|"type" -> "Partitioned",
    "transitionRules" -> {
      {1, 1, 1, 0, 0} -> 0,
      {0, 0, 1, 1, 1} -> 1,
      {0, 1, 1, 1, 1} -> 1,
      {1, _, _, _, _} -> 1
    },
    "rotational" -> True,
    "undefinedDefault" -> "same",
    "defaultValue" -> 0, "numStates" -> 2|>];
  CASimulator[sqGraph, sqBanks]
  
  (* 14c. 3-state signal propagation *)
  sqSignal = CreateCARule[<|"type" -> "Partitioned",
    "transitionRules" -> {
      {0, 1, _, _, _} -> 1,
      {1, _, _, _, _} -> 2,
      {2, _, _, _, _} -> 0
    },
    "rotational" -> True,
    "undefinedDefault" -> "same",
    "defaultValue" -> 0, "numStates" -> 3|>];
  CASimulator[sqGraph, sqSignal]
  
  (* 14d. Fredkin's parity rule — from parity-vonNeumann.txt *)
  (* GCA with Neumann neighborhood: new state = parity of sum of neighbors *)
  sqParity = CreateCARule[<|"type" -> "GCA",
    "neighborhood" -> "Neumann",
    "transitionRules" -> {
      {_, 0} -> 0, {_, 1} -> 1, {_, 2} -> 0, {_, 3} -> 1, {_, 4} -> 0
    },
    "rotational" -> False,
    "undefinedDefault" -> 0,
    "defaultValue" -> 0, "numStates" -> 2|>];
  CASimulator[sqGraph, sqParity]
  
  (* ============================================================ *)
  (* True 5-Neighborhood Partitioned CA (PCA5) Examples            *)
  (* ============================================================ *)
  
  (* 15. PCA5 on square grid: straight-moving conserved signals *)
  (* Each cell state = {c, N, E, S, W} *)
  (* Rule: signal received from S -> forward to N (straight line) *)
  (* With rotational symmetry: 4 directions *)
  sqPCA = CreatePCA5Rule[<|
    "transitionRules" -> {
      {0, 0, 0, 1, 0} -> {0, 1, 0, 0, 0}
    },
    "rotational" -> True,
    "numStates" -> 2
  |>];
  sqTiles = GenerateSquareGrid[60, 60];
  sqGraph = BuildSquareGridGraph[sqTiles, 60, 60];
  PCA5Simulator[sqGraph, sqPCA]
  
  (* 16. PCA5: worm with trail *)
  (* Signal from S makes center=2 (trail) and forwards to N *)
  sqWorm = CreatePCA5Rule[<|
    "transitionRules" -> {
      {0, 0, 0, 1, 0} -> {2, 1, 0, 0, 0},
      {2, 0, 0, 0, 0} -> {0, 0, 0, 0, 0}
    },
    "rotational" -> True,
    "numStates" -> 3
  |>];
  PCA5Simulator[sqGraph, sqWorm]
  
  (* 17. PCA5: right-turning signal *)
  (* Signal from S turns right -> goes to E *)
  sqTurn = CreatePCA5Rule[<|
    "transitionRules" -> {
      {0, 0, 0, 1, 0} -> {0, 0, 1, 0, 0}
    },
    "rotational" -> True,
    "numStates" -> 2
  |>];
  PCA5Simulator[sqGraph, sqTurn]
  
  (* 18. PCA5 on Penrose rhomb tiling *)
  (* The facingMap is automatically built using the RPT conversion table *)
  (* Direction parts: SE=slot2, NE=slot3, NW=slot4, SW=slot5, center=slot1 *)
  tiles = GeneratePenroseRhombs[{-1, -1, 15, 15}, {0, 0.1, -0.1, 0.2, -0.2}];
  graph = BuildTilingGraph[tiles];
  
  rptPCA = CreatePCA5Rule[<|
    "transitionRules" -> {
      {0, 0, 0, 1, 0} -> {0, 1, 0, 0, 0}
    },
    "rotational" -> True,
    "numStates" -> 2
  |>];
  PCA5Simulator[graph, rptPCA]
  
  (* 19. PCA5 on Penrose rhomb: worm with trail *)
  rptWorm = CreatePCA5Rule[<|
    "transitionRules" -> {
      {0, 0, 0, 1, 0} -> {2, 1, 0, 0, 0},
      {2, 0, 0, 0, 0} -> {0, 0, 0, 0, 0}
    },
    "rotational" -> True,
    "numStates" -> 3
  |>];
  PCA5Simulator[graph, rptWorm]
  
  (* 20. PCA5 on KD tiling *)
  kdTiles = GeneratePenroseKD[{-1, -1, 15, 15}, {0, 0.1, -0.1, 0.2, -0.2}];
  kdGraph = BuildKDTilingGraph[kdTiles];
  PCA5Simulator[kdGraph, rptPCA]
*)

(* ============================================================ *)
(*  iOS CA Simulator File I/O                                    *)
(* ============================================================ *)

(* Read file — use Import which handles encoding natively *)
readiOSFile[path_String] := 
  Module[{text},
    text = Quiet[Check[
      Import[path, "Text", CharacterEncoding -> "ShiftJIS"],
      Check[Import[path, "Text", CharacterEncoding -> "UTF8"],
        Import[path, "Text"]]
    ]];
    If[!StringQ[text], text = ""];
    text
  ];

(* Extract text between XML tags — line-based, robust *)
extractTag[text_String, tag_String] := 
  Module[{lines, openPat, closePat, startLine = 0, endLine = 0,
          line, openIdx, closeIdx, content},
    openPat = "<" <> tag;
    closePat = "</" <> tag <> ">";
    lines = StringSplit[text, "\n"];
    
    (* Single-line case: <tag>content</tag> on one line *)
    Do[
      line = lines[[li]];
      If[StringContainsQ[line, openPat] && StringContainsQ[line, closePat],
        openIdx = StringPosition[line, ">", 1];
        closeIdx = StringPosition[line, closePat, 1];
        If[Length[openIdx] > 0 && Length[closeIdx] > 0 && 
           closeIdx[[1, 1]] > openIdx[[1, 2]],
          Return[StringTrim[
            StringTake[line, {openIdx[[1, 2]] + 1, closeIdx[[1, 1]] - 1}]], Module]
        ];
      ];
      , {li, Length[lines]}
    ];
    
    (* Multi-line case *)
    Do[
      If[startLine == 0 && StringContainsQ[lines[[li]], openPat],
        startLine = li];
      If[startLine > 0 && endLine == 0 && StringContainsQ[lines[[li]], closePat],
        endLine = li; Break[]];
      , {li, Length[lines]}
    ];
    If[startLine == 0 || endLine == 0, Return[""]];
    
    (* First line: content after > *)
    line = lines[[startLine]];
    openIdx = StringPosition[line, ">", 1];
    content = If[Length[openIdx] > 0 && openIdx[[1, 2]] < StringLength[line],
      StringDrop[line, openIdx[[1, 2]]], ""];
    (* Middle lines *)
    Do[content = content <> "\n" <> lines[[li]], 
      {li, startLine + 1, endLine - 1}];
    (* Last line: content before </tag> *)
    If[endLine > startLine,
      closeIdx = StringPosition[lines[[endLine]], closePat, 1];
      If[Length[closeIdx] > 0 && closeIdx[[1, 1]] > 1,
        content = content <> "\n" <> 
          StringTake[lines[[endLine]], closeIdx[[1, 1]] - 1]
      ];
    ];
    StringTrim[content]
  ];

(* Extract attribute from tag — line-based *)
extractAttr[text_String, tag_String, attr_String] := 
  Module[{lines, line, m},
    lines = StringSplit[text, "\n"];
    Do[
      line = lines[[li]];
      If[StringContainsQ[line, "<" <> tag],
        m = StringCases[line, 
          attr <> "=\"" ~~ val : Shortest[__] ~~ "\"" :> val, 1];
        If[Length[m] > 0, Return[m[[1]], Module]];
      ];
      , {li, Length[lines]}
    ];
    ""
  ];

(* Parse a PCA vector like "(c|d1,d2,d3,d4)" or "(v1,v2,...)" or scalar *)
parseiOSVector[s_String] := 
  Module[{inner, center, rest, parts},
    inner = StringTrim[s, ("(" | ")")];
    If[StringContainsQ[inner, "|"],
      (* PCA5 format: center|d1,d2,d3,d4 *)
      {center, rest} = StringSplit[inner, "|", 2];
      parts = Prepend[StringSplit[rest, ","], center];
      ,
      (* GCA format: v1,v2,... *)
      parts = StringSplit[inner, ","];
    ];
    Map[
      Function[p, Module[{t = StringTrim[p]},
        Which[
          t === "*", _,
          StringMatchQ[t, NumberString], 
            Round[ToExpression[t]],
          True, Quiet[Check[Round[ToExpression[t]], 0]]
        ]
      ]],
      parts
    ]
  ];

(* Parse transition rules text *)
parseiOSTransitionRules[rulesText_String] := 
  Module[{lines, rules = {}},
    lines = StringSplit[rulesText, ";"];
    Do[
      Module[{line, lhsStr, rhsStr, lhs, rhs},
        line = StringTrim[line0];
        (* Remove comments starting with % *)
        line = StringReplace[line, "%" ~~ Shortest[___] ~~ EndOfLine -> ""];
        line = StringReplace[line, "%" ~~ ___ -> ""];
        line = StringTrim[line];
        If[StringContainsQ[line, "=>"],
          {lhsStr, rhsStr} = StringTrim /@ StringSplit[line, "=>", 2];
          lhs = parseiOSVector[lhsStr];
          rhs = parseiOSVector[rhsStr];
          AppendTo[rules, lhs -> rhs];
        ];
      ];
      , {line0, lines}
    ];
    rules
  ];

(* Main loader *)
LoadiOSRuleFile[path_String] := 
  Quiet[Module[{text, name, comment, geomType, cellRange, offsets,
          expr, rotational, undefDefault, rulesText, rules,
          ruleType, numStates, colors, allVals, result, meta,
          rule, defaultVal},
    
    text = readiOSFile[path];
    
    (* Header *)
    name = extractTag[text, "name"];
    If[name === "", name = extractTag[text, "n"]];
    comment = extractTag[text, "comment"];
    
    (* Geometry *)
    geomType = extractAttr[text, "Geometry", "type"];
    
    cellRange = Quiet[Check[
      Module[{cr = extractTag[text, "cellRange"], nums},
        nums = ToExpression /@ StringCases[cr, x : (DigitCharacter | "-").. :> x];
        If[Length[nums] >= 4, nums, {0, 0, 25, 25}]
      ],
      {0, 0, 25, 25}
    ]];
    
    offsets = Quiet[Check[
      Module[{oStr = extractTag[text, "offsetValues"]},
        If[StringLength[oStr] > 0,
          ToExpression /@ StringCases[oStr, 
            x : (DigitCharacter | "-" | ".").. :> x],
          {}
        ]
      ],
      {}
    ]];
    If[Length[offsets] == 0,
      Which[
        StringContainsQ[geomType, "ABT" | "Ammann" | "Beenker", IgnoreCase -> True],
          offsets = mgDefaultOffsets[8],
        StringMatchQ[geomType, "MG" ~~ DigitCharacter ..],
          offsets = mgDefaultOffsets[ToExpression[StringDrop[geomType, 2]]],
        StringContainsQ[geomType, "Rhomb" | "RPT", IgnoreCase -> True],
          offsets = mgDefaultOffsets[5],
        True,
          offsets = {0, 0.1, -0.1, 0.2, -0.2}
      ]
    ];
    
    (* Rule *)
    expr = StringTrim[extractTag[text, "infixExpression"]];
    rotational = StringMatchQ[
      StringTrim[extractTag[text, "rotational"]], 
      "YES" | "yes" | "TRUE" | "true" | "1"
    ];
    undefDefault = extractTag[text, "undefinedDefault"];
    defaultVal = extractTag[text, "defaultValue"];
    
    (* Determine rule type *)
    (* PCA5 indicator: dot notation on neighbor methods like N().s, NE().sw *)
    ruleType = Which[
      StringContainsQ[expr, "hash(c()"] ||
        StringContainsQ[expr, ").s"] ||
        StringContainsQ[expr, ").w"] ||
        StringContainsQ[expr, ").n"] ||
        StringContainsQ[expr, ").e"],
      "PCA5",
      StringContainsQ[expr, "hash(center(),"] && 
        (StringContainsQ[expr, "N()"] || StringContainsQ[expr, "NE()"]),
      "Partitioned",
      True,
      "GCA"
    ];
    
    (* Parse transition rules *)
    rulesText = extractTag[text, "transitionRules"];
    rules = parseiOSTransitionRules[rulesText];
    
    (* Count states — avoid Flatten on Blank patterns *)
    allVals = {};
    Do[
      Do[If[IntegerQ[v], AppendTo[allVals, v]], {v, r[[1]]}];
      Do[If[IntegerQ[v], AppendTo[allVals, v]], {v, r[[2]]}];
      , {r, rules}
    ];
    numStates = If[Length[allVals] > 0, Max[allVals] + 1, 2];
    
    (* Parse colors — position-based to handle multiline *)
    colors = Association[];
    Module[{colorPositions, sub, valStr, rgbaStr},
      colorPositions = StringPosition[text, "stateRGBAColor"];
      Do[
        sub = StringTake[text, {cp[[1]], Min[cp[[1]] + 200, StringLength[text]]}];
        valStr = StringCases[sub, "value=\"" ~~ v : Shortest[__] ~~ "\"" :> v, 1];
        rgbaStr = StringCases[sub, ">" ~~ Shortest[Whitespace...] ~~ 
          r : Shortest[__] ~~ "<" :> r, 1];
        If[Length[valStr] > 0 && Length[rgbaStr] > 0,
          Quiet[Check[
            Module[{val, rgbaNums},
              val = Round[ToExpression[valStr[[1]]]];
              rgbaNums = ToExpression /@ StringTrim /@ StringSplit[rgbaStr[[1]], ","];
              If[Length[rgbaNums] >= 3 && AllTrue[rgbaNums, NumericQ],
                colors[val] = RGBColor @@ (rgbaNums[[;; 3]] / 255.0)
              ];
            ],
            Null  (* ignore parse errors *)
          ]]
        ];
        , {cp, colorPositions}
      ];
    ];
    
    (* Build metadata *)
    meta = <|
      "name" -> name,
      "comment" -> comment,
      "geometryType" -> geomType,
      "cellRange" -> cellRange,
      "offsetValues" -> offsets,
      "infixExpression" -> expr,
      "ruleType" -> ruleType,
      "numStates" -> numStates,
      "stateColors" -> colors,
      "cellFileSrc" -> extractAttr[text, "CellFile", "src"],
      "filePath" -> path
    |>;
    
    (* Build rule *)
    If[ruleType === "PCA5",
      rule = CreatePCA5Rule[<|
        "transitionRules" -> rules,
        "rotational" -> rotational,
        "numStates" -> numStates
      |>];
      ,
      rule = CreateCARule[<|
        "type" -> ruleType,
        "transitionRules" -> rules,
        "rotational" -> rotational,
        "undefinedDefault" -> If[undefDefault === "same" || undefDefault === "", 
          "same", 
          Quiet[Check[Round[ToExpression[StringTrim[undefDefault, ("(" | ")" | " ")]]], 0]]
        ],
        "defaultValue" -> 0,
        "numStates" -> numStates
      |>];
    ];
    
    <|"rule" -> rule, "metadata" -> meta|>
  ]];

(* Load .caconf configuration file *)
LoadiOSConfigFile[path_String, graph_Association] := 
  Module[{text, tiles, nTiles, isPCA5, defaultVec, state, cells, tileType},
    text = readiOSFile[path];
    tiles = graph["tiles"];
    nTiles = Length[tiles];
    tileType = tiles[[1]]["type"];
    
    (* Parse default value *)
    defaultVec = ToExpression /@ StringCases[
      extractAttr[text, "Configuration", "defaultValue"],
      x : (DigitCharacter | "-" | ".").. :> x];
    isPCA5 = Length[defaultVec] >= 5;
    
    (* Parse cell values — position-based *)
    cells = Association[];
    Module[{valPositions, sub, nameStr, valsStr},
      valPositions = StringPosition[text, "<Value"];
      Do[
        sub = StringTake[text, {vp[[1]], Min[vp[[1]] + 400, StringLength[text]]}];
        nameStr = StringCases[sub, "name=\"" ~~ n : Shortest[__] ~~ "\"" :> n, 1];
        valsStr = StringCases[sub, ">" ~~ Shortest[Whitespace...] ~~ 
          v : Shortest[__] ~~ "</Value" :> v, 1];
        If[Length[nameStr] > 0 && Length[valsStr] > 0,
          Quiet[
            cells[nameStr[[1]]] = Round /@ (ToExpression /@ 
              StringCases[valsStr[[1]], x : (DigitCharacter | "-" | ".").. :> x])
          ]
        ];
        , {vp, valPositions}
      ];
    ];
    
    (* Initialize state *)
    If[isPCA5,
      state = Table[Round /@ defaultVec, nTiles];
      ,
      state = Table[If[Length[defaultVec] > 0, Round[defaultVec[[1]]], 0], nTiles];
    ];
    
    (* Map cell names to tile indices *)
    If[tileType === "Square" && Length[tiles[[1]]["label"]] <= 2,
      (* Square grid: name = "col,row" *)
      Do[
        Module[{parts, col, row, idx},
          parts = Round[ToExpression /@ StringSplit[key, ","]];
          If[Length[parts] >= 2,
            (* Find matching tile by vertex position *)
            Do[
              Module[{v = tiles[[i]]["vertices"][[1]]},
                If[Round[v[[1]]] == parts[[1]] && Round[v[[2]]] == parts[[2]],
                  If[isPCA5,
                    state[[i]] = cells[key],
                    state[[i]] = Round[cells[key][[1]]]
                  ];
                ];
              ];
              , {i, 1, nTiles}
            ];
          ];
        ];
        , {key, Keys[cells]}
      ];
      ,
      (* Rhomb tiles (Penrose/AB/etc): name = "k0,...,kN,r,s" *)
      Do[
        Module[{parts, label},
          parts = Round[ToExpression /@ StringSplit[key, ","]];
          If[Length[parts] >= 6,
            Do[
              label = tiles[[i]]["label"];
              If[label === parts,
                If[isPCA5,
                  state[[i]] = cells[key],
                  state[[i]] = Round[cells[key][[1]]]
                ];
              ];
              , {i, 1, nTiles}
            ];
          ];
        ];
        , {key, Keys[cells]}
      ];
    ];
    
    state
  ];

(* Save rule to iOS format *)
SaveiOSRuleFile[path_String, rule_Association, meta_Association:{}] := 
  Module[{lines, rtype, geom, rotStr, rules, isPCA5},
    rtype = Lookup[meta, "ruleType", rule["type"]];
    isPCA5 = (rtype === "PCA5");
    geom = Lookup[meta, "geometryType", "Square"];
    rotStr = If[TrueQ[rule["rotational"]], "YES", "NO"];
    
    lines = {
      "<CellularAutomaton>",
      "\t<Header>",
      "\t\t<n>" <> Lookup[meta, "name", "Exported Rule"] <> "</n>",
      "\t\t<comment>" <> Lookup[meta, "comment", ""] <> "</comment>",
      "\t</Header>",
      "\t<Geometry type=\"" <> geom <> "\">",
      "\t\t<cellRange>{{0, 0}, {30, 30}}</cellRange>"
    };
    
    If[KeyExistsQ[meta, "offsetValues"],
      AppendTo[lines, "\t\t<offsetValues>" <> 
        StringRiffle[ToString /@ meta["offsetValues"], ", "] <> "</offsetValues>"]
    ];
    AppendTo[lines, "\t</Geometry>"];
    
    (* Rule section *)
    If[isPCA5,
      AppendTo[lines, "\t<Rule>"];
      AppendTo[lines, "\t\t<defaultValue>(0, 0, 0, 0, 0)</defaultValue>"];
      AppendTo[lines, "\t\t<infixExpression>"];
      AppendTo[lines, "\t\t\t(c, n, e, s, w) = hash(c(), N().s, E().w, S().n, W().e)"];
      AppendTo[lines, "\t\t</infixExpression>"];
      ,
      AppendTo[lines, "\t<Rule>"];
      AppendTo[lines, "\t\t<defaultValue>0.00</defaultValue>"];
      AppendTo[lines, "\t\t<infixExpression>"];
      AppendTo[lines, "\t\t\t" <> Lookup[meta, "infixExpression", 
        "(c, n, e, s, w) = hash(center(), N(), E(), S(), W())"]];
      AppendTo[lines, "\t\t</infixExpression>"];
    ];
    
    AppendTo[lines, "\t\t<Hash>"];
    AppendTo[lines, "\t\t\t<undefinedDefault>" <> 
      If[isPCA5, "(0, 0, 0, 0, 0)", "0.00"] <> "</undefinedDefault>"];
    AppendTo[lines, "\t\t\t<rotational>" <> rotStr <> "</rotational>"];
    AppendTo[lines, "\t\t\t<transitionRules>"];
    
    (* Write rules *)
    rules = Lookup[rule, "transitionRules", {}];
    Do[
      Module[{lhs, rhs, lhsStr, rhsStr},
        lhs = r[[1]]; rhs = r[[2]];
        If[isPCA5,
          (* PCA5: (center|d1,d2,d3,d4) => (center'|d1',d2',d3',d4') *)
          lhsStr = "(" <> ToString[lhs[[1]]] <> "|" <> 
            StringRiffle[
              Map[If[MatchQ[#, Blank[]], "*", ToString[#]]&, lhs[[2;;]]], ","] <> ")";
          rhsStr = "(" <> ToString[rhs[[1]]] <> "|" <> 
            StringRiffle[ToString /@ rhs[[2;;]], ","] <> ")";
          ,
          (* Scalar rules *)
          lhsStr = "(" <> StringRiffle[
            Map[If[MatchQ[#, Blank[]], "*", ToString[#]]&, lhs], ","] <> ")";
          rhsStr = ToString[rhs];
        ];
        AppendTo[lines, "\t\t\t\t" <> lhsStr <> " => " <> rhsStr <> ";"];
      ];
      , {r, rules}
    ];
    
    AppendTo[lines, "\t\t\t</transitionRules>"];
    AppendTo[lines, "\t\t</Hash>"];
    AppendTo[lines, "\t</Rule>"];
    
    (* Design section *)
    AppendTo[lines, "\t<Design>"];
    AppendTo[lines, "\t\t<valueRange>(0.000, " <> 
      ToString[N[Lookup[rule, "numStates", 8] - 1]] <> ")</valueRange>"];
    If[KeyExistsQ[meta, "stateColors"],
      AppendTo[lines, "\t\t<cellFillColor>"];
      Do[
        Module[{rgb = List @@ meta["stateColors"][k]},
          AppendTo[lines, "\t\t\t<stateRGBAColor value=\"" <> 
            ToString[N[k]] <> "\">" <> 
            StringRiffle[ToString[Round[255 #]] & /@ rgb, ", "] <> 
            ", 200</stateRGBAColor>"];
        ];
        , {k, Sort[Keys[meta["stateColors"]]]}
      ];
      AppendTo[lines, "\t\t</cellFillColor>"];
    ];
    AppendTo[lines, "\t</Design>"];
    AppendTo[lines, "</CellularAutomaton>"];
    
    Export[path, StringRiffle[lines, "\n"], "Text"];
    path
  ];

(* Save state to .caconf format *)
SaveiOSConfigFile[path_String, graph_Association, state_List] := 
  Module[{tiles, nTiles, isPCA5, lines, defaultVec, tileType},
    tiles = graph["tiles"];
    nTiles = Length[tiles];
    isPCA5 = ListQ[state[[1]]] && Length[state[[1]]] >= 5;
    tileType = tiles[[1]]["type"];
    
    defaultVec = If[isPCA5, "0.00, 0.00, 0.00, 0.00, 0.00", "0.00"];
    lines = {"<Configuration defaultValue=\"" <> defaultVec <> "\">"};
    
    Do[
      Module[{sv = state[[i]], isDefault, nameStr, valStr},
        isDefault = If[isPCA5, 
          sv === {0,0,0,0,0},
          sv === 0
        ];
        If[!isDefault,
          (* Build name string *)
          If[tileType === "Square" && Length[tiles[[1]]["label"]] <= 2,
            Module[{v = tiles[[i]]["vertices"][[1]]},
              nameStr = ToString[Round[v[[1]]]] <> "," <> ToString[Round[v[[2]]]];
            ];
            ,
            nameStr = StringRiffle[ToString /@ tiles[[i]]["label"], ","];
          ];
          (* Build value string *)
          If[isPCA5,
            valStr = StringRiffle[
              ToString[NumberForm[N[#], {4, 2}]] & /@ sv, ", "];
            ,
            valStr = ToString[NumberForm[N[sv], {4, 2}]];
          ];
          AppendTo[lines, "\t<Value name=\"" <> nameStr <> "\">" <> 
            valStr <> "</Value>"];
        ];
      ];
      , {i, 1, nTiles}
    ];
    
    AppendTo[lines, "</Configuration>"];
    Export[path, StringRiffle[lines, "\n"], "Text"];
    path
  ];

(* Compute multigrid intersection points for tiles in a .caconf file *)
(* Supports both Penrose (7-element labels) and AB (6-element labels) *)
configIntersectionPoints[configPath_String] := 
  configIntersectionPoints[configPath, Automatic];

configIntersectionPoints[configPath_String, off_] := 
  Module[{text, names, allLabels, numGrids, actualOff, coords},
    text = readiOSFile[configPath];
    names = StringCases[text, 
      "name=\"" ~~ n : Shortest[__] ~~ "\"" :> n];
    If[Length[names] == 0, Return[{{4, 4}}]];
    allLabels = Quiet[Select[
      (Round[ToExpression /@ StringSplit[#, ","]] &) /@ names,
      Length[#] >= 6 &]];
    If[Length[allLabels] == 0, Return[{{4, 4}}]];
    
    numGrids = Length[allLabels[[1]]] - 2;
    If[off === Automatic,
      Module[{symOrd},
        symOrd = If[OddQ[numGrids], numGrids, 2 numGrids];
        actualOff = mgDefaultOffsets[symOrd]
      ],
      actualOff = off
    ];
    
    coords = Table[
      Module[{kk = label[[1 ;; numGrids]], 
              r = label[[numGrids + 1]], s = label[[numGrids + 2]],
              origI, origJ, ci, si, cj, sj, oi, oj, det},
        If[r > s, origI = s; origJ = r, origI = r; origJ = s];
        If[numGrids == 5,
          (* Penrose: use gridIntersection (same + offset convention as the
             Cramer's rule branch below; lines are x.e_i - offset_i = m) *)
          gridIntersection[origI, kk[[origI + 1]], origJ, kk[[origJ + 1]], actualOff],
          (* General multigrid: Cramer's rule with + offset *)
          Module[{symOrd, eV},
            symOrd = If[OddQ[numGrids], numGrids, 2 numGrids];
            eV = mgEVec[symOrd];
            ci = eV[[origI + 1, 1]]; si = eV[[origI + 1, 2]];
            cj = eV[[origJ + 1, 1]]; sj = eV[[origJ + 1, 2]];
            oi = actualOff[[origI + 1]]; oj = actualOff[[origJ + 1]];
            det = ci sj - cj si;
            If[Abs[det] < 1.0*^-10, {4, 4},
              {((kk[[origI + 1]] + oi) sj - (kk[[origJ + 1]] + oj) si) / det,
               ((kk[[origJ + 1]] + oj) ci - (kk[[origI + 1]] + oi) cj) / det}
            ]
          ]
        ]
      ],
      {label, allLabels}
    ];
    coords
  ];

(* 2-arg: keep size, shift origin to center intersection points *)
InferCellRangeFromConfig[configPath_String, {width_Integer, height_Integer}] := 
  Module[{coords, centroid, xmin, ymin},
    coords = configIntersectionPoints[configPath];
    centroid = Mean[coords];
    xmin = Floor[centroid[[1]] - width / 2];
    ymin = Floor[centroid[[2]] - height / 2];
    {xmin, ymin, width, height}
  ];

(* 1-arg: minimal bounding range of intersection points *)
InferCellRangeFromConfig[configPath_String] := 
  Module[{coords, margin = 2},
    coords = configIntersectionPoints[configPath];
    {Floor[Min[coords[[All, 1]]] - margin], 
     Floor[Min[coords[[All, 2]]] - margin],
     Ceiling[Max[coords[[All, 1]]] - Floor[Min[coords[[All, 1]]]] + 2 margin],
     Ceiling[Max[coords[[All, 2]]] - Floor[Min[coords[[All, 2]]]] + 2 margin]}
  ];

End[];
EndPackage[];
