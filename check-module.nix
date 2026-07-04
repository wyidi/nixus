nixus: { ... }: {
  imports = [ 
    (nixus.inputs.import-tree ./tests)
    (nixus.inputs.nix-unit.modules.flake.default)
  ];

  perSystem = { ... }: {
    # required: flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    # https://flake.parts/options/nix-unit.html#opt-perSystem.nix-unit.inputs
    nix-unit.inputs = {
      # import-tree is required for test to be evaluated so it is included here
      # input that test does not depend on need not to be included here (such as colmena)
      inherit (nixus.inputs) nixpkgs flake-parts import-tree nix-unit;
    };
  };
}
