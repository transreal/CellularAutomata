# Usage Examples

[日本語](../../examples/example.md) | **English**

This document introduces the main features of the CellularAutomata package through practical examples.

## 1. Generating and drawing a Penrose rhombus tiling

Generate and visualize a basic Penrose tiling.

```mathematica
tiles = GeneratePenroseRhombs[{0, 0, 800, 600}, {0, 0, 0, 0, 0}];
DrawPenroseTiling[tiles]
```

A Graphics object of a Penrose tiling consisting of roughly 400–600 tiles is produced.

## 2. Building and analyzing the neighborhood graph

Build the neighborhood relations from the tiling and classify the neighborType of each tile.

```mathematica
graph = BuildTilingGraph[tiles];
neighborTypes = Table[NeighborType[graph, i], {i, Length[tiles]}];
Counts[neighborTypes]
```

The number of occurrences of each neighborType is returned as an Association (e.g. <|0 -> 45, 1 -> 78, ...|>).

## 3. Creating and evolving a cellular automaton rule

Create and run a rule similar to Conway's Game of Life.

```mathematica
rule = CreateCARule[<|"transitionRules" -> {{0, 3} -> 1, {1, 2} -> 1, {1, 3} -> 1}, 
  "rotational" -> False, "undefinedDefault" -> 0, "defaultValue" -> 0|>];
initState = RandomChoice[{0, 1}, Length[tiles]];
evolution = CAEvolve[graph, rule, initState, 10];
```

The results of 10 evolution steps are returned as a list (each step is an array whose length equals the number of tiles).

## 4. Generating a kite & dart tiling

Generate a Penrose tiling in kite & dart form.

```mathematica
kdTiles = GeneratePenroseKD[{0, 0, 600, 450}, {0, 0, 0, 0, 0}];
DrawPenroseKD[kdTiles]
```

A Graphics object color-coded by kites (blue) and darts (red) is produced.

## 5. Building neighborhood graphs on a square grid

Generate a square grid and build its Moore and Neumann neighborhoods.

```mathematica
squareTiles = GenerateSquareGrid[10, 8];
squareGraph = BuildSquareGridGraph[squareTiles, 10, 8];
MooreNeighbors[squareGraph, 45]
```

A list of indices of the Moore neighbors (8 directions) of tile 45 is returned.

## 6. True five-neighbor partitioned cellular automata

Create a PCA5 rule in which each cell has a center part and four directional parts.

```mathematica
pca5Rule = CreatePCA5Rule[<|"transitionRules" -> {
  {0, 0, 0, 0, 0} -> {1, 0, 0, 0, 0}, {1, 1, 1, 1, 1} -> {0, 0, 0, 0, 0}}, 
  "rotational" -> True, "numStates" -> 2, "defaultValue" -> {0, 0, 0, 0, 0}|>];
initState = Table[{RandomChoice[{0, 1}], 0, 0, 0, 0}, Length[squareTiles]];
```

An initial state is produced in which each cell has five components: {center, north, east, south, west}.

## 7. Loading rule files from the iOS app

Load a rule file from the iOS CA Simulator app.

```mathematica
ruleData = LoadiOSRuleFile["example.txt"];
rule = ruleData["rule"];
metadata = ruleData["metadata"]
```

The rule object is returned together with metadata such as the geometry type, color settings, and name.

## 8. Interactive simulator

Launch the CA simulator and run it interactively.

```mathematica
CASimulator[graph, rule]
```

A DynamicModule is displayed with play/pause buttons, step execution, and reset to the initial state.
