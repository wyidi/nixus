nixus: { lib, ... }: let 
  nixus-lib-paths = lib.filter (n: lib.strings.hasSuffix ".nix" n) (lib.filesystem.listFilesRecursive ./lib);

  nixus-lib = lib.fix (self: builtins.foldl' (a: b: a // b) {} (map (path: import path { inherit self; inherit lib; } ) nixus-lib-paths));
  # nixus-lib = builtins.trace "hello world" (builtins.foldl' (a: b: a // b) {} (map (path: import path { inherit lib; } ) nixus-lib-paths));
in {
  imports = [( nixus.inputs.import-tree ./modules )];

  _module.args = builtins.trace nixus-lib { inherit nixus; inherit nixus-lib; };
}
