use serde::Deserialize;

#[derive(Deserialize, Debug, PartialEq, Eq)]
#[serde(tag = "type")]
pub enum Node {
    Terraform { id: String, name: String, requires: Vec<String>, backend: String },
    NixOS     { id: String, name: String, requires: Vec<String>, },
    Ansible   { id: String, name: String, requires: Vec<String>, },
}

impl Node {
    pub fn id(&self) -> &str {
        match self {
            Node::Terraform { id, .. } => id,
            Node::NixOS     { id, .. } => id,
            Node::Ansible   { id, .. } => id,
        }
    }

    pub fn name(&self) -> &str {
        match self {
            Node::Terraform { name, .. } => name,
            Node::NixOS     { name, .. } => name,
            Node::Ansible   { name, .. } => name,
        }
    }


    pub fn requires(&self) -> &Vec<String> {
        match self {
            Node::Terraform { requires, .. } => requires,
            Node::NixOS     { requires, .. } => requires,
            Node::Ansible   { requires, .. } => requires,
        }
    }
}


#[derive(Deserialize, Debug, PartialEq, Eq)]
pub struct Plan {
    pub nodes: Vec<Node>,
    pub order: Vec<String>,
}


use std::process::Command;

pub fn toposort() -> Plan {

    // pure flake output attribute evaluation
    let output = Command::new("nix")
        .arg("eval")
        .arg(format!(".#nixus.{}.plan", eval_flake_system()))
        .arg("--json")
        .output()
        .expect("Failed to start deploy order evaluation");

    // impure evaluation example    
    /*
    let output = Command::new("nix")
        .arg("eval")
        .arg("--impure")
        .arg("--json")
        .arg("--expr")
        .arg(r#"
        let
            flake = builtins.getFlake (toString ./.);
        in
            flake.nixus.${builtins.currentSystem}.plan
        "#)
        .output()
        .expect("Failed to start evaluation");
    */

    if !output.status.success() {
        println!("{}", &String::from_utf8(output.stdout).expect("stdout is not valid UTF-8"));
        println!("{}", &String::from_utf8(output.stderr).expect("stderr is not valid UTF-8"));
        panic!("Failed to evaluate deploy order");
    }

    let plan: Plan = serde_json::from_str(
        &String::from_utf8(output.stdout).expect("stdout is not valid UTF-8")
    ).unwrap();

    println!("{:#?}", plan);

    plan
}


pub fn eval_flake_system() -> String {
    let system_eval = Command::new("nix")
        .arg("eval")
        .arg("--impure")
        .arg("--expr")
        .arg("builtins.currentSystem")
        .output()
        .expect("Failed to start system string evaluation");

    let system_string = &String::from_utf8(system_eval.stdout).expect("API output is not valid UTF-8");

    let system = system_string.trim_end();

    return system.to_owned();
}

