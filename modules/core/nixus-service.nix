{ lib, flake-parts-lib, ... }: with lib; let
  module_service = types.submodule ( { ... }: {
    options = {
      constructor = mkOption {
        type = types.str;
        description = ''
          The ansible playbook for creating the service.
        '';
      };

      destructor = mkOption {
        type = types.str;
        description = ''
          The ansible playbook for destroying the service.
        '';
      };

      dependency = mkOption {
        type = types.listOf types.str;
        description = ''
          The service-to-service dependency.
        '';
      };
    };
  });

in {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { ... } : {
    options.nixus.service = mkOption {
      type = types.attrsOf module_service;
    };

    # Creates new composite playbook per service (for create)
    # Creates new composite playbook per service (for destroy)
    # Creates new composite playbook that deploys all services
    # Creates new composite playbook that destroys all services
  });
}
