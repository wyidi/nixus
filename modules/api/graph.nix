{ lib, config, nixus-lib, ... }: with lib; let
  inherit (nixus-lib) linearize linearizeAncestors reverse;
in {
  config.flake = {
    nixus = genAttrs config.systems ( system: let
      nodes = config.allSystems.${system}.nixus.node;

      graph = concatMapAttrs (type: value: mapAttrs' (name: value: 
        nameValuePair "${type}.${name}" value.requires
      ) value) nodes;
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
          nodes = TODO;
        }
      );
    });
  };
}
