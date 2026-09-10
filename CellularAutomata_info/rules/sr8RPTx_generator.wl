(* Generate SR8-RPTx: complete SR8's rule table over all inputs reached by the
   RPT loop/worm battery, injectively (reversibility preserved).
   Policy: identity ("reflect/freeze") output; on RHS collision, deterministic
   center-substitution fallback (8 candidates). Rules are added with all 4
   rotations; the produced table is machine-verified injective.
   IMPORTANT (2026-09-01): do NOT widen the fallback beyond center
   substitution. A wider tier (uniform nonzero-part shifts, 64 candidates)
   was tried and causes a junk epidemic: debris survives instead of hitting
   a still-undefined input, spreads to the whole region (~36k active cells).
   The inputs left undefined by the narrow fallback act as absorbers that
   keep fossils compact -- the same status as SR8's own undefined inputs. *)
$packageDirectory = "F:/Dropbox/Mathematica-oneDrive/MyPackages";
AppendTo[$Path, $packageDirectory];
Block[{$CharacterEncoding = "UTF-8"},
  Needs["CellularAutomata`", FileNameJoin[{$packageDirectory, "CellularAutomata.wl"}]]];
rulesDir = FileNameJoin[{$packageDirectory, "CellularAutomata_info", "rules"}];
OFFS = {0, 0.1, -0.1, 0.2, -0.2};
q = {0, 0, 0, 0, 0};
d0 = LoadiOSRuleFile[FileNameJoin[{rulesDir, "sr8RPT.txt"}]];
base = d0["rule"]["transitionRules"];
LK = Association[Rule @@@ base];
Print["base rules: ", Length[LK]];
RHSUSED = Association[Table[r[[2]] -> True, {r, base}]];
Print["base RHS distinct: ", Length[RHSUSED] == Length[base]];

rotT[t_, k_] := Prepend[RotateRight[t[[2 ;; 5]], k], t[[1]]];

ADDED = {};   (* list of canonical class records {inp, out} *)
FAILED = Association[];
(* candidate outputs, symmetry-preserving: identity, then center substitution
   (see header: keep this list NARROW on purpose) *)
candList[inp_] := Table[ReplacePart[inp, 1 -> Mod[inp[[1]] + d, 8]], {d, 0, 7}];
addRuleFor[inp_] := Module[{done = False},
  Do[
    Module[{outs = Table[rotT[cand, k], {k, 0, 3}], ok},
      ok = AllTrue[DeleteDuplicates[outs], !KeyExistsQ[RHSUSED, #] &];
      If[ok,
        Do[
          Module[{li = rotT[inp, k], ro = rotT[cand, k]},
            If[!KeyExistsQ[LK, li],
              LK[li] = ro; RHSUSED[ro] = True]],
          {k, 0, 3}];
        AppendTo[ADDED, {inp, cand}];
        done = True; Break[]]],
    {cand, candList[inp]}];
  If[!done, FAILED[inp] = Lookup[FAILED, Key[inp], 0] + 1];
  done];

tl = GeneratePenroseRhombs[{-32, -32, 72, 72}, OFFS];
n = Length[tl]; Print["tiles: ", n];
g = BuildTilingGraph[tl];
NB = g["neumannNeighbors"];
PM = CellularAutomata`Private`buildPCA5MapEdge[g];
cents = Table[Mean[tl[[i]]["vertices"]], {i, n}];

(* learning stepper: on miss, add rule and APPLY it *)
NMISS = 0;
learnStep[assoc_] := Module[{cands, out = Association[], inp, o},
  cands = DeleteDuplicates[Flatten[Table[Prepend[NB[c], c], {c, Keys[assoc]}]]];
  Do[
    inp = q; inp[[1]] = Lookup[assoc, c, q][[1]];
    Do[Module[{sl = PM[c][k], stk = Lookup[assoc, k, q]},
       inp[[sl[[1]]]] = stk[[sl[[2]]]]], {k, NB[c]}];
    If[inp =!= q,
      o = Lookup[LK, Key[inp], Missing[]];
      If[MissingQ[o],
        NMISS++;
        If[addRuleFor[inp], o = LK[inp], o = q]];
      If[o =!= q, out[c] = o]],
    {c, cands}];
  out];

nComps[cells_List] := Length[ConnectedComponents[
  Graph[cells, UndirectedEdge @@@
    Select[Subsets[cells, {2}], MemberQ[NB[#[[1]]], #[[2]]] &]]]];

vk = Association[];
Do[Do[Module[{k = tl[[i]]["vertexKeys"][[j]]},
    If[KeyExistsQ[vk, k], AppendTo[vk[k], {i, j}], vk[k] = {{i, j}}]],
    {j, 4}], {i, n}];
target = {4., 4.};
mkVertexLoop[k_] := Module[{ts = vk[k], vpos},
  vpos = tl[[ts[[1, 1]]]]["vertices"][[ts[[1, 2]]]];
  SortBy[ts[[All, 1]], ArcTan @@ (cents[[#]] - vpos) &]];
deepKeys = Select[Keys[vk],
  Function[k, 3 <= Length[vk[k]] <= 7 &&
    AllTrue[vk[k][[All, 1]], Function[t, Length[NB[t]] == 4]] &&
    Norm[Mean[cents[[vk[k][[All, 1]]]]] - target] < 6]];
byDeg = GroupBy[deepKeys, Length[vk[#]] &];
placeGene[cells_List, s_] := Module[{a = Association[], L = Length[cells], nx, pv},
  Do[
    nx = cells[[Mod[i, L] + 1]]; pv = cells[[Mod[i - 2, L] + 1]];
    a[cells[[i]]] = ReplacePart[q,
      {1 -> If[i == s, 2, 1],
       PM[cells[[i]]][nx][[1]] -> If[i == s, 4, 1],
       PM[cells[[i]]][pv][[1]] -> 5}],
    {i, L}];
  a];

runB[label_, init_, steps_] := Module[{st = init, m0 = NMISS, a0 = Length[ADDED]},
  Do[
    st = learnStep[st];
    If[st === Association[], Break[]],
    {t, 1, steps}];
  Print[label, ": misses=", NMISS - m0, " newClasses=", Length[ADDED] - a0,
    " finalAct=", Length[st],
    " comps=", If[st === Association[], 0, nComps[Keys[st]]]]];

(* ---- battery ---- *)
Do[
  Module[{ks = Take[Lookup[byDeg, deg, {}], UpTo[2]]},
    Do[
      Module[{cells = mkVertexLoop[k]},
        Do[
          runB["loop deg" <> ToString[deg] <> " s" <> ToString[s],
            placeGene[cells, s], 2000],
          {s, 1, Length[cells]}]],
      {k, ks}]],
  {deg, {3, 4, 5, 6, 7}}];

(* deg-4 long case *)
Module[{cells = mkVertexLoop[{1, 4, 3, -2, -2}]},
  runB["loop deg4 best (6000)", placeGene[cells, 2], 6000]];

(* worm configs *)
Do[
  Module[{stt = LoadiOSConfigFile[FileNameJoin[{rulesDir, f}], g], a},
    a = Association[Table[
      If[stt[[i]] =!= q, i -> stt[[i]], Nothing], {i, n}]];
    If[Length[a] > 0, runB[f, a, 1500],
      Print[f, ": no cells in region, skipped"]]],
  {f, {"sr8RPT-ribbonworm-straight.caconf", "sr8RPT-ribbonworm-branch2.caconf",
       "sr8RPT-ribbonworm-branch3.caconf", "sr8RPT-ribbonworm-branch2-L8.caconf",
       "sr8RPT-ribbonworm-branch3-L8.caconf", "sr8RPT-loop-deg4-DB.caconf"}}];

Print["=== learning done: added classes=", Length[ADDED],
  "  total rules=", Length[LK], "  distinct failed classes=", Length[FAILED], " ==="];
Print["identity classes: ", Count[ADDED, a_ /; a[[1]] === a[[2]]],
  "  center-sub classes: ",
  Count[ADDED, a_ /; a[[1]] =!= a[[2]] && a[[1, 2 ;; 5]] === a[[2, 2 ;; 5]]],
  "  part-shift classes: ",
  Count[ADDED, a_ /; a[[1, 2 ;; 5]] =!= a[[2, 2 ;; 5]]]];
If[Length[FAILED] > 0,
  Do[Print["  STILL FAILED: ", k2, " (", FAILED[k2], " events)"],
    {k2, Keys[FAILED]}]];

(* injectivity verification *)
allRules = Normal[LK];
Print["INJECTIVITY: LHS distinct=", Length[DeleteDuplicates[allRules[[All, 1]]]],
  "/", Length[allRules],
  "  RHS distinct=", Length[DeleteDuplicates[allRules[[All, 2]]]],
  "/", Length[allRules]];

(* ---- write sr8RPTx.txt ---- *)
fmt[t_] := "(" <> ToString[t[[1]]] <> "|" <>
  StringRiffle[ToString /@ t[[2 ;; 5]], ","] <> ")";
addedLines = StringRiffle[
  Table["\t\t\t\t" <> fmt[r[[1]]] <> " => " <> fmt[r[[2]]] <> ";",
    {r, Sort[Select[Normal[LK], !KeyExistsQ[Association[Rule @@@ base], #[[1]]] &]]}],
  "\n"];
nAddedRules = Length[LK] - Length[base];
srcTxt = Import[FileNameJoin[{rulesDir, "sr8RPT.txt"}], "Text"];
newTxt = StringReplace[srcTxt, {
  "<name>Self-Reproducing RPCA SR8</name>" ->
    "<name>Self-Reproducing RPCA SR8 RPTx (auto-completed)</name>",
  "<cellRange>{{0, 0}, {6, 8}}</cellRange>" ->
    "<cellRange>{{-16, -16}, {40, 40}}</cellRange>",
  "<CellFile src=\"sr8RPT130213173209\">" ->
    "<CellFile src=\"sr8RPT-loop-deg4-DB\">",
  "%  There are 765 rules. ;" ->
    "%  There are 765 rules. ;\n\t\t\t\t% (8) RPTx auto-completion: reflect/freeze semantics for inputs\n\t\t\t\t% reached on the rhombic Penrose tiling; injectivity verified. ;\n" <>
    addedLines <> "\n\t\t\t\t%  RPTx: " <> ToString[nAddedRules] <>
    " added rules (total " <> ToString[Length[LK]] <> "). ;"}];
outFile = FileNameJoin[{rulesDir, "sr8RPTx.txt"}];
Export[outFile, newTxt, "Text"];
Print["saved: ", FileNameTake[outFile], "  (+", nAddedRules, " rules)"];
Print["done"];
