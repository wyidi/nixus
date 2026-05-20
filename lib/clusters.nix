{ self, lib, ... }: with lib; let
  inherit (self) mkTaskAskAndSetVar;
  mkNameClusterPWD = cluster: concatStringsSep "_" [ "PWD" "CLUSTER" (toUpper cluster.name) ];

  mkClusterOptions = opts: mkOption {
    type = types.attrsOf (types.submodule ({ cluster, ... }: opts cluster));
  };
  mkNodeOptions = opts: mkOption {
    type = types.attrsOf (types.submodule ({ node, ... }: opts node));
  };
  mkClusterNodeOptions = opts: { cluster = mkClusterOptions (cluster: { node = mkNodeOptions (node: opts cluster node); }); };
in {
  inherit mkNameClusterPWD;
  mkTaskGetClusterPWD = node: mkTaskAskAndSetVar (mkNameClusterPWD node);

  # A function that returns list of all nodes from list of clusters
  flattenNodes = foldl (acc: cluster: acc ++ (attrValues cluster.node)) [];

  inherit mkClusterNodeOptions;
}
