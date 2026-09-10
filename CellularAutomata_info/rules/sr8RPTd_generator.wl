(* Build SR8-RPTd (9-state docking/closure extension): rule table -> sr8RPTd.txt,
   injectivity report, and videos of (1) worm->loop docking + self-closure and
   (2) deg-4 loop absorbing its returning wanderer. *)
$packageDirectory = "F:/Dropbox/Mathematica-oneDrive/MyPackages";
AppendTo[$Path, $packageDirectory];
Block[{$CharacterEncoding = "UTF-8"},
  Needs["CellularAutomata`", FileNameJoin[{$packageDirectory, "CellularAutomata.wl"}]];
  Needs["TurtleTiling`", FileNameJoin[{$packageDirectory, "TurtleTiling.wl"}]]];
rulesDir = FileNameJoin[{$packageDirectory, "CellularAutomata_info", "rules"}];
outDir = DirectoryName[$InputFileName];
OFFS = {0, 0.1, -0.1, 0.2, -0.2};
q = {0, 0, 0, 0, 0};
d0 = LoadiOSRuleFile[FileNameJoin[{rulesDir, "sr8RPT.txt"}]];
base = d0["rule"]["transitionRules"];
LK = Association[Rule @@@ base];
RHS = Association[Table[r[[2]] -> r[[1]], {r, base}]];
rotT[t_, k_] := Prepend[RotateRight[t[[2 ;; 5]], k], t[[1]]];
DESIGNEDLHS = Association[]; NCLASH = 0; NADDED = 0; DESIGNEDLIST = {};
(* a class is admissible only if lhs and rhs have the same rotational stabilizer
   (same number of distinct rotations); otherwise one LHS would get two outputs
   or two LHS the same output (e.g. C-signal 3 + photon 3 opposite each other) *)
symOK[lhs_, rhs_] := Length[DeleteDuplicates[Table[rotT[lhs, k], {k, 0, 3}]]] ==
  Length[DeleteDuplicates[Table[rotT[rhs, k], {k, 0, 3}]]];
addClass[lhs_, rhs_, tag_] := Module[{ok = symOK[lhs, rhs]},
  Do[Module[{li = rotT[lhs, k], ro = rotT[rhs, k]},
     If[KeyExistsQ[LK, li] && LK[li] =!= ro, ok = False];
     If[KeyExistsQ[RHS, ro] && RHS[ro] =!= li, ok = False]], {k, 0, 3}];
  If[ok,
    Do[Module[{li = rotT[lhs, k], ro = rotT[rhs, k]},
       LK[li] = ro; RHS[ro] = li; DESIGNEDLHS[li] = tag], {k, 0, 3}];
    AppendTo[DESIGNEDLIST, {tag, lhs, rhs}]; NADDED++,
    NCLASH++; Print["CLASH (", tag, "): ", lhs, " -> ", rhs]];
  ok];
addClassQuiet[lhs_, rhs_] := Module[{ok = symOK[lhs, rhs]},
  Do[Module[{li = rotT[lhs, k], ro = rotT[rhs, k]},
     If[KeyExistsQ[LK, li] && LK[li] =!= ro, ok = False];
     If[KeyExistsQ[RHS, ro] && RHS[ro] =!= li, ok = False]], {k, 0, 3}];
  If[ok, Do[Module[{li = rotT[lhs, k], ro = rotT[rhs, k]},
       LK[li] = ro; RHS[ro] = li], {k, 0, 3}]];
  ok];
