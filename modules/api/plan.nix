{ lib, config, nixus-lib, ... }: with lib; let
  inherit (nixus-lib) linearize linearizeAncestors reverse;
in {
  config.flake = {
    nixus = genAttrs config.systems ( system: let

      nodes = builtins.concatLists (mapAttrsToList (_: v:
        mapAttrsToList (_: trivial.id) v
      ) config.allSystems.${system}.nixus.node);

      graph = concatMapAttrs (_: value: mapAttrs' (_: value: 
        nameValuePair value.id value.requires
      ) value) config.allSystems.${system}.nixus.node;

    in {

      # Evaluates to topological sorted deploy graph
      plan = {
        inherit nodes;
        order = flatten (linearize graph).result;
      };

    });
  };
}
