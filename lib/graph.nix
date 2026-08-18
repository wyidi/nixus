{ lib, ... }: with lib; let

  reverse = graph: let 
    # hint: neighbors is a set represented as list
    lst1 = mapAttrsToList (vertex: map (neighbor: { name = neighbor; value = [ vertex ]; })) graph;
    lst2 = map listToAttrs lst1;
    lst3 = [(mapAttrs (_: _: []) graph)] ++ lst2; # ensure that node with no edge holds empty list
  in
    # uniqueStrings is not needed since duplicate will be removed at lst2
    zipAttrsWith (_: concatLists) lst3;

  linearize = graph: let
    vertices = attrNames graph;
    # A reversed graph is used to find sinks
    graph'   = reverse   graph;
    # A sink is a node that no other nodes depends on it
    sinks    = filter (x: graph'.${x} == []) vertices;

    # Outputs list of minimum heights of each node in DAG
    # TODO: add `ancestors` parameter to detect back edge (no cycle detection currently)
    getLevels = levels: queue:
      if queue == [] then
        levels
      else let e = head queue; in
        if hasAttr e levels then
          getLevels levels (drop 1 queue)
        else let parents = graph.${e}; in
          if parents == [] then
            getLevels (levels // { ${e} = 1; }) (drop 1 queue)
          else let xs = filter (x: !(hasAttr x levels)) parents; in
            if xs == [] then let lst = map (x: levels.${x}) parents; in
              # height is max heigh of parent nodes + 1
              getLevels (levels // { ${e} = 1 + (foldl max (head lst) lst); }) (drop 1 queue)
            else
              getLevels levels (xs ++ queue);

    levels  = getLevels {} sinks;

    levels' = reverseAttrs (mapAttrs (_: level: [level]) levels); 
    # mapping integer to singleton list is needed because reverAttrs assumes that value is list
  in {
    inherit  graph';
    inherit  levels;
    inherit levels';

    result = map (level: sort (a: b: a < b) level.value) (sort (x: y: (toIntBase10 x.name) < (toIntBase10 y.name)) (attrsToList levels'));
  };

  linearizeAncestors = levels: root: graph: let
    dfs = visited: queue:
      if queue == [] then
        visited
      else let e = head queue; in
        if hasAttr e visited then
          dfs visited (drop 1 queue)
        else let parents = graph.${e}; in
          if parents == [] then
            dfs (visited // { ${e} = null; }) (drop 1 queue)
          else let xs = filter (x: !(hasAttr x visited)) parents; in
            if xs == [] then
              dfs (visited // { ${e} = null; }) (drop 1 queue)
            else
              dfs visited (xs ++ queue);

    visited = dfs { } [ root ];

    partial_levels  = mapAttrs (node: _: levels.${node}) visited;
    partial_levels' = reverseAttrs (mapAttrs (_: level: [level]) partial_levels);
  in { 
    result = map (level: sort (a: b: a < b) level.value) (sort (x: y: (toIntBase10 x.name) < (toIntBase10 y.name)) (attrsToList partial_levels'));
  };

  # Helper function (not exported)
  reverseAttrs = graph: let 
    # Note: reverseAttrs is extracted from reverse function, so parameter names are not general
    lst1 = mapAttrsToList (vertex: map (neighbor: { name = toString neighbor; value = [ vertex ]; })) graph;
    # Hint: neighbors is a set represented as list
    lst2 = map listToAttrs lst1;
  in
    # uniqueStrings is not needed since duplicate will be removed at lst2
    zipAttrsWith (_: concatLists) lst2;


in {
  inherit reverse;
  inherit linearize;
  inherit linearizeAncestors;
}
