{ lib, config, nixus, ... }: with lib; let cfg = config.colmena;
  colmena = nixus.inputs.colmena;
in {
  options.colmena.hive = mkOption {
    type = types.attrsOf types.deferredModule;
    default = {};
  };

  options.colmena.meta = mkOption {
    type = types.submodule ({ ... }: {
      freeformType = types.attrsOf types.anything;
    });
    default = {};
  };

  config = {
    flake.colmenaHive = colmena.lib.makeHive (
      cfg.hive // { meta = cfg.meta; }
    );
  };
}
