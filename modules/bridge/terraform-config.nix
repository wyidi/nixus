{ lib, flake-parts-lib, ... }: with lib; let
  module_config = types.submodule ({ ... }: {
    freeformType = types.attrsOf types.anything;
  });

  module_backend = types.submodule ({ ... }: {
    options.type = mkOption {
      type = types.enum [ "local" "s3" ];
      default = "local";
    };

    options.bucket = mkOption {
      type = types.string;
    };

    options.keyPrefix = mkOption {
      type = types.string;
      default = "terraform";
    };

    options.region = mkOption {
      type = types.string;
    };
  });
in {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { ... } : {
    options.terranix.config = mkOption {
      type = module_config;
    };

    options.terranix.package.config = mkOption {
      type = types.attrsOf types.package;

      description = ''
        Package of json config.
      '';

      readOnly = true;
    };

    options.terranix.backend = mkOption {
      type = module_backend;
    };

  });

  config.perSystem = { pkgs, config, ... }: let cfg = config.terranix;
    terranix = cfg.package.terranix;
    nix      = cfg.package.nix;

    postprocess = name: value: if cfg.backend.type == "s3" then {
      backend."s3" = { 
        bucket = cfg.backend.bucket;
        key    = "${cfg.backend.keyPrefix}/${name}/terraform.tfstate";
        region = cfg.backend.region;
      };
    } // value else value;

    mkConfig = name: value: let
      json = pkgs.writers.writeJSON "config.json" (postprocess name value);
      code = pkgs.writeText "config.nix" ''
        { ... }: builtins.fromJSON (builtins.readFile ${json})
      '';

    in pkgs.stdenv.mkDerivation {
      inherit name;

      dontUnpack = true; # call mkDerivation without src

      buildInputs = [
        terranix nix
      ];

      phases = ["installPhase"];

      installPhase = ''
        terranix ${code} > $out
      '';

      allowSubstitutes = false; # prevent querying cache
    };
  in {
    terranix.package.config = mapAttrs mkConfig cfg.config;
  };

  config.flake.terranix = genAttrs config.systems (system: let
    cfg = config.allSystems.${system}.terranix;
  in {
    config = cfg.package.config;
  });
}
