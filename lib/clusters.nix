{ self, lib, ... }: with lib; let
  inherit (self) mkTaskAskAndSetVar;

  toUpper' = str: builtins.replaceStrings [ "@" ] [ "_" ] str |> toUpper;

  mkNameClusterPWD = cluster: user_fullname: concatStringsSep "_" [ "PVE" "PWD" (toUpper cluster.name) (toUpper' user_fullname) ];

  mkNameClusterRootPWD = cluster: mkNameClusterPWD cluster "root@pam";

in {
  inherit mkNameClusterPWD;
  inherit mkNameClusterRootPWD;

  mkTaskGetClusterPWD = cluster: { user, realm }: mkTaskAskAndSetVar (mkNameClusterPWD cluster { inherit user; inherit realm; });

  mkTaskGetClusterRootPWD = cluster: mkTaskGetClusterPWD "root@pam";

  # A function that returns list of all nodes from list of clusters
  flattenNodes = foldl (acc: cluster: acc ++ (attrValues cluster.node)) [];
}
