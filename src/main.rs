use clap::{Parser, Subcommand};

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}


#[derive(Subcommand)]
enum Commands {
    Plan    {},
    Apply   {},
    Destroy {},
}

use serde::Deserialize;

#[derive(Deserialize, Debug)]
#[serde(tag = "type")]
enum Node {
    Terraform { id: String, name: String, requires: Vec<String>, backend: String, },
    NixOS     { id: String, name: String, requires: Vec<String>, },
    Ansible   { id: String, name: String, requires: Vec<String>, config : String, },
}

impl Node {
    fn id(&self) -> &str {
        match self {
            Node::Terraform { id, .. } => id,
            Node::NixOS     { id, .. } => id,
            Node::Ansible   { id, .. } => id,
        }
    }
}


#[derive(Deserialize, Debug)]
struct Plan {
    nodes: Vec<Node>,
    order: Vec<String>,
}

fn topological_sort() -> Plan {
    use std::process::Command;

    let output = Command::new("nix")
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
        panic!("Failed to call TopoSort API");
    }

    let plan: Plan = serde_json::from_str(
        &String::from_utf8(output.stdout).expect("API output is not valid UTF-8")
    ).unwrap();

    println!("{:?}", plan);

    plan
}

fn main() {
    let cli = Cli::parse();

    use std::collections::HashMap;

    match &cli.command {
        Commands::Plan {} => {
            let plan = topological_sort();

            let mut nodes = HashMap::new();

            for (idx, node) in plan.nodes.iter().enumerate() {
                nodes.insert(node.id(), idx);
            }
        }
        Commands::Apply {} => {

        }
        Commands::Destroy {} => {

        }
    }
}
