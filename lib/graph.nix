{ lib, ... }: with lib; let

  reverse = graph: let
    # Hint: neighbors is a set represented as list
    lst1 = mapAttrsToList (vertex: map (neighbor: { name = neighbor; value = [ vertex ]; })) graph;
    lst2 = map listToAttrs lst1;
    lst3 = [(mapAttrs (_: _: []) graph)] ++ lst2; # ensures that node with no edge holds empty list
  in
    # uniqueStrings is not needed since duplicate will be removed at lst2
    zipAttrsWith (_: concatLists) lst3;

in {
  inherit reverse;
}
