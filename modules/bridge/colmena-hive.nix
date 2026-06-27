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
    });
    default = {};
  };

  config = {
    flake.colmenaHive = colmena.lib.makeHive (
      cfg.hive // { meta = cfg.meta; }
    );
  };
}
