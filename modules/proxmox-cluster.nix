{ config, lib, ... }: with lib; let cfg = config.nixus;
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

        # TODO: generalize this
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
        type = types.attrsOf (module_node name);
      };

      api_host = mkOption {
        type = types.str;
      };

      api_port = mkOption {
        type = types.int;
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

  config = let
    inherit (nixus-lib) stackt mkTaskIssueRootToken mkTaskGetClusterPWD;

    clusters = attrValues cfg.proxmox.cluster;

    TaskGetClusterPWDs  = stackt mkTaskGetClusterPWD  clusters;
    TaskIssueRootTokens = stackt mkTaskIssueRootToken clusters;

  in { perSystem = { ... }: {
    nixible.playbook.issue-tokens = {
      tasks = concatLists [
        TaskGetClusterPWDs
        TaskIssueRootTokens
      ];
    };

    terraform.config.seed = {
      # https://developer.hashicorp.com/terraform/language/values/variables#environment-variables
      # Plan: Inject api token variable using environment variable
      # root@pam api token is created by outter ansible wrapper. It takes proxmox password and creates it.
      provider.proxmox = TODO;
    };
  };};
}
