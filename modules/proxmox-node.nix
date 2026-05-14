{ lib, ... }: with lib; let
  module_node = cluster: (types.submodule ({ name, ... }: {
      options = {
        cluster = mkOption {
          type = types.str;
          default = cluster; readOnly = true;
        };

        name = mkOption {
          type = types.str;
          default = name; readOnly = true;
        };

        address = mkOption {
          type = types.str;
          description = "IPv6 address of the host.";
        };
      };
  }));

  module_cluster = (types.submodule ({ name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = name; readOnly = true;
      };

      node = mkOption {
        type = types.attrsOf (module_node cluster);
      };

      api_host = mkOption {
        type = types.str;
      };

      api_port = mkOption {
        type = types.int;
      };

      api_user = mkOption {
        type = types.str;
      };

      validate_certs = mkOption {
        type = types.bool;
        default = false;
      };
    };
  }));

in {
  options.nixus.proxmox.cluster = mkOption {
    type = types.attrsOf module_cluster;
  };
}
