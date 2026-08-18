{ lib, config, nixus, ... }: with lib; let cfg = config.colmena;
  colmena = nixus.inputs.colmena;
in {
  options.colmena.hive = mkOption {
    type = types.attrsOf types.deferredModule;
    default = {};
  };

  options.colmena.meta = mkOption {
    type = types.submodule ({ ... }: {
      options.nixpkgs = mkOption {
        type = types.raw;
      };

      options.nodeSpecialArgs = mkOption {
        type = types.attrsOf (types.attrsOf types.raw);
      };

      options.nodeNixpkgs = mkOption {
        type = types.attrsOf types.raw;
      };

    });
    default = {};
  };

  config = {
    flake.colmenaHive = colmena.lib.makeHive (
      cfg.hive // { meta = cfg.meta; }
    );
  };
}
