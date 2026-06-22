nixus: { lib, ... }: {
  imports = [( nixus.inputs.import-tree ./modules )];

  _module.args = {
    inherit nixus;
  };

  _module.args.lib = lib.extend (final: prev: {
    TODO = builtins.throw "TODO";
  });
}
