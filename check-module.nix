nixus: { ... }: {
  imports = [
    (nixus.inputs.import-tree ./tests)
    (nixus.inputs.nix-unit.modules.flake.default)
  ];

  perSystem = { ... }: {
    # required: flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nix-unit.inputs = {
      inherit (nixus.inputs) nixpkgs flake-parts import-tree colmena nix-unit;
    };
  };
}
