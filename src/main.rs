use clap::{Parser, Subcommand};

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}


#[derive(Subcommand)]
enum Commands {
    Init    {},
    Plan    {},
    Apply   {},
    Destroy {},
}

fn main() {
    let cli = Cli::parse();

    use std::process::Command;
    use std::collections::HashMap;

    match &cli.command {
        Commands::Init {} => {
            std::fs::create_dir(".nixus").unwrap();
        }
        Commands::Plan {} => {
            let plan = nixus::topological_sort();

            let mut nodes = HashMap::new();

            for (idx, node) in plan.nodes.iter().enumerate() {
                nodes.insert(node.id(), idx);
            }

            // traverse list
            for nodeId in plan.order.iter() {
                let nodeIdx = nodes.get(nodeId as &str).unwrap();
                println!("{}", nodeIdx);

                // match node and plan
                match plan.nodes.get(*nodeIdx).unwrap() {
                    nixus::Node::Terraform { id, name, requires, config, backend } => {
                        // need to first copy the config to local directory under .nixus
                        std::fs::soft_link(config, ".nixus".to_owned() + &name).unwrap();

                        let mut cmd = if backend == "opentofu" { 
                            let mut cmd = Command::new("tofu");
                            cmd.arg("plan");

                            cmd
                        } else if backend == "terraform" { 
                            let mut cmd = Command::new("terraform");
                            cmd.arg("plan");

                            cmd
                        } else {
                            unreachable!()
                        };

                        let output = cmd
                            .output()
                            .expect("Failed to start planning");
                    }
                    nixus::Node::NixOS     { id, .. } => (),
                    nixus::Node::Ansible   { id, .. } => (),
                };
            }
        }
        Commands::Apply {} => {

        }
        Commands::Destroy {} => {

        }
    }
}
