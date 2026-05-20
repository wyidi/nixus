{ self, lib, ... }: with lib; let
  mkNodeOptions = mkOpts: { options.node = mkOption {
    type = types.attrsOf (types.submodule ({ node, ... }: mkOpts node));
  };};
  mkClusterOptions = mkOpts: { options.cluster = mkOption {
    type = types.attrsOf (types.submodule ({ cluster, ... }: mkOpts cluster));
  };};
  mkClusterNodeOptions = mkOpts: mkClusterOptions (cluster: mkNodeOptions (node: mkOpts cluster node));
in {
  inherit mkNodeOptions;
  inherit mkClusterOptions;
  inherit mkClusterNodeOptions;
}
