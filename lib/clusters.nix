{ self, lib, ... }: with lib; let
  inherit (self) mkTaskAskAndSetVar;
  mkNameClusterPWD = cluster: concatStringsSep "_" [ "PWD" "Cluster" (toUpper cluster.name) ];
in {
  inherit mkNameClusterPWD;
  mkTaskGetClusterPWD = node: mkTaskAskAndSetVar (mkNameClusterPWD node);

  # A function that returns list of all nodes from list of clusters
  flattenNodes = foldl (acc: cluster: acc ++ attrValues cluster.node);
}
