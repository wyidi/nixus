{ lib, ... }: with lib; {
  options.nixus.proxmox.node = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        enable = mkEnableOption "proxmox host ${name}";

        address = mkOption {
          type = types.str;
          description = "IPv4 address of the host.";
        };
      };
    }));
  };
}
