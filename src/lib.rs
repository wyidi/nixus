use serde::Deserialize;

#[derive(Deserialize, Debug)]
#[serde(tag = "type")]
pub enum Node {
    Terraform { id: String, name: String, requires: Vec<String>, backend: String, },
    NixOS     { id: String, name: String, requires: Vec<String>, },
    Ansible   { id: String, name: String, requires: Vec<String>, config : String, },
}

impl Node {
    pub fn id(&self) -> &str {
        match self {
            Node::Terraform { id, .. } => id,
            Node::NixOS     { id, .. } => id,
            Node::Ansible   { id, .. } => id,
        }
    }
}


#[derive(Deserialize, Debug)]
pub struct Plan {
    pub nodes: Vec<Node>,
    pub order: Vec<String>,
}

pub fn topological_sort(cd: Option<&std::path::Path>) -> Plan {
    use std::process::Command;

    let output = Command::new("nix")
        .current_dir(cd.unwrap_or(std::path::Path::new(".")))
        .arg("eval")
        .arg("--impure")
        .arg("--json")
        .arg("--expr")
        .arg(r#"
        let
            flake = builtins.getFlake (toString ./.);
        in
            flake.nixus.${builtins.currentSystem}.API.TopoSort { }
        "#)
        .output()
        .expect("Failed to start evaluation");

    if !output.status.success() {
        println!("{}", &String::from_utf8(output.stdout).expect("API output is not valid UTF-8"));
        println!("{}", &String::from_utf8(output.stderr).expect("API output is not valid UTF-8"));
        panic!("Failed to call TopoSort API");
    }

    let plan: Plan = serde_json::from_str(
        &String::from_utf8(output.stdout).expect("API output is not valid UTF-8")
    ).unwrap();

    println!("{:?}", plan);

    plan
}

