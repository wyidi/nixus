nixus: { lib, ... }: let 
  nixus-lib-paths = lib.filter (n: lib.strings.hasSuffix ".nix" n) (lib.filesystem.listFilesRecursive ./lib);

  nixus-lib = builtins.foldl' (a: b: a // b) {} (map import nixus-lib-paths);
in {
  imports = [( nixus.inputs.import-tree ./modules )];

  _module.args = { inherit nixus; inherit nixus-lib; };
}
