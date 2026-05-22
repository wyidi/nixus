{ lib, flake-parts-lib, ... }: with lib; {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { system, ... } : {
    options.terraform.package.terranix = mkOption {
      type = types.package;
      description = ''
        Terranix package.
      '';
      default = pkgs.terranix;
    };
  }); 
}
