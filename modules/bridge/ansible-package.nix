{ lib, nixus, flake-parts-lib, ... }: with lib; {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { system, ... } : let
    python = nixus.withSystem system ({ pkgs, ... }: pkgs.python314);
  in {
    options.nixible.package.python = mkOption {
      type = types.package;
      description = ''
        Python interpreter package.
      '';
      default = python;
    };

    options.nixible.package.ansible = mkOption {
      type = types.package;
      description = ''
        Ansible package.
      '';
      default = python.pkgs.ansible-core;
    };
  });
}