M = 8;
designed = {
  {{1, 6, 0, 5, 1}, {1, 5, M, 1, 7}, "S1A"}, {{1, 7, 0, 5, 1}, {1, 5, M, 1, 3}, "S2A"},
  {{1, 6, 1, 5, 0}, {1, 5, 7, 1, M}, "S1Am"}, {{1, 7, 1, 5, 0}, {1, 5, 3, 1, M}, "S2Am"},
  {{1, 6, 5, 1, 0}, {1, 5, 1, 7, M}, "S1B"}, {{1, 7, 5, 1, 0}, {1, 5, 1, 3, M}, "S2B"},
  {{1, 6, 0, 1, 5}, {1, 5, M, 7, 1}, "S1Bm"}, {{1, 7, 0, 1, 5}, {1, 5, M, 3, 1}, "S2Bm"},
  {{1, 6, 5, 0, 1}, {1, 5, 1, M, 7}, "S1C"}, {{1, 7, 5, 0, 1}, {1, 5, 1, M, 3}, "S2C"},
  {{1, 6, 1, 0, 5}, {1, 5, 7, M, 1}, "S1Cm"}, {{1, 7, 1, 0, 5}, {1, 5, 3, M, 1}, "S2Cm"},
  {{1, 1, 7, 0, 0}, {1, 5, 0, 6, M}, "PV"}, {{1, 1, 0, 0, 7}, {1, 5, M, 6, 0}, "PVm"},
  {{1, 1, 0, 7, 0}, {4, 5, 6, 0, 0}, "PS1"},
  {{4, 1, 0, 3, 0}, {4, 5, 7, 0, 0}, "PS2v"},
  {{4, 1, 5, 0, 0}, {1, 5, 1, M, M}, "FIN"}, {{4, 1, 0, 5, 0}, {1, 5, M, 1, M}, "FINs"},
  {{4, 1, 0, 0, 5}, {1, 5, M, M, 1}, "FINm"},
  {{6, 7, 0, 0, 0}, {0, 0, M, M, M}, "TVAN"},
  {{0, 5, 0, 0, 0}, {0, 0, 3, 3, 3}, "Q5"},
  {{0, 3, 0, 0, 0}, {0, 0, 0, 3, 0}, "PH3"}, {{0, M, 0, 0, 0}, {0, 0, 0, M, 0}, "PH8"},
  {{0, 3, 0, 3, 0}, {0, 3, 0, 3, 0}, "PH33"}, {{0, M, 0, M, 0}, {0, M, 0, M, 0}, "PH88"},
  {{0, 3, 0, M, 0}, {0, M, 0, 3, 0}, "PH38"}, {{0, 3, 3, 0, 0}, {0, 0, 0, 3, 3}, "PH33b"},
  {{0, M, M, 0, 0}, {0, 0, 0, M, M}, "PH88b"}, {{0, 3, M, 0, 0}, {0, 0, 0, 3, M}, "PH38b"},
  {{0, M, 3, 0, 0}, {0, 0, 0, M, 3}, "PH83b"}
};
Do[addClass[d[[1]], d[[2]], d[[3]]], {d, designed}];
mkT[roles_, spec_, c_:1] := Module[{t = {c, 0, 0, 0, 0}},
  Do[t[[roles[[k]] + 1]] = spec[[k]], {k, 4}]; t];
Do[
  Module[{a = p[[1]], b = p[[2]], f = p[[3]], roles},
    roles = {1, a, b, f};
    addClass[mkT[roles, {6, 5, 7, 0}], mkT[roles, {5, 1, 7, 3}], "S1T"];
    addClass[mkT[roles, {7, 5, 7, 0}], mkT[roles, {5, 1, 5, M}, 4], "S2T"]],
  {p, Permutations[{2, 3, 4}]}];
Print["designed classes: ", NADDED, " clashes: ", NCLASH];
nDesignedRules = Length[LK] - Length[base];
(* marker variants of base rules: a marker (3 or 8) entering a free slot s passes
   straight (s+2) if that slot is free in lhs and rhs, otherwise deflects to the
   first free slot in cyclic order after s (s+1, then s+3) - a rotation-invariant
   choice - and never reflects back. Added class-wise (all 4 rotations or none)
   so the table stays rotation-closed. *)
