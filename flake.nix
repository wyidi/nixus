{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs = { ... } @ inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ flake-parts-lib, withSystem, ... } : let
      flakeModule = (flake-parts-lib.importApply ./flake-module.nix { inherit inputs; inherit withSystem; });
    in {
      # The flakeModule is the only flake output. Import this to use the framework.
      flake = { inherit flakeModule; };

      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ];

      perSystem = { pkgs, ... }: let python = pkgs.python314; in {
        packages = {
          inherit python;
          ansible = python.pkgs.ansible-core;
        };
      };

      imports = [
        flakeModule
        (inputs.import-tree ./tests)
      ];

    });
}
