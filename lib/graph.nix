{ lib, ... }: with lib; let

  reverse = graph: let 
    # hint: neighbors is a set represented as list
    lst1 = mapAttrsToList (vertex: map (neighbor: { name = neighbor; value = [ vertex ]; })) graph;
    lst2 = map listToAttrs lst1;
    lst3 = [(mapAttrs (_: _: []) graph)] ++ lst2;
  in 
    zipAttrsWith (_: xs: uniqueStrings (concatLists xs)) lst3;

  linearize = graph: TODO;

in {
  inherit reverse;
  inherit linearize;
}
