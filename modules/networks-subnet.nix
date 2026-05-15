{ lib, nixus-lib, config, ... }: with lib; let cfg = config.nixus; in {

  options.nixus.networks.subnet = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        enable = mkEnableOption "subnet ${name}";

        name = mkOption {
          type = types.str;
          description = ''
            Name of the subnet.
          '';
          readOnly = true;
        };

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
              default = 64; readOnly = true;
            };

          });
        };

      };

      config.name = name;

    }));

    default = { };
  };

  config = let
    inherit (nixus-lib) foldt foldts flattenNodes mkNameClusterPWD mkTaskGetClusterPWD;

    clusters = attrValues cfg.proxmox.cluster;
    subnets  = attrValues cfg.networks.subnet;

    peers = clusters |> flattenNodes |> map (node: node.address);
    zone.name = "nixus";

    mkTaskAddVXLAN = ( cluster: {
        name = "Create VXLAN zone for ${cluster.name}";
        "community.proxmox.proxmox_zone" = {
          api_host     = cluster.api_host;
          api_port     = cluster.api_port;
          api_user     = cluster.api_user;
          api_password = "{{${mkNameClusterPWD cluster}}}";

          validate_certs = cluster.validate_certs;

          type = "vxlan";
          zone = zone.name;

          peers = concatStringsSep "," peers; #ex: "192.168.0.1,192.168.0.2,192.168.0.3"

          bridge = "vmbr0"; # TODO: parameterize bridge

          state = "present";
        };
      }
    );

    mkTaskAddSubnet = ( cluster:
      subnet: {
        name = "Create subnet ${subnet.name} at ${cluster.name}";
        block = [{
          "community.proxmox.proxmox_vnet" = {
            api_host     = cluster.api_host;
            api_port     = cluster.api_port;
            api_user     = cluster.api_user;
            api_password = "{{${mkNameClusterPWD cluster}}}";
 
            validate_certs = cluster.validate_certs;

            vnet = subnet.name;
            zone =   zone.name;

            state = "present";
          };
        }];
      }
    );

    TaskGetClusterPWDs = foldt  mkTaskGetClusterPWD clusters;
    TaskAddVXLANs      = foldt  mkTaskAddVXLAN      clusters;
    TaskAddSubnets     = foldts mkTaskAddSubnet     [ clusters subnets ];

  in { perSystem = { ... }: {

    nixible.playbook.vxlan = [{
      tasks = concatLists [
        TaskGetClusterPWDs
        TaskAddVXLANs
        TaskAddSubnets
      ];
    }];

  };};
}