cyc[s_, d_] := Mod[s - 2 + d, 4] + 2;
nPV = 0; nPVskip = 0; seenPV = Association[];
Do[
  Do[
    Module[{lhs = r[[1]], rhs = r[[2]]},
      Do[
        If[lhs[[s]] == 0,
          Module[{lhs2 = ReplacePart[lhs, s -> mk], rhs2 = $Failed, cand},
            Do[
              If[rhs2 === $Failed && lhs[[cand]] == 0 && rhs[[cand]] == 0,
                rhs2 = ReplacePart[rhs, cand -> mk]],
              {cand, {cyc[s, 2], cyc[s, 1], cyc[s, 3]}}];
            If[rhs2 =!= $Failed && !KeyExistsQ[seenPV, lhs2],
              Do[seenPV[rotT[lhs2, k]] = True, {k, 0, 3}];
              If[addClassQuiet[lhs2, rhs2], nPV++, nPVskip++]]]],
        {s, 2, 5}]],
    {r, base}],
  {mk, {3, M}}];
Print["marker variant classes: added=", nPV, " skipped=", nPVskip];
allRules = Normal[LK];
injective = Length[DeleteDuplicates[allRules[[All, 1]]]] == Length[allRules] &&
  Length[DeleteDuplicates[allRules[[All, 2]]]] == Length[allRules];
Print["TOTAL rules=", Length[LK], "  injective=", injective];
rotOK = AllTrue[allRules, Function[r, AllTrue[Range[3], Function[k,
  KeyExistsQ[LK, rotT[r[[1]], k]] && LK[rotT[r[[1]], k]] === rotT[r[[2]], k]]]]];
Print["rotation-closed: ", rotOK];

