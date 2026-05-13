{ self, ... }: with self; {
  play-add-host = {
    name, groups ? null, 
    ansible_host, ansible_user, ansible_ssh_common_args ? "-o StrictHostKeyChecking=no", 
    extra-variables ? {} 
  }: {
    tasks = [{
      name = "Add host ${name} to inventory";
      "ansible.builtin.add_host" = {
        inherit name;
        inherit groups;
        inherit ansible_host;
        inherit ansible_user;
        inherit ansible_ssh_common_args;
      } // extra-variables;

      when = "${name} not in groups['all']";
    }];
  };

  # play-add-hosts = foldp play-add-host;

  play-add-pve-hosts = nodes: TODO;  
  # name of host follows convention ( function )
  # add ansible_ssh_pass variable
}
