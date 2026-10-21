{ lib, config, nixus-lib, ... }: with lib; let
  inherit (nixus-lib) linearize linearizeAncestors reverse;
in {
  config.flake = {
    nixus = genAttrs config.systems ( system: let
      # nodes = config.allSystems.${system}.nixus.node;
      nodes = builtins.concatLists (mapAttrsToList (_: v:
        mapAttrsToList (_: trivial.id) v
      ) config.allSystems.${system}.nixus.node);

      graph = concatMapAttrs (_: value: mapAttrs' (_: value: 
        nameValuePair value.id value.requires
      ) value) config.allSystems.${system}.nixus.node;

    in {
      API.TopoSort = ({ Tail ? null }: let
        order = linearize graph; 
      in
        if builtins.isNull Tail then {
          order = flatten order.result;
          inherit nodes;
        } else {
          order = flatten (linearizeAncestors order.levels Tail graph).result;
          inherit nodes;
        }
      );

      API.ReverseTopoSort = ({ Tail ? null }: let
        graph' = reverse graph;
        order  = linearize graph';
      in 
        if builtins.isNull Tail then {
          order = flatten order.result;
          inherit nodes;
        } else {
          order = flatten (linearizeAncestors order.levels Tail graph).result;
          inherit nodes;
        }
      );
    });
  };
}
