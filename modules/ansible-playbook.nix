{ lib, config, flake-parts-lib, ... }: with lib; let 
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

  options.perSystem = flake-parts-lib.mkPerSystemOption ( { ... } : {
    options.nixible.playbook = mkOption {
      type = types.attrsOf (types.submodule ({ ... }: {

        options.package = mkOption {
          type = types.package;
          description = ''
            Package of playbook.
          '';
          readOnly = true;
        };

      }));

      default = {};
    };
  });

  config = {
    perSystem = { system, pkgs, config, ... }: let
      filterNull = value: 
        if builtins.isAttrs value && !builtins.hasAttr "_type" value then 
          filterAttrs (name: value: !builtins.isNull value) (builtins.mapAttrs (name: value: filterNull value) value)
        else if builtins.isList value then 
          builtins.filter (value: !builtins.isNull value) (builtins.map (value: filterNull value) value)
        else 
          value;

      mkPlaybook = name: value: (pkgs.formats.yaml {}).generate ("playbook-" + name) (filterNull value);

      ansible = config.nixible.package.ansible;
      python  = config.nixible.package.python;

      #/-package--
      # NixOS 25.11 Manual: Language and frameworks/Python
      environment = python.withPackages ( pkgs:
        lists.unique (foldlAttrs (acc: name: value: acc ++ (value.requires pkgs)) [ansible] cfg.collection)
      );
      #--package-/

      mkExecutable = collections: name: value: let
        playbook = value.package; 
      in pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [ environment ];
        text = ''
          export ANSIBLE_COLLECTIONS_PATH=${collections}
          ansible-playbook ${playbook}
        '';
      };

      #/-package--
      executables = let 
        collections = pkgs.symlinkJoin {
          name  = "collections";
          paths = lists.unique (mapAttrsToList ( name: value: value.package ) config.nixible.collection);
        }; 
      in mapAttrs' (name: value: let
        pname = "executable-" + name;
      in nameValuePair pname (mkExecutable collections pname value)) config.nixible.playbook;
      #--package-/

    
    in {
      nixible.playbook = mapAttrs (name: value:
        { package = (mkPlaybook name value); }
      ) cfg.playbook;

      packages = { inherit environment; } // executables;
    };
  };
}
