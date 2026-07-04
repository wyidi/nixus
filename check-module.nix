nixus: { ... }: {
  imports = [
    (nixus.inputs.import-tree ./tests)
    (nixus.inputs.nix-unit.modules.flake.default)
  ];
}
