nixus: { lib, ... }: {
  imports = [( nixus.inputs.import-tree ./modules )];

  _module.args = {
    inherit nixus;
  };

}
