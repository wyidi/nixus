{ lib, config, nixus, ... }: with lib; let 
  cfg = config.nixible;
in {
  options.nixible.playbook = mkOption {
    type = types.attrsOf (types.listOf (types.submodule ({ ... }: { 
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
  };

  config = {
    perSystem = { system, pkgs, ... }: let
      filterNull = value: 
        if builtins.isAttrs value && !builtins.hasAttr "_type" value then 
          filterAttrs (name: value: !builtins.isNull value) (builtins.mapAttrs (name: value: filterNull value) value)
        else if builtins.isList value then 
          builtins.filter (value: !builtins.isNull value) (builtins.map (value: filterNull value) value)
        else 
          value;

      mkPlaybook = name: value: 
        (pkgs.formats.yaml {}).generate name (filterNull value);

      #/-packages--
      playbooks = mapAttrs' (name: value:
        let pname = "playbook-" + name; in nameValuePair pname (mkPlaybook pname value)
      ) cfg.playbook;
      #--packages-/


      ansible = nixus.withSystem system ({ config, ... }:
        config.packages.ansible
      );

      python = nixus.withSystem system ({ config, ... }:
        config.packages.python
      );

      #/-package--
      # NixOS 25.11 Manual: Language and frameworks/Python
      environment = python.withPackages ( pkgs:
        lists.unique (foldlAttrs (acc: name: value: acc ++ (value.requires pkgs)) [ansible] config.collection)
      );
      #--package-/

      #mkExecutable = name: value: pkgs.writeShellApplication {
      #  inherit name;
      #  runtimeInputs = [ environment ];
      #  text = let

      #  in ''
      #    export ANSIBLE_COLLECTIONS_PATH
      #  '';
      #};

      #executables = mapAttrs' (name: value:
      #  let pname = "executable-" + name; in nameValuePair pname 
      #) playbooks;

    in { 
      packages = playbooks // { inherit environment; };
    };
  };
}
