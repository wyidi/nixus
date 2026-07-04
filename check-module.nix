nixus: { ... }: {
  imports = [
    (nixus.inputs.import-tree ./tests)
    (nixus.inputs.nix-unit.modules.flake.default)
  ];

  perSystem = { ... }: {
    nix-unit.inputs = {
      # NOTE: a `nixpkgs-lib` follows rule is currently required
      inherit (nixus.inputs) nixpkgs flake-parts nix-unit;
    };
  };
}
