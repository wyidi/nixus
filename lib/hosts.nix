{ self, lib, ... }: with lib; let
  inherit (self) mkTaskAskAndSetVar;

  mkTaskAddHost = { name, ... }@inputs: [{
    name = "Add host ${name} to inventory";
    "ansible.builtin.add_host" = inputs;
    when = "${name} not in groups['all']";
  }];

  mkNamePVEHost    = node: user: concatStringsSep "_" [ "PVE" "HOST" (toUpper node.cluster) (toUpper node.name) (toUpper user)];
  mkNamePVEHostPWD = node: user: concatStringsSep "_" [ "PVE" "PWD"  (toUpper node.cluster) (toUpper node.name) (toUpper user)];
in {
  inherit mkTaskAddHost;
  inherit mkNamePVEHost;
  inherit mkNamePVEHostPWD;

  mkTaskGetPVEHostPWD = node: mkTaskAskAndSetVar (mkNamePVEHostPWD node);

  mkPlayAddPVEHost = node: let 
    name = mkNamePVEHost    node "root";
    pwd  = mkNamePVEHostPWD node "root";
    TaskAskAndSetVar = mkTaskAskAndSetVar pwd;
    TaskAddHost      = mkTaskAddHost {
      inherit name;
      ansible_host = node.address; # Using IPv6 is suggested
      ansible_user = "root";
      ansible_ssh_common_args = "-o StrictHostKeyChecking=no";
      ansible_ssh_pass = "{{ hostvars['localhost']['${pwd}'] | default(omit) }}";
    };
  in [{
    tasks = concatLists [
      TaskAskAndSetVar
      TaskAddHost
    ];
  }];

}
