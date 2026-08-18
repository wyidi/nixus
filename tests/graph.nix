{ nixus-lib, ... }: let
  inherit (nixus-lib) reverse;
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

}
