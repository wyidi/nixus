{ lib, flake-parts-lib, ... }: with lib; let
  module_config = types.submodule ({ ... }: {
    freeformType = types.attrsOf types.anything;
  });
in {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { ... } : {
    options.terraform.config = mkOption {
      type = module_config;
    };

    options.terraform.package.config = mkOption {
      type = types.attrsOf types.package;

      description = ''
        Package of json config.
      '';

      readOnly = true;
    };
  });

  config.perSystem = { pkgs, config, ... }: let cfg = config.terraform;
    terranix = cfg.package.terranix;

    mkConfig = name: value: let
      json = pkgs.writeJSON "config.json" value;
      code = pkgs.writeText ''
        { ... }: builtins.fromJSON (builtins.readFile ${json})
      '';
    in pkgs.stdenv.mkDerivation {
      pname = name;

      dontUnpack = true; # call mkDerivation without src
      
      buildInputs = [
        terranix
      ];

      phases = ["installPhase"];

      installPhase = ''
        terranix ${code} > $out 
      '';
    };
  in {
    terraform.package.config = mapAttrs mkConfig cfg.config;
  };
}
