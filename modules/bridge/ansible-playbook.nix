{ lib, flake-parts-lib, ... }: with lib; let
  module_playbook = (types.listOf (types.submodule ({ ... }: {
    options.name = mkOption {
      type = types.nullOr types.str;
      description = ''
        Name of the play.
      '';
    };

    options.hosts = mkOption {
      type = types.str;
      description = ''
        The target hosts for this play.
      '';
      default = "localhost";
    };

    options.tasks = mkOption {
      type = types.listOf (types.submodule ({ ... }: {
        options.name = mkOption {
          type = types.nullOr types.str;
          description = ''
            Name of the task.
          '';
        };

        freeformType = types.attrsOf types.anything;
      }));

      default = [];
      description = ''
        List of tasks to execute in this play.
      '';

    };

    options.become = mkOption {
      type = types.nullOr types.bool;
      description = ''
        Whether to use privilege escalation.
      '';
    };

  })));
in {

  options.perSystem = flake-parts-lib.mkPerSystemOption ( { ... } : {
    options.nixible.playbook = mkOption {
      type = types.attrsOf module_playbook;

      default = {};
    };

    options.nixible.package.playbook = mkOption {
      type = types.attrsOf types.package;

      description = ''
        Package of playbook.
      '';

      readOnly = true;
    };

  });

  config = {
    perSystem = { pkgs, config, ... }: let cfg = config.nixible;

      filterNull = value:
        if builtins.isAttrs value && !builtins.hasAttr "_type" value then
          filterAttrs (name: value: !builtins.isNull value) (builtins.mapAttrs (name: value: filterNull value) value)
        else if builtins.isList value then
          builtins.filter (value: !builtins.isNull value) (builtins.map (value: filterNull value) value)
        else
          value;

      mkPlaybook = name: value: (pkgs.formats.yaml {}).generate name (filterNull value);

    in {
      nixible.package.playbook = mapAttrs mkPlaybook cfg.playbook;
    };
  };
}
