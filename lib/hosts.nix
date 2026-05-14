{ lib, ... }: with lib; let
  _ = node: concatStringsSep "_" [ "HOST" "PVE" node.cluster node.name ];
in {
  mkTaskAddHost = { name, ... }@inputs: [{
    name = "Add host ${name} to inventory";
    "ansible.builtin.add_host" = inputs;
    when = "${name} not in groups['all']";
  }];

  # name of host follows convention ( function )
  # add ansible_ssh_pass variable
  mkPlayAddPVEHost = node: [{
    hosts = "localhost";
    tasks = concatLists [
      TODO
    ];
  }];

}
