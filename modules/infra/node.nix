{ lib, flake-parts-lib, config, ... }: with lib; let
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
  });

  module_tf = cfg: types.submodule ({ name, ... }: {
    options.backend = mkOption {
      type    = types.enum [ "terraform" "opentofu" ];
      default = "opentofu";
      description = ''
        Whether to use opentofu or terraform as the backend.
        Defaults to opentofu.
      '';
    };

    options.requires = mkOption {
      type = types.listOf types.str;
      description = "List of required nodes.";
    };

    options.config = mkOption {
      type     = types.package;
      readOnly = true;
      description = "Package of terraform/opentofu configuration.";
    };

    config = {
      config = cfg.terranix.package.config.${name};
    };
  });

  module_nix = cfg: types.submodule ({ name, ... }: {
    options.requires = mkOption {
      type = types.listOf types.str;
      description = "List of required nodes.";
    };

    options.name = mkOption {
      type     = types.str;
      default  = name;
      readOnly = true;
      description = "Name of the nixos configuration.";
    };
  });

  module_pb = cfg: types.submodule ({ name, ... }: {
    options.requires = mkOption {
      type = types.listOf types.str;
      description = "List of required nodes.";
    };

    options.playbook = mkOption {
      type     = types.package;
      readOnly = true;
      description = "Package of ansible playbook.";
    };

    config = {
      playbook = cfg.nixible.package.playbook.${name};
    };
  });

in {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { config, ... } : {
    options.nixus.node = mkOption {
      type = module_node {
        terranix = config.terranix; 
        nixible  = config.nixible;
      };
    };
  });
}
