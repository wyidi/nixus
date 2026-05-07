{ ... }: let
  mkPrompt = ansible_variable: {
    block = [
      { name = "Prompt ${ansible_variable}";
        "ansible.builtin.pause" = {
          echo = false;
          prompt = "Enter ${ansible_variable}:";
        };
        register = "_${ansible_variable}";
      }
      { name = "Register ${ansible_variable}";
        "ansible.builtin.set_fact" = {
          ${ansible_variable} = "{{ _${ansible_variable}.user_input }}";
        };
      }
    ];
    when = "${ansible_variable} is not defined";
    no_log = true;
  };

  task-prompt-vars = map mkPrompt;

in {
  inherit task-prompt-vars;
}
