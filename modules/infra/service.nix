# service that groups nodes or services
# I think this can be implemented with the empty node that depends on the other nodes
# The most outer empty node indicates the highest level of service (But current implement does not guarantee this)
# this module is just a wrapper of it

# The user-facing service moudle(ex: proxmox nixos vm) should register it's given name as a service
# should crash if some other module registers the same name. Would be great if we provide a way to alias

{ flake-parts-lib, lib, ... }: with lib; {
  options.perSystem = flake-parts-lib.mkPerSystemOption ( { config, ... } : {
    options.nixus.service = mkOption {
      type = types.attrsOf (types.submodule ({ name, ... }: {
        options.name = mkOption {
          type     = types.str;
          default  = name;
          readOnly = true;
          description = "Name of the service.";
        };

        options.requires = mkOption {
          type = types.listOf types.str;
          description = "List of required services.";
        };

        options.parts = mkOption {
          type = types.listOf types.str;
          description = "List of nodes that compose this service.";
          # Component could be either service or node. In the form of {type}.{name}
          # If it is a service, the type could be neglected
        };

        # How should I propagate this? 
        # disability is propagated to components
        options.disabled = mkOption {
          type    = types.bool;
          default = false;
          description = "Whether this service is disabled or not.";
        };
      }));
    };
  });

  config.perSystem = { config, ... }: let
    # should work on this
    #graph = mergeAttrsList (builtins.mapAttrsToList (name: value: 
    #  mergeAttrsList (builtins.map (x: {
    #    ${x} = name;
    #  }) value.requires)
    #) config.nixus.service);
  in {
    config.nixus.node.svc = builtins.mapAttrs (name: value: let
      v = {
        parts = builtins.map (str:
          # Fragile structure. Should try to couple with the actual prefix list.
          if lib.any lib.hasPrefix [ "Terraform." "NixOS." "Ansible." "Service." ] then
            str
          else
            "Service" + "." + str
        ) value.parts;
        requires = builtins.map (str: "Service" + "." + str) value.requires;
      };
    in {
      requires = builtins.concatLists [
        v.parts
        v.requires
      ];

      # service = graph.${name};

      # disabled = value.disabled || config.nixus.service.${graph.${name}}.disabled;
    }) config.nixus.service;
  };
}
