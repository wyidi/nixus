{ self, lib, ... }: with lib; let
  mkNodeOptions = opts: { node = mkOption {
    type = types.attrsOf (types.submodule ({ node, ... }: opts node));
  };};
  mkClusterOptions = opts: { cluster = mkOption {
    type = types.attrsOf (types.submodule ({ cluster, ... }: opts cluster));
  };};
  mkClusterNodeOptions = opts: mkClusterOptions (cluster: mkNodeOptions (node: opts cluster node));
in {
  inherit mkNodeOptions;
  inherit mkClusterOptions;
  inherit mkClusterNodeOptions;
}
