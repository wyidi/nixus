{ lib, nixus-lib, ... }: with lib; let cfg = config.nixus;
  inherit (nixus-lib) TODO;

  module_zfs = zpool: (types.submodule ({ name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = zpool.name + "/" + name; readOnly = true;
        description = ''
          Name of zfs dataset.
        '';
      };
    };
  }));

  module_vdev = (types.submodule ({ ... }: {
    options = {
      type = mkOption {
        type = types.enum [ "stripe" "mirror" "raidz" "raidz1" "raidz2" "raidz3" ];
        description = ''
          Type of vdev.
        '';
      };

      disks = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          List of disks that consists a vdev.
        '';
      };
    };
  }));

  module_zpool = (types.submodule ({ name, config, ... }: {
    options = {
      cluster = mkOption {
        type = types.str;
        description = ''
          Name of the cluster that contains a zpool.
        '';
      };

      node = mkOption {
        type = types.str;
        description = ''
          Name of the node that contains a zpool.
        '';
      };

      name = mkOption {
        type = types.str;
        default = name; readOnly = true;
        description = ''
          Name of a zpool.
        '';
      };

      zfs = mkOption {
        type = types.attrsOf (builtins.removeAttrs config ["zfs"] |> module_zfs);
        default = {};
        description = ''
          ZFS datasets of zpool.
        '';
      };

      vdevs = mkOption {
        type = types.listOf module_vdev;
        default = []; # This should result in error
        description = ''
          List of vdevs of zpool.
        '';
      };

    };
  }));
in {
  options.nixus.storage.zpool = mkOption {
    type = types.attrsOf module_zpool;

    default = {};
  };

  config = let
    inherit (nixus-lib) foldp play-add-pve-hosts;

    play-add-zpools = zpools: let
    # /-Implementation--
      task-create-zpool = zpool: [{
        name = "Create zpool ${zpool.name}";
        "community.general.zpool" = {
          name  = zpool.name;
          vdevs = zpool.vdevs;
        };
      }];

      task-create-zfs = zpool: TODO;

      play-add-zpool = zpool: {
        hosts = TODO; # name of host follows convention ( function )

        tasks = concatLists [
          (task-create-zpool zpool)
          (task-create-zfs   zpool)
        ];

      };

      play-add-hosts  = zpool-groups: zpool-groups 
      |> foldl ( acc: group: acc ++ [(head group).node] ) [] 
      |> play-add-pve-hosts;

      play-add-zpools = zpool-groups: zpool-groups 
      |> map ( group: foldp play-add-zpool group );


      groupPools = acc: zpool: with zpool; let
          prev = attrByPath [ "${cluster}" "${node}" ] [ ] acc;
        in  acc // { ${cluster}.${node} = prev ++ zpool; }; 

      zpool-groups = zpools |> foldl groupPools {} |> attrValues |> map attrValues;

    # --Implementation-/
    in concatLists [
      (play-add-hosts  zpool-groups)
      (play-add-zpools zpool-groups)
    ];


  in {
    perSystem = { config, ... }: let cfg = config.nixus;
      class = attrValues cfg.storage.zpool |> foldl (zpool: 
        updateManyAttrsByPath [{
          path = [ "${zpool.cluster}" "${zpool.node}" ];
          update = old: old ++ zpool;
        }]
      ) {};

      zpools = cluster: node: class.${cluster}.${node};
    in {

      nixible.playbook = {
        proxmox-storage = play-add-zpools zpools;
      };

    };
  };
}
