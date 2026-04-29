{ lib, ... }: with lib; {
  options.nixus.networks.subnet = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        enable = mkEnableOption "subnet ${name}";

        # https://datatracker.ietf.org/doc/html/rfc4193
        ipv6 = mkOption {
          type = types.submodule ({ ... }: {

            globalId = mkOption {
              type = types.str;
              description = ''
                Prefix of a subnet that is globally unique.
              '';
            };
 
            subnetId = mkOption {
              type = types.str;
              description = ''
                Identifier of a subnet within the site.
              '';
            };

            mask = mkOption {
              type = types.int;
              description = ''
                Mask of a subnet.
              '';
              default = 64; readOnly = true;
            };

          });
        };

      };
    }));
  };

  config = {

  };
}
