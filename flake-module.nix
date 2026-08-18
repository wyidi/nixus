nixus: { flake-parts-lib, ... }: let
  assetModule = flake-parts-lib.importApply ./asset-module.nix nixus;
in {
  imports = [
    (nixus.inputs.import-tree ./modules)
    assetModule
  ];

  _module.args = {
    inherit nixus;
  };
}