(* ---- write sr8RPTd.txt ---- *)
fmt[t_] := "(" <> ToString[t[[1]]] <> "|" <> StringRiffle[ToString /@ t[[2 ;; 5]], ","] <> ")";
baseLK = Association[Rule @@@ base];
newRules = Sort[Select[allRules, !KeyExistsQ[baseLK, #[[1]]] &]];
lines = StringRiffle[Table["\t\t\t\t" <> fmt[r[[1]]] <> " => " <> fmt[r[[2]]] <> ";",
  {r, newRules}], "\n"];
srcTxt = Import[FileNameJoin[{rulesDir, "sr8RPT.txt"}], "Text"];
newTxt = StringReplace[srcTxt, {
  "<name>Self-Reproducing RPCA SR8</name>" ->
    "<name>SR8 RPTd: 9-state docking/closure extension</name>",
  "<cellRange>{{0, 0}, {6, 8}}</cellRange>" -> "<cellRange>{{-16, -16}, {40, 40}}</cellRange>",
  "<CellFile src=\"sr8RPT130213173209\">" -> "<CellFile src=\"sr8RPT-loop-deg4-DB\">",
  "<valueRange>(0.000, 7.000)</valueRange>" -> "<valueRange>(0.000, 8.000)</valueRange>",
  "</cellFillColor>" -> "	<stateRGBAColor value=\"8.000\">255,   0, 255, 200</stateRGBAColor>
			</cellFillColor>",
  "%  There are 765 rules. ;" ->
    "%  There are 765 rules. ;\n\t\t\t\t% (8) RPTd designed rules: splice-and-cut docking / self-closure\n\t\t\t\t% (state 8 = trace marker, 3 = photon in empty space), plus marker\n\t\t\t\t% pass-through/deflection variants of base rules. Injective. ;\n" <>
    lines <> "\n\t\t\t\t%  RPTd: " <> ToString[Length[newRules]] <> " added (total " <>
    ToString[Length[LK]] <> "). ;"}];
Export[FileNameJoin[{rulesDir, "sr8RPTd.txt"}], newTxt, "Text"];
Print["saved sr8RPTd.txt (+", Length[newRules], ")"];
Export[FileNameJoin[{rulesDir, "sr8RPTd_designed_classes.txt"}],
  StringRiffle[Table[StringPadRight[d[[1]], 6] <> fmt[d[[2]]] <> " => " <> fmt[d[[3]]],
    {d, DESIGNEDLIST}], "\n"], "Text"];

(* ---- simulation + video ---- *)
tl = GeneratePenroseRhombs[{-16, -16, 40, 40}, OFFS];
n = Length[tl];
g = BuildTilingGraph[tl];
NB = g["neumannNeighbors"];
PM = CellularAutomata`Private`buildPCA5MapEdge[g];
cents = Table[Mean[tl[[i]]["vertices"]], {i, n}];
nav = BuildTurtleNav[g]; e2n = nav["edgeToNbr"]; winds = nav["windings"];
tstep = TurtleTiling`Private`turtleStep;
ribbon[c_, e_, m_] := Module[{st = {c, e}, out = {c}},
  Do[st = tstep[e2n, winds, st, "S"]; If[st === $Failed, Break[]];
     AppendTo[out, st[[1]]], {m}]; out];
NMISS = 0;
step[assoc_] := Module[{cands, out = Association[], inp, o},
  cands = DeleteDuplicates[Flatten[Table[Prepend[NB[c], c], {c, Keys[assoc]}]]];
  Do[
    inp = q; inp[[1]] = Lookup[assoc, c, q][[1]];
    Do[Module[{sl = PM[c][k], stk = Lookup[assoc, k, q]},
       inp[[sl[[1]]]] = stk[[sl[[2]]]]], {k, NB[c]}];
    If[inp =!= q,
      o = Lookup[LK, Key[inp], Missing[]];
      If[MissingQ[o], NMISS++; o = q];
      If[o =!= q, out[c] = o]],
    {c, cands}];
  out];
vk = Association[];
Do[Do[Module[{k = tl[[i]]["vertexKeys"][[j]]},
    If[KeyExistsQ[vk, k], AppendTo[vk[k], {i, j}], vk[k] = {{i, j}}]],
    {j, 4}], {i, n}];
mkVertexLoop[k_] := Module[{ts = vk[k], vpos},
  vpos = tl[[ts[[1, 1]]]]["vertices"][[ts[[1, 2]]]];
  SortBy[ts[[All, 1]], ArcTan @@ (cents[[#]] - vpos) &]];
placeLoop[cells_List] := Module[{a = Association[], L = Length[cells], nx, pv},
  Do[nx = cells[[Mod[i, L] + 1]]; pv = cells[[Mod[i - 2, L] + 1]];
    a[cells[[i]]] = ReplacePart[q, {1 -> 1, PM[cells[[i]]][nx][[1]] -> 1,
      PM[cells[[i]]][pv][[1]] -> 5}], {i, L}]; a];
placeWorm[cells_List] := Module[{a = Association[], L = Length[cells]},
  a[cells[[1]]] = ReplacePart[q, {1 -> 5, PM[cells[[1]]][cells[[2]]][[1]] -> 7}];
  Do[a[cells[[i]]] = ReplacePart[q, {1 -> 1,
      PM[cells[[i]]][cells[[i - 1]]][[1]] -> 5,
      PM[cells[[i]]][cells[[i + 1]]][[1]] -> 1}], {i, 2, L - 1}];
  a[cells[[L]]] = ReplacePart[q, {1 -> 7, PM[cells[[L]]][cells[[L - 1]]][[1]] -> 5}];
  a];

pca5Polys = CellularAutomata`Private`precomputePCA5Polygons[g];
cellPolys = Table[tl[[k2]]["vertices"], {k2, n}];
cols = Join[CellularAutomata`Private`defaultCAColorAssoc, d0["metadata"]["stateColors"],
  <|8 -> RGBColor[1, 0, 1], 8. -> RGBColor[1, 0, 1]|>];
IMGW = 840;
mkBG[clip_] := UsingFrontEnd[Rasterize[
  CellularAutomata`Private`renderPCA5Clipped[pca5Polys, cellPolys,
    Table[q, {n}], cols, {}, clip, IMGW]]];
mkOverlay[assoc_, clip_, bg_, bgDim_] := Module[{gr, ov},
  gr = Graphics[{
      EdgeForm[],
      KeyValueMap[Function[{i, sv},
        Table[{Lookup[cols, sv[[p]], GrayLevel[0.5]],
           Polygon[pca5Polys[[i, p]]]}, {p, 1, 5}]], assoc],
      {RGBColor[0.35, 0.3, 0.25], AbsoluteThickness[0.7],
       KeyValueMap[Function[{i, sv},
         Line[Append[cellPolys[[i]], cellPolys[[i, 1]]]]], assoc]}
    },
    AspectRatio -> Automatic, PlotRange -> clip,
    PlotRangePadding -> 0, ImageSize -> IMGW, Background -> None];
  ov = UsingFrontEnd[Rasterize[gr, Background -> None]];
  If[ImageDimensions[ov] =!= bgDim, ov = ImageResize[ov, bgDim]];
  ImageCompose[bg, ov]];
mkVideo[init_, clip_, windows_, fname_] := Module[
  {bg = mkBG[clip], bgDim, st = init, frames = {}, tmax = Max[windows[[All, 2]]]},
  bgDim = ImageDimensions[bg];
  NMISS = 0;
  If[AnyTrue[windows, #[[1]] <= 0 &], AppendTo[frames, mkOverlay[st, clip, bg, bgDim]]];
  Do[
    st = step[st];
    Do[If[w[[1]] <= t <= w[[2]] && Mod[t, w[[3]]] == 0,
        AppendTo[frames, mkOverlay[st, clip, bg, bgDim]]], {w, windows}];
    Do[If[t == w[[2]] && w =!= Last[windows],
        frames = Join[frames, ConstantArray[frames[[-1]], 10]]], {w, windows}];
    If[st === Association[], Break[]],
    {t, 1, tmax}];
  frames = Join[ConstantArray[frames[[1]], 9], frames, ConstantArray[frames[[-1]], 15]];
  Export[FileNameJoin[{outDir, fname}], frames, "MP4", "FrameRate" -> 10];
  Print["saved ", fname, " frames=", Length[frames], " misses=", NMISS]];

(* video 1: worm -> deg-5 loop docking, merged worm, self-closure *)
k5 = SelectFirst[Keys[vk], Length[vk[#]] == 5 && MemberQ[vk[#][[All, 1]], 4122] &];
loopCells = mkVertexLoop[k5];
rb = ribbon[4122, 1, 12];
init1 = Join[placeLoop[loopCells], placeWorm[{rb[[8]], rb[[7]], rb[[6]]}]];
ctr1 = Mean[cents[[loopCells]]];
mkVideo[init1, {{ctr1[[1]] - 10, ctr1[[1]] + 10}, {ctr1[[2]] - 10, ctr1[[2]] + 10}},
  {{0, 260, 1}}, "sr8RPTd-dock-and-close.mp4"];

(* video 2: deg-4 loop + DB; wanderer returns and is absorbed (t~4285) *)
Module[{stt = LoadiOSConfigFile[FileNameJoin[{rulesDir, "sr8RPT-loop-deg4-DB.caconf"}], g], a, ctr},
  a = Association[Table[If[stt[[i]] =!= q, i -> stt[[i]], Nothing], {i, n}]];
  ctr = Mean[cents[[Keys[a]]]];
  mkVideo[a, {{ctr[[1]] - 13, ctr[[1]] + 13}, {ctr[[2]] - 4, ctr[[2]] + 22}},
    {{0, 200, 2}, {4240, 4440, 1}}, "sr8RPTd-wanderer-absorbed.mp4"]];
Print["done"];
