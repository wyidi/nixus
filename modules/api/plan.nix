{ lib, config, nixus-lib, ... }: with lib; let
  inherit (nixus-lib) toposort bfs;
in {
  config.flake = {
    nixus = genAttrs config.systems ( system: let

      nodes = builtins.concatLists (mapAttrsToList (_: v:
        mapAttrsToList (_: trivial.id) v
      ) config.allSystems.${system}.nixus.node);

      graph = concatMapAttrs (_: value: mapAttrs' (_: value: 
        nameValuePair value.id value.requires
      ) value) config.allSystems.${system}.nixus.node;

      services = attrNames (config.allSystems.${system}.nixus.node.svc);

    in {
      plan = {
        inherit nodes;
        order = flatten (toposort graph); # topological ordering
      };

      plan_of = genAttrs services (name: let
        subgraph = bfs graph (concatStringsSep "." [ "Service" name ]);
      in {
        nodes = filter (node:
          hasAttr node.id subgraph
        ) nodes;
        order = flatten (toposort subgraph);
      });
    });
  };
}
