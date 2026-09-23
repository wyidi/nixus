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


#[derive(Deserialize, Debug)]
struct Plan {
    nodes: Vec<Node>,
    order: Vec<String>,
}

fn topological_sort() {
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
        .expect("Failed to call nixus TopoSort API");

    println!("status: {}", output.status);

    use std::io::{self, Write};
    io::stdout().write_all(&output.stdout).expect("Failed to write at stdout");
    io::stderr().write_all(&output.stderr).expect("Failed to write at stderr");

    let plan: Plan = serde_json::from_str(&String::from_utf8(output.stdout).expect("not valid UTF8")).unwrap();
    println!("deserialized = {:?}", plan);

}

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Plan {} => {
            topological_sort(); 
        }
        Commands::Apply {} => {

        }
        Commands::Destroy {} => {

        }
    }
}
