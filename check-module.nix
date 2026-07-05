nixus: { flake-parts-lib, ... }: {
  imports = [ 
    (nixus.inputs.import-tree ./tests)
    (nixus.inputs.nix-unit.modules.flake.default)
    # assetModule is imported implicitly by importing flakeModule from top level
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

  # run below command to unit test
  # nix flake check
  # use below command to unit test and see the full log
  # nix flake check -L
  # use below command to unit test and ignore build error (no color)
  # nix flake check -L 2>&1 | awk '/^error:/{exit} {print}'
  # use below command to respect color
  # script -q /dev/null nix flake check -L
}
