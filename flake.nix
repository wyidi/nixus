{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

    nix-unit.url = "github:nix-community/nix-unit";
    nix-unit.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { ... } @ inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ flake-parts-lib, withSystem, ... } : let
      flakeModule = flake-parts-lib.importApply ./flake-module.nix { inherit inputs; inherit withSystem; };
    in {
      # The flakeModule is the only flake output. Import this to use the framework.
      flake = { inherit flakeModule; };

      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ];

      imports = let 
        module-tests    = inputs.import-tree ./tests;
        module-nix-unit = inputs.nix-unit.modules.flake.default;
      in [
        flakeModule
        module-tests
        module-nix-unit
      ];

    });
}
