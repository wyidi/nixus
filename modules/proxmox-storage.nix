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
    inherit (nixus-lib) foldp;

    play-add-host = {
      name, groups ? null, 
      ansible_host, ansible_user, ansible_ssh_common_args ? "-o StrictHostKeyChecking=no", 
      extra-variables ? {} 
    }: {
      tasks = [{
        name = "Add host ${name} to inventory";
        "ansible.builtin.add_host" = {
          inherit name;
          inherit groups;
          inherit ansible_host;
          inherit ansible_user;
          inherit ansible_ssh_common_args;
        } // extra-variables;

        when = "${name} not in groups['all']";
      }];
    };

    play-add-hosts = foldp play-add-host;

    play-add-pve-hosts = nodes: nixus-lib.TODO;  
    # name of host follows convention ( function )
    # add ansible_ssh_pass variable

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
      zpools = attrValues cfg.storage.zpool;
    in {

      nixible.playbook = {
        proxmox-storage = play-add-zpools zpools;
      };

    };
  };
}
