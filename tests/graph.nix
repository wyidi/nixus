{ nixus-lib, ... }: let
  inherit (nixus-lib) reverse linearize;
in {

  flake.tests.ReverseGraph = {
    testCase1 = let
      graph = { nodeA = []; };
    in {
      expr     = reverse graph;
      expected = { nodeA = []; };
    };

    testCase2 = let
      graph = { nodeA = []; nodeB = []; nodeC = []; };
    in {
      expr     = reverse graph;
      expected = { nodeA = []; nodeB = []; nodeC = []; };
    };

    testCase3 = let
      graph = { };
    in {
      expr     = reverse graph;
      expected = { };
    };

    testCase4 = let
      graph = { nodeA = []; nodeB = [ "nodeA" ]; };
    in {
      expr     = reverse graph;
      expected = { nodeA = ["nodeB"]; nodeB = []; };
    };

  };


  flake.tests.TopologicalSort = {
    testCase1 = let
      graph = { nodeA = []; }; # graph is represented as adjacency list
    in {
      expr     = (linearize graph).result or null;
      expected = [ [ "nodeA" ] ]; # linearized strongly connected components
    };

    testCase2 = let
      graph = { nodeA = []; nodeB = []; nodeC = []; };
    in {
      expr     = (linearize graph).result or null;
      expected = [ [ "nodeA" "nodeB" "nodeC" ] ];
    };

    testCase3 = let
      graph = { };
    in {
      expr     = (linearize graph).result or null;
      expected = [ ];
    };

    testCase4 = let
      graph = { nodeA = []; nodeB = [ "nodeA" ]; };
    in {
      expr     = (linearize graph).result or null;
      expected = [ [ "nodeA" ] [ "nodeB" ] ];
    };

    testCase5 = let
      graph = {
        nodeA = [];
        nodeB = [ "nodeA" ];

        nodeC = [];
        nodeD = [ "nodeC" ];
        nodeE = [ "nodeD" ];
        nodeF = [ "nodeB" "nodeE" ];
      };
    in {
      expr     = (linearize graph).result or null;
      expected = [ [ "nodeA" "nodeC" ] [ "nodeB" "nodeD" ] [ "nodeE" ] [ "nodeF" ] ];
    };
  };

}
