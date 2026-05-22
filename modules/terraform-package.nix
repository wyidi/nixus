{ lib, nixus, flake-parts-lib, ... }: with lib; {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { system, ... } : let
    terranix = nixus.withSystem system ({ pkgs, ... }: pkgs.terranix);
    nix      = nixus.withSystem system ({ pkgs, ... }: pkgs.nix);
  in {
    options.terraform.package.terranix = mkOption {
      type = types.package;
      description = ''
        Terranix package.
      '';
      default = terranix;
    };

    options.terraform.package.nix = mkOption {
      type = types.package;
      description = ''
        Nix package.
      '';
      default = nix;
    };
  }); 
}
