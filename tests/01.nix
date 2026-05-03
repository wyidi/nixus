{ ... }: {
  perSystem = { config, ... }: {
    packages.collection-community-proxmox = config.nixible.collection.community-proxmox.package;
  };

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
}
