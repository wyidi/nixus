inputs: 
  inputs.flake-parts.lib.mkFlake { inherit inputs; } ({ inputs, ... } :{
      flake = { };

      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ];

      imports = [
        inputs.nixus.flakeModule
      ];


      perSystem = { ... }: {
        nixus.node.tf = {
          "ProxmoxVM.example" = {

          };
        };

        terranix.config = {
          "ProxmoxVM.example" = {

          };
        };
      };

  })
