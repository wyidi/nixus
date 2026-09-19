{ lib, flake-parts-lib, config, ... }: with lib; let
  # The layer of indirection
  module_node = types.submodule ({ ... }: {
    options.tf = mkOption {
      type = types.attrsOf module_tf;
    };

    options.nix = mkOption {
      type = types.attrsOf module_nix;
    };

    options.pb = mkOption {
      type = types.attrsOf module_pb;
    };
  });

  module_tf = types.submodule ({ name, cfg, ... }: {
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

  module_nix = types.submodule ({ name, ... }: {
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

  module_pb = types.submodule ({ name, cfg, ... }: {
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
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { ... } : {
    options.nixus.node = mkOption {
      type = module_node;        
    };
  });

  # The glue
  config = {
    perSystem = { config, ... }: {
      nixus.node.tf = {
        _module.args.cfg = {
          terranix = config.terranix;
        };
      };

      nixus.node.nix = {
        _module.args.cfg = {

        };
      };

      nixus.node.pb = {
        _module.args.cfg = {
          nixible = config.nixible;
        };
      };
    };
  }; 
}
