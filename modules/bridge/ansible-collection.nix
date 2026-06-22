{ lib, flake-parts-lib, ... }: with lib; let
  module_collection = (types.submodule ({ name, ... }: {

    options.version = mkOption {
      type = types.str;
      description = ''
        Version of the collection.
      '';
      example = "1.0.0";
    };

    options.hash = mkOption {
      type = types.str;
      description = ''
        SHA256 hash of the collection tarball for verification.
      '';
      example = "sha256-...";
    };

    options.requires = mkOption {
      type = types.functionTo (types.listOf types.package);
      description = ''
        Python packages which collection requires.
      '';
      default = pkgs: [];
    };

  }));

in {

  options.perSystem = flake-parts-lib.mkPerSystemOption ( { ... } : {

    options.nixible.collection = mkOption {
      type = types.attrsOf module_collection;
      default = {};
    };

    options.nixible.package.collection = mkOption {
      type = types.attrsOf types.package;
      description = ''
        Package of collection.
      '';
      readOnly = true;
    };

  });

  config.perSystem = { pkgs, config, ... }: let cfg = config.nixible;
    ansible = cfg.package.ansible;

    mkCollection = name: value: pkgs.stdenv.mkDerivation {
      pname   = name;
      version = value.version;

      src = pkgs.fetchurl {
        hash = value.hash;
        url  = "https://galaxy.ansible.com/download/${name}-${value.version}.tar.gz";
      };

      buildInputs = [
        ansible
      ];

      phases = ["installPhase"];

      installPhase = ''
        export HOME=$TMPDIR
        mkdir -p $out
        ansible-galaxy collection install $src -p $out --no-deps --force
      '';
    };

  in {
    nixible.package.collection = mapAttrs mkCollection cfg.collection;
  };

}
