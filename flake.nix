{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";

    colmena.url = "github:zhaofengli/colmena";

    nix-unit.url = "github:nix-community/nix-unit?tag=v2.34.0";
    nix-unit.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { ... } @ inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ flake-parts-lib, withSystem, ... } : let
      flakeModule = flake-parts-lib.importApply ./flake-module.nix { inherit inputs; inherit withSystem; };
      checkModule = flake-parts-lib.importApply ./check-module.nix { inherit inputs; inherit withSystem; };
    in {
      # The flakeModule is the only flake output. Import this to use the framework.
      flake = { inherit flakeModule; };

      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ];

      imports = [
        flakeModule
        checkModule
      ];

    });
}
