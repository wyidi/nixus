{ lib, config, ... }: with lib; let
  cfg = config.nixus;
in {
  options.nixus.networks.subnet = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        enable = mkEnableOption "subnet ${name}";

        # RFC4193
        ipv6 = mkOption {
          type = types.submodule ({ name, ... }: {

            options.globalId = mkOption {
              type = types.str;
              description = ''
                Prefix of a subnet that is globally unique.
              '';
            };
 
            options.subnetId = mkOption {
              type = types.str;
              description = ''
                Identifier of a subnet within the site.
              '';
            };

            options.mask = mkOption {
              type = types.int;
              description = ''
                Mask of a subnet.
              '';
              readOnly = true;
            };

            options.vnetId = mkOption {
              type = types.str;
              description = ''
                Identifier of a vnet that contains a subnet.
              '';
              readOnly = true;
            };

            config.mask = 64;

            config.vnetId = name;

          });
        };

      };
    }));
  };

  config = let
    mkVXLAN = ( cluster: 
      peers: TODO
    );

    mkSubnet = ( cluster:
      subnet: TODO
    );

    peers    = TODO;
    clusters = attrValues cfg.proxmox.cluster;
    subnets  = attrValues cfg.networks.subnet;
  in {
    nixible.playbook = {
      backbone-vxlan  =   peers |> map  mkVXLAN clusters;
      backbone-subnet = subnets |> map mkSubnet clusters;
    };
  };
}
