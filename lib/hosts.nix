{ self, lib, ... }: with lib; let
  inherit (self) mkTaskAskAndSetVar;

  mkTaskAddHost = { name, ... }@inputs: [{
    name = "Add host ${name} to inventory";
    "ansible.builtin.add_host" = inputs;
    when = "${name} not in groups['all']";
  }];

  mkNamePVEHost    = node: concatStringsSep "_" [ "HOST" "PVE" (toUpper node.cluster) (toUpper node.name) ];
  mkNamePVEHostPWD = node: concatStringsSep "_" [ "PWD"  "PVE" (toUpper node.cluster) (toUpper node.name) ];
in {
  inherit mkTaskAddHost;
  inherit mkNamePVEHost;
  inherit mkNamePVEHostPWD;

  mkTaskGetPVEHostPWD = node: mkTaskAskAndSetVar (mkNamePVEHostPWD node);

  mkPlayAddPVEHost = node: let 
    name = mkNamePVEHost    node;
    pwd  = mkNamePVEHostPWD node;
    TaskAskAndSetVar = mkTaskAskAndSetVar pwd;
    TaskAddHost      = mkTaskAddHost { 
      inherit name;
      ansible_host = node.address; # Using IPv6 is suggested
      ansible_user = "root";
      ansible_ssh_common_args = "-o StrictHostKeyChecking=no";
      ansible_ssh_pass = "{{ hostvars['localhost']['${pwd}'] }}";
    };
  in [{
    hosts = "localhost";
    tasks = concatLists [
      TaskAskAndSetVar
      TaskAddHost
    ];
  }];

}
