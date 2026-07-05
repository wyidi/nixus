{ lib, ... }: with lib; let
  # hint: mapAttrsToList, listToAttrs
  # hint: neighbors is a set
  # hint: zipAttrsWith to finish (flatten when merging)
  reverse = graph: let
    lst1 = mapAttrsToList (vertex: map (neighbor: { ${neighbor} = vertex; }) graph;
    lst2 = map listToAttrs lst1;
  in 
    zipAttrsWith (xs: uniqueStrings (concatLists xs)) lst2;

  linearize = graph: let
    vertices = attrNames graph;
    graph'   = reverse   graph;
  in 
    foldl TODO { tree = {}; } vertices;

in {
  inherit linearize;
}
