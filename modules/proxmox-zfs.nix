{ config, lib, nixus-lib, ... }: with lib; let cfg = config.nixus;
  inherit (nixus-lib) mkClusterNodeOptions;

  module_zfs = zpool: (types.submodule ({ name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = zpool.name + "/" + name; readOnly = true;
        description = ''
          Full name of zfs dataset.
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

  module_zpool = cluster: node: (types.submodule ({ name, config, ... }: {
    options = {
      cluster = mkOption {
        type = types.str;
        description = ''
          Name of the cluster that contains a zpool.
        '';
        default = cluster; readOnly = true;
      };

      node = mkOption {
        type = types.str;
        description = ''
          Name of the node that contains a zpool.
        '';
        default = node; readOnly = true;
      };

      name = mkOption {
        type = types.str;
        default = name; readOnly = true;
        description = ''
          Name of a zpool.
        '';
      };

      dataset = mkOption {
        type = types.attrsOf (builtins.removeAttrs config ["datasets"] |> module_zfs);
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
  
  options.nixus.proxmox = mkClusterNodeOptions (cluster: node: {
    options.zpool = mkOption {
      type = types.attrsOf (module_zpool cluster node);
      description = ''
        List of zpools.
      '';
      default = {};
    };
  });

  config = let
    inherit (nixus-lib) foldp stackp stackt flattenNodes mkNamePVEHost mkPlayAddPVEHost;

    mkTaskAddZFSPool = zpool: [{
      name = "Create zpool ${zpool.name}";
      "community.general.zpool" = {
        name  = zpool.name;
        vdevs = zpool.vdevs;
      };
    }];

    mkPlayAddZFSPools = node: let zpools = attrValues node.zpool; in [{
      # The host name follows convention
      hosts = mkNamePVEHost node;
      tasks = stackt mkTaskAddZFSPool zpools;
    }];

    mkTaskAddZFSSet = dataset: [{
      name = "Create dataset ${dataset.name}";
      "community.general.zfs" = {
        name = dataset.name;
        extra_zfs_properties.mountpoint = "/" + dataset.name;
        state = "present";
      };
    }];

    mkPlayAddZFSSets = node: let zpools = attrValues node.zpool; in [{
      # The host name follows convention
      hosts = mkNamePVEHost node;
      tasks = stackt (zpool: let datasets = attrValues zpool.dataset; in stackt mkTaskAddZFSSet datasets) zpools;
    }];

    nodes = cfg.proxmox.cluster 
          # Transform attrset of clusters to list of clusters
          |> attrValues 
          # Transform list of clusters to list of all nodes
          |> flattenNodes 
          # Filter out nodes that don't have zpool
          |> filter (node: node.zpool != {});

    # A play that dynamically adds pve nodes to the ansible inventory
    PlayAddZFSHosts =  foldp mkPlayAddPVEHost   nodes;
    # A list of plays where each adds zpools   to a particular node
    PlayAddZFSPools = stackp mkPlayAddZFSPools  nodes;
    # A list of plays where each adds datasets to a particular node
    PlayAddZFSSets  = stackp mkPlayAddZFSSets   nodes;
    
  in { perSystem = { ... }: {

    nixible.playbook.zfs = concatLists [
      PlayAddZFSHosts
      PlayAddZFSPools
      PlayAddZFSSets
    ];

  };};
}
