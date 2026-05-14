{ lib, ... }: with lib; let
  mkTaskAskVar = name: [{
    name = "Prompt ${name}";
    "ansible.builtin.pause" = {
      echo = false;
      prompt = "Enter ${name}:";
    };
    register = "${name}";
  }];

  mkTaskSetVar = name: [{
    name = "Register ${name}";
    "ansible.builtin.set_fact" = {
      ${name} = "{{ ${name}.user_input }}";
    };
  }];
in {

  mkTaskAskAndSetVar = name: [{
    block = concatLists [
      (mkTaskPromptVar name)
      (mkTaskSetVar    name)
    ];
    when = "${name} is not defined";
    no_log = true;
  }];

}
