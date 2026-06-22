{ lib, nixus, flake-parts-lib, ... }: with lib; {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { system, ... } : let
    colmena = nixus.withSystem system ({ inputs', ... }: inputs'.colmena.packages.colmena);
  in {
    options.colmena.package.colmena = mkOption {
      type = types.package;
      description = ''
        Colmena package.
      '';
      default = colmena;
    };
  });
}
