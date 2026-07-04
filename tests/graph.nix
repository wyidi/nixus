{ nixus-lib, ... }: let
  inherit (nixus-lib) linearize TODO;
in {
  flake.tests = {
    TopologicalSort.testCaseA = let
      graph = { nodeA = []; }; # graph is represented as adjacency list
    in {
      expr     = linearize graph;
      expected = [ [ "nodeA" ] ]; # linearized strongly connected components
    };

    TopologicalSort.testCaseB = let
      graph = { nodeA = []; nodeB = []; nodeC = []; }; 
    in {
      expr     = linearize graph;
      expected = [ [ "nodeA" "nodeB" "nodeC" ] ]; 
    };

    TopologicalSort.testCaseC = let
      graph = { }; 
    in {
      expr     = linearize graph;
      expected = [ ]; 
    };

    TopologicalSort.testCaseD = let
      graph = { nodeA = []; nodeB = [ "nodeA" ]; }; 
    in {
      expr     = linearize graph;
      expected = [ [ "nodeA" ] [ "nodeB" ] ]; 
    };

  };
}
