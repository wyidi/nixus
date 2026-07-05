nixus: { lib, ... }: let
  nixus-lib-paths = lib.filter (n: lib.strings.hasSuffix ".nix" n) (lib.filesystem.listFilesRecursive ./lib);

  nixus-lib = lib.fix (self: builtins.foldl' (a: b: a // b) {} (map (path: import path { inherit self; lib = lib'; } ) nixus-lib-paths));

  lib' = lib.extend (final: prev: {
    TODO = builtins.throw "TODO";
  });
in {
  _module.args = {
    inherit nixus-lib;
  };

  _module.args.lib = lib';
}

