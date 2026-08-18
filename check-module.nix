nixus: { flake-parts-lib, ... }: {
  imports = [
    (nixus.inputs.import-tree ./tests)
    (nixus.inputs.nix-unit.modules.flake.default)
  ];

  # (Important) This config block prevents `nix flake check` from failing
  perSystem = { ... }: {
    nix-unit.inputs = {
      # input that test does not depend on need not to be included here (such as colmena)
      inherit (nixus.inputs) nixpkgs flake-parts import-tree nix-unit;
    };
    # (Required) flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    # https://flake.parts/options/nix-unit.html#opt-perSystem.nix-unit.inputs
  };

}
