{ lib, nixus, flake-parts-lib, ... }: with lib; {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { system, ... } : let
    terranix = nixus.withSystem system ({ pkgs, ... }: pkgs.terranix);
    nix      = nixus.withSystem system ({ pkgs, ... }: pkgs.nix);
    opentofu = nixus.withSystem system ({ pkgs, ... }: pkgs.opentofu);
  in {
    options.terranix.package.terranix = mkOption {
      type = types.package;
      description = ''
        Terranix package.
      '';
      default = terranix;
    };

    options.terranix.package.nix = mkOption {
      type = types.package;
      description = ''
        Nix package.
      '';
      default = nix;
    };

    options.terranix.package.terraform = mkOption {
      type = types.package;
      description = ''
        Terraform package.
      '';
      default = opentofu;
    };
  }); 
}
