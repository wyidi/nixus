{ nixus-lib, ... }: let
  inherit (nixus-lib) linearize;
in {
  flake.tests = {
    TopologicalSort.testCaseA = let
      graph = { nodeA = []; }; # graph is represented as adjacency list
    in {
      expr     = (linearize graph).toset;
      expected = [ [ "nodeA" ] ]; # linearized strongly connected components
    };

    TopologicalSort.testCaseB = let
      graph = { nodeA = []; nodeB = []; nodeC = []; }; 
    in {
      expr     = (linearize graph).toset;
      expected = [ [ "nodeA" "nodeB" "nodeC" ] ]; 
    };

    TopologicalSort.testCaseC = let
      graph = { }; 
    in {
      expr     = (linearize graph).toset;
      expected = [ ];
    };

    TopologicalSort.testCaseD = let
      graph = { nodeA = []; nodeB = [ "nodeA" ]; }; 
    in {
      expr     = (linearize graph).toset;
      expected = [ [ "nodeA" ] [ "nodeB" ] ]; 
    };

  };
}
