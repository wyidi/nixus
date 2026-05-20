{ lib, nixus-lib, ... }: with lib; let
  inherit (nixus-lib) mkClusterNodeOptions;
in {
  options.nixus.proxmox = mkClusterNodeOptions (cluster: node: {
    
  });
}
