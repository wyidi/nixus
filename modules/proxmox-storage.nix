{ lib, nixus-lib, ... }: with lib; let
  inherit (nixus-lib) mkClusterOptions;

  module_dir_options = types.submodule ({ ... }: {
    options = {
      path = mkOption {
        type = types.str;
        description = ''
          The path of the directory on the nodes.
        ''; 
      };
    };
  });

  module_nfs_options = types.submodule ({ ... }: {
    options = {
      export = mkOption {
        type = types.str;
        description = ''
          The required NFS export path.
        ''; 
      };

      options = mkOption {
        type = types.str;
        description = ''
          Additional NFS related mount options.
        ''; 
      };

      server = mkOption {
        type = types.str;
        description = ''
          The hostname or IP address of the nfs server.
        ''; 
      };

    };
  });

  module_storage = cluster: (types.submodule ({ name, config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = name; readOnly = true;
      };

      nodes = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      contents = mkOption {
        type = types.listOf types.str;
        default = [];
      };

      type = mkOption {
        type = types.enum [ "cephfs" "cifs" "dir" "iscsi" "nfs" "pbs" "zfspool" ];
      };

      # Requires type to be "dir"
      dir_options = mkOption {
        type = module_dir_options;
      };

      # Requires type to be "nfs"
      nfs_options = mkOption {
        type = module_nfs_options;
      };
    };

  }));

in {
  options.nixus.proxmox = mkClusterOptions (cluster: {
    options.storage = mkOption {
      type = types.attrsOf (module_storage cluster);
      description = ''
        Set of pve stores.
      '';
      default = {};
    };
  });
}
