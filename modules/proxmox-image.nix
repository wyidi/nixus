{ config, lib, nixus-lib, ... }: with lib; let cfg = config.nixus;
  inherit (nixus-lib) mkClusterNodeOptions;

  module_image = cluster: node: types.submodule ({ name, ... }: {
    options = {

      name = mkOption {
        type = types.str;
        default = name; readOnly = true;
      };

      cluster = mkOption {
        type = types.str;
        default = cluster; readOnly = true;
      };

      node = mkOption {
        type = types.str;
        default = node; readOnly = true;
      };

      url = mkOption {
        type = types.str;
      }; 

      storage = mkOption {
        type = types.str;
      };

    };
  });
in {
  options.nixus.proxmox = mkClusterNodeOptions (cluster: node: {
    options.image = mkOption {
      type = types.attrsOf (module_image cluster node);
    };
  });
}
