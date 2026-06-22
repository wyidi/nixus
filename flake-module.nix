nixus: { lib, ... }: let
  nixus-lib-paths = lib.filter (n: lib.strings.hasSuffix ".nix" n) (lib.filesystem.listFilesRecursive ./lib);

  nixus-lib = lib.fix (self: builtins.foldl' (a: b: a // b) {} (map (path: import path { inherit self; inherit lib; } ) nixus-lib-paths));
in {
  imports = [( nixus.inputs.import-tree ./modules )];

  _module.args = {
    inherit nixus;
    inherit nixus-lib;
  };

  _module.args.lib = lib.extend (final: prev: {
    TODO = builtins.throw "TODO";
  });
}
