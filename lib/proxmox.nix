{ lib, ... }: with lib; let
  mkNodeOptions = mkOpts: { node = mkOption {
    type = types.attrsOf (types.submodule ({ node, ... }: mkOpts node));
  };};
  mkClusterOptions = mkOpts: { cluster = mkOption {
    type = types.attrsOf (types.submodule ({ cluster, ... }: mkOpts cluster));
  };};
  mkClusterNodeOptions = mkOpts: mkClusterOptions (cluster: { options = mkNodeOptions (node: mkOpts cluster node); });
in {
  inherit mkNodeOptions;
  inherit mkClusterOptions;
  inherit mkClusterNodeOptions;
}
