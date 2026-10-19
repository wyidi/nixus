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

                        // TODO: should remove config.tf.json file or symlink if already exists
                        match std::fs::remove_file(cfgdir.to_owned() + "/config.tf.json") {
                            Ok(()) => (),
                            Err(e) if e.kind() == std::io::ErrorKind::NotFound => {
                                ()
                            }
                            Err(_) => todo!(),
                        };

                        let mut cmd = {
                            let mut cmd = Command::new("nix");
                            cmd.arg("build");
                            cmd.arg(format!(".#nixus.aarch64-darwin.terranix.{}", name));
                            cmd.arg("-o");
                            cmd.arg("config.tf.json");

                            cmd
                        };

                        cmd.current_dir(std::path::Path::new(&cfgdir));

                        let mut child = cmd
                            .spawn()
                            .expect("Failed to spawn build config");
                        
                        child.wait()
                             .expect("Failed to wait build config finish");

                        //std::fs::soft_link(config, cfgdir.clone() + "/" + "config.tf.json").unwrap();

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

                        child = cmd
                            .spawn()
                            .expect("Failed to init terraform config");

                        child.wait()
                             .expect("Failed to wait init terraform config");

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

                        child = cmd
                            .spawn()
                            .expect("Failed to start planning");

                        child.wait()
                             .expect("Failed to wait planning");
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

                        let mut child = cmd
                            .spawn()
                            .expect("Failed to init terraform config. Try to include terraform/tofu cli from nixpkgs to devShell.");

                        child.wait()
                             .expect("Failed to wait init terraform config");

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

                        child = cmd
                            .spawn()
                            .expect("Failed to start applying");

                        child.wait()
                             .expect("Failed to wait apply");
                              
                    }
                    nixus::Node::NixOS     { id, name, .. } => {
                        let mut cmd = Command::new("colmena");
                        cmd.arg("apply");
                        cmd.arg("--on");
                        cmd.arg(format!("{}", name));

                        let mut child = cmd
                            .spawn()
                            .expect("Failed to deploy nixos via colmena. Try to include config.colmena.package.colmena in devShell.");

                        child.wait()
                             .expect("Failed to wait colmena");

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
