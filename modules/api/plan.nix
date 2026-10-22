{ lib, config, nixus-lib, ... }: with lib; let
  inherit (nixus-lib) toposort;
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
      plan = {
        inherit nodes;
        order = flatten (toposort graph); # topological ordering
      };
    });
  };
}
