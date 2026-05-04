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
    TODO = builtins.throw "TODO";

    clusters = attrValues cfg.proxmox.cluster;
    subnets  = attrValues cfg.networks.subnet;

    peers = clusters
      |> map (cluster: attrValues cluster.node)
      |> concatLists
      |> map (node: node.address);

    mkPrompt = ansible_variable: {
      block = [
        { name = "Prompt ${ansible_variable}";
          "ansible.builtin.pause" = {
            echo = false;
            prompt = "Enter ${ansible_variable}:";
          };
          register = "_${ansible_variable}";
        }
        { name = "Register ${ansible_variable}";
          "ansible.builtin.set_fact" = {
            ${ansible_variable} = "{{ _${ansible_variable}.user_input }}";
          };
        }
      ];
      when = "${ansible_variable} is not defined";
      no_log = true;
    };

    mkPrompts = map mkPrompt;

    addPrompts = prompts: tasks: mkPrompts prompts ++ tasks;

    mkPasswordVar = cluster: "PROXMOX_${toUpper cluster.name}_API_PASSWORD";

    mkVXLAN = ( cluster: 
      peers: {
        name = "Create VXLAN zone";
        "community.proxmox.proxmox_zone" = {
          api_host     = cluster.api_host;
          api_port     = cluster.api_port;
          api_user     = cluster.api_user;
          api_password = "{{${mkPasswordVar cluster}}}";

          validate_certs = cluster.validate_certs;

          type = "vxlan";
          zone = "nixus";

          peers = concatStringsSep "," peers; #ex: "192.168.0.1,192.168.0.2,192.168.0.3"

          state = "present";
        };
      }
    );

    mkSubnet = ( cluster:
      subnet: TODO
    );

    mkSubnets = ( cluster:
      subnets: TODO
    );

  in {
    perSystem = { pkgs, config, ... }: let cfg = config.nixible;
    in {
      nixible.playbook = {
        backbone-vxlan  = [{
          tasks = map (f: f   peers) (map   mkVXLAN clusters) |> addPrompts (map mkPasswordVar clusters);
        }];
        backbone-subnet = [{
          tasks = map (f: f subnets) (map mkSubnets clusters) |> addPrompts [];
        }];
      };
    };
  };
}
