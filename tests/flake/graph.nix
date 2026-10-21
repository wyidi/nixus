{ nixus-lib, ... }: let
  inherit (nixus-lib) reverse toposort bfs;
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
      expr     = toposort graph;
      expected = [ [ "nodeA" ] ]; # linearized strongly connected components
    };

    testCase2 = let
      graph = { nodeA = []; nodeB = []; nodeC = []; };
    in {
      expr     = toposort graph;
      expected = [ [ "nodeA" "nodeB" "nodeC" ] ];
    };

    testCase3 = let
      graph = { };
    in {
      expr     = toposort graph;
      expected = [ ];
    };

    testCase4 = let
      graph = { nodeA = []; nodeB = [ "nodeA" ]; };
    in {
      expr     = toposort graph;
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
      expr     = toposort graph;
      expected = [ [ "nodeA" "nodeC" ] [ "nodeB" "nodeD" ] [ "nodeE" ] [ "nodeF" ] ];
    };
  };


  flake.tests.TopologicalSortAfterBFS = {
    testCase1 = let
      graph = {
        nodeA = [];
        nodeB = [ "nodeA" ];

        nodeC = [];
        nodeD = [ "nodeC" ];
        nodeE = [ "nodeD" ];
        nodeF = [ "nodeB" "nodeE" ];
      };

      subgraph = bfs graph "nodeE";
    in {
      expr     = toposort subgraph;
      expected = [ [ "nodeC" ] [ "nodeD" ] [ "nodeE" ] ];
    };
  };

}
