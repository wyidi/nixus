{ lib, ... }: with lib; let
  module_node = (types.submodule ({ name, ... }: {
      options = {
        enable = mkEnableOption "proxmox host ${name}";

        address = mkOption {
          type = types.str;
          description = "IPv4 address of the host.";
        };
      };
  }));

  module_cluster = (types.submodule ({ name, ...}: {
    options = {
      type = types.attrsOf module_node;
    };
  }));

in {
  options.nixus.proxmox.cluster = mkOption {
    type = types.attrsOf module_cluster;
  };
}
