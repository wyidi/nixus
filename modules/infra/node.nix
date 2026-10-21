{ lib, flake-parts-lib, ... }: with lib; let
  # The layer of indirection
  module_node = cfg: types.submodule ({ ... }: {
    options.tf = mkOption {
      type = types.attrsOf (module_tf cfg);
    };

    options.nix = mkOption {
      type = types.attrsOf (module_nix cfg);
    };

    options.pb = mkOption {
      type = types.attrsOf (module_pb cfg);
    };

    # The empty service module
    options.svc = mkOption {
      type = types.attrsOf module_svc;
    };
  });

  module_tf = cfg: types.submodule ({ name, ... }: {
    imports = [ module_common ];

    options.backend = mkOption {
      type    = types.enum [ "terraform" "opentofu" ];
      default = "opentofu";
      description = ''
        Whether to use opentofu or terraform as the backend.
        Defaults to opentofu.
      '';
    };

    config = {
      type = "Terraform";
    };
  });

  module_nix = cfg: types.submodule ({ ... }: {
    imports = [ module_common ];

    config = {
      type = "NixOS";
    };
  });

  module_pb = cfg: types.submodule ({ ... }: {
    imports = [ module_common ];

    config = {
      type = "Ansible";
    };
  });

  module_svc = types.submodule ({ ... }: {
    imports = [ module_common ];

    config = {
      type = "Service";
    };
  });

  module_common = { name, config, ... }: {
    options.requires = mkOption {
      type = types.listOf types.str;
      description = "List of required nodes.";
    };

    options.type = mkOption {
      type     = types.enum [ "Terraform" "NixOS" "Ansible" "Service" ];
      readOnly = true;
      description = "Type of the node.";
    };

    options.name = mkOption {
      type     = types.str;
      default  = name;
      readOnly = true;
      description = "Name of the node.";
    };

    options.id = mkOption {
      type     = types.str;
      readOnly = true;
      description = ''
        Identifier of the node.
        Automatically derived from type and name.
      '';
    };

    options.disabled = mkOption {
      type    = types.bool;
      default = false;
      description = "Whether this node is disabled.";
    };

    config = {
      id = config.type + "." + config.name;
    };
  };

in {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { config, ... } : {
    options.nixus.node = mkOption {
      type = module_node {
        terranix = config.terranix; # For tf type node
        nixible  = config.nixible;  # For pb type node
      };
    };
  });
}
