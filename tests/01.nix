{ ... }: {
  perSystem = { config, ... }: {
    packages.collection-community-proxmox = config.nixible.package.collection.community-proxmox;

    nixible.playbook = {
      network = [{
        name  = "Deploy network";
        tasks = [ { name = "Create VXLAN"; debug.msg = "Hello World"; } ];
      }];
    };

    nixible.collection = {
      community-proxmox = {
        version = "1.6.0";
        hash = "sha256-YRYY0qdQqWi5N2rh+N0AfiH5l0MWhaT+xdtC926zlA0=";
        requires = pkgs: with pkgs; [ proxmoxer requests ];
      };
    };

    terraform.config.test01 = {
      terraform = {
        backend.s3 = {
          bucket = "terraform-bucket";

          region = "garage"; # value s3_api.s3_region inside garage.toml.j2

          key = "terraform.tfstate";
          endpoints = {
            s3 = "http://10.10.3.1:3900";
          };

          insecure                    = true;
          skip_credentials_validation = true;
          # skip_requesting_account_id  = true;
          # skip_metadata_api_check     = true;
          skip_region_validation      = true;
          use_path_style              = true;
        };

        required_providers = {
          vault = {
            source = "hashicorp/vault";
            version = "5.7.0";
          };

          proxmox = {
            source = "bpg/proxmox";
            # version = "0.93.0";
            version = "0.100.0";
          };

          random = {
            source  = "hashicorp/random";
            version = "3.8.1";
          };

          tls = {
            source  = "hashicorp/tls";
            version = "4.2.1";
          };

          restapi = {
            source  = "Mastercard/restapi";
            version = "3.0.0";
          };

        };
  };

  provider.vault = {
    address = "http://10.10.2.1";
  };

    };

    packages.terraform-test01 = builtins.trace "${config.terraform.package.config.test01}" config.terraform.package.config.test01;
  };

  nixus = {
    proxmox.cluster.cluster0 = {
      node.node01 = {
        address = "";

        zpool.tank = {
          vdevs = [{
            type = "stripe";
            disks = [ "deva" ];
          }];
          dataset = {
            test = {};
          };
        };
      };
      api_host = "";
      api_port = 8006;
      api_user = "";
    };

    networks.subnet.vnet0 = { };
  };

}
