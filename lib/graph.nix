{ lib, ... }: with lib; let

  reverse = graph: let 
    # hint: neighbors is a set represented as list
    lst1 = mapAttrsToList (vertex: map (neighbor: { ${neighbor} = vertex; })) graph;
    lst2 = map listToAttrs lst1;
  in 
    zipAttrsWith (xs: uniqueStrings (concatLists xs)) lst2;

  linearize = graph: TODO;

in {
  inherit reverse;
  inherit linearize;
}
