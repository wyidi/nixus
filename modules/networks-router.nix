{ config, lib, ... }: with lib; let cfg = config.nixus;

  module_ipv4 = types.submodule ( { ... }: {
    options = {
      address = mkOption {
        type = types.str;
        description = ''
          IPv4 address.
        '';
      };

      mask = mkOption {
        type = types.str;
        description = ''
          IPv4 subnet mask.
        '';
      };
    };
  });

  module_ipv6 = types.submodule ( { ... }: {
    options = {
      address = mkOption {
        type = types.str;
        description = ''
          IPv6 address.
        '';
      };

      mask = mkOption {
        type = types.str;
        description = ''
          IPv6 subnet mask.
        '';
      };
    };
  });

  module_interface = router: types.submodule ({ name, ... }: {
    options = {
      ipv4 = mkOption {
        type = module_ipv4;
        description = ''
          IPv4.
        '';
      };
      ipv6 = mkOption {
        type = module_ipv6;
        description = ''
          IPv6.
        '';
      };
    };
  });

  module_router = types.submodule ({name, ... }: {
    options = {
      backend = mkOption {
        type = types.enum [ "opnsense" ];
        description = ''
          Type of router backend.
        '';
      };

      version = mkOption {
        type = types.str;
        description = ''
          Version of router backend.
        '';
      };

      cluster = mkOption {
        type = types.str;
        description = ''
          PVE cluster where router resides.
        '';
      };

      node = mkOption {
        type = types.str;
        description = ''
          PVE node where router resides.
        '';
      };

      interface = mkOption {
        type = types.attrsOf (module_interface name);
        description = ''
          Interfaces of router.
        '';
      };
    };
  });

in {

}
