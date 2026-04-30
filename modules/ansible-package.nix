{ lib, nixus, flake-parts-lib, ... }: with lib; {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { system, ... } : let
    python = nixus.withSystem system ({ pkgs, ... }: pkgs.python314);
  in {
    options.nixible.package = mkOption {
      type = types.submodule ({ ... }: {
        options.python = mkOption {
          type = types.package;
          description = ''
            Python interpreter package.
          '';
          default = python;
        };

        options.ansible = mkOption {
          type = types.package;
          description = ''
            Ansible package.
          '';
          default = python.pkgs.ansible-core;
        };

      });

      default = {};
    };
  }); 
}
