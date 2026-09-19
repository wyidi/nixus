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

  module_tf = types.submodule ({ ... }: {
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
  });

  module_nix = types.submodule ({ ... }: {
    options.requires = mkOption {
      type = types.listOf types.str;
      description = "List of required nodes.";
    };

    options.name = mkOption {
      type     = types.str;
      readOnly = true;
      description = "Name of the nixos configuration.";
    };
  });

  module_pb = types.submodule ({ ... }: {
    options.requires = mkOption {
      type = types.listOf types.str;
      description = "List of required nodes.";
    };

    options.playbook = mkOption {
      type     = types.package;
      readOnly = true;
      description = "Package of ansible playbook.";
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
      nixus.node.tf = builtins.mapAttrs (name: value: {
        config = config.terranix.package.config.${name};
      }) config.nixus.node.tf;

      nixus.node.nix = builtins.mapAttrs (name: value: {
        inherit name;
      }) config.nixus.node.nix;

      nixus.node.pb = builtins.mapAttrs (name: value: {
        config = config.nixible.package.playbook.${name};
      }) config.nixus.node.pb;
    };
  }; 
}
