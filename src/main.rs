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
            let plan = nixus::toposort();

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

                        let cfgdir = ".nixus/".to_owned() + &name;
                        std::fs::soft_link(config, cfgdir.clone() + "/" + "config.tf.json").unwrap();

                        let mut cmd = if backend == "opentofu" {
                            let mut cmd = Command::new("tofu");
                            cmd.arg("init");
                            cmd.arg("-upgrade");

                            cmd
                        } else if backend == "terraform" { 
                            let mut cmd = Command::new("terraform");
                            cmd.arg("init");
                            cmd.arg("-upgrade");

                            cmd
                        } else {
                            unreachable!()
                        };

                        cmd.current_dir(std::path::Path::new(&cfgdir));

                        let mut output = cmd
                            .output()
                            .expect("Failed to init terraform config");

                        cmd = if backend == "opentofu" {
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

                        cmd.current_dir(std::path::Path::new(&cfgdir));

                        output = cmd
                            .output()
                            .expect("Failed to start planning");
                    }
                    nixus::Node::NixOS     { id, .. } => (),
                    nixus::Node::Ansible   { id, .. } => (),
                };
            }
        }
        Commands::Apply {} => {
            let plan = nixus::toposort();

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

                        let cfgdir = ".nixus/".to_owned() + &name;
                        std::fs::soft_link(config, cfgdir.clone() + "/" + "config.tf.json").unwrap();

                        let mut cmd = if backend == "opentofu" {
                            let mut cmd = Command::new("tofu");
                            cmd.arg("init");
                            cmd.arg("-upgrade");

                            cmd
                        } else if backend == "terraform" { 
                            let mut cmd = Command::new("terraform");
                            cmd.arg("init");
                            cmd.arg("-upgrade");

                            cmd
                        } else {
                            unreachable!()
                        };

                        cmd.current_dir(std::path::Path::new(&cfgdir));

                        let mut output = cmd
                            .output()
                            .expect("Failed to init terraform config. Try to include terraform/tofu cli from nixpkgs to devShell.");

                        cmd = if backend == "opentofu" {
                            let mut cmd = Command::new("tofu");
                            cmd.arg("apply");

                            cmd
                        } else if backend == "terraform" { 
                            let mut cmd = Command::new("terraform");
                            cmd.arg("apply");

                            cmd
                        } else {
                            unreachable!()
                        };

                        cmd.current_dir(std::path::Path::new(&cfgdir));

                        output = cmd
                            .output()
                            .expect("Failed to start planning");
                    }
                    nixus::Node::NixOS     { id, name, .. } => {
                        let mut cmd = Command::new("colmena");
                        cmd.arg("apply");
                        cmd.arg(format!("--on {}", name));

                        let output = cmd
                            .output()
                            .expect("Failed to deploy nixos via colmena. Try to include config.colmena.package.colmena in devShell.");

                    }
                    nixus::Node::Ansible   { id, .. } => {
                        todo!()
                    },
                };
            }

        }
        Commands::Destroy {} => {

        }
    }
}
