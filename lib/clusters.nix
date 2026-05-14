{ self, lib, ... }: with lib; let
  inherit (self) mkTaskAskAndSetVar;
  mkNameClusterPWD = node: concatStringsSep "_" [ "PWD" "Cluster" node.cluster node.name ];
in {
  inherit mkNameClusterPWD;
  mkTaskGetClusterPWD = node: mkTaskAskAndSetVar (mkNameClusterPWD node);
}
