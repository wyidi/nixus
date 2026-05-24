{ ... }: { perSystem = { ... }: {
  # This config is shared across all configs
  terraform.config.boilerplate = {
    required_providers.proxmox = {
      source = "bpg/proxmox";
      version = "0.106.0";
    };
  };
};}
