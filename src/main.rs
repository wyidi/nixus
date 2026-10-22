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
            let plan = nixus::plan();

            let mut nodes = HashMap::new();

            for (idx, node) in plan.nodes.iter().enumerate() {
                nodes.insert(node.id(), idx);
            }

            // traverse list
            for nodeId in plan.order.iter() {
                let nodeIdx = nodes.get(nodeId as &str).unwrap();

                match plan.nodes.get(*nodeIdx).unwrap() {
                    nixus::Node::Terraform { id, name, requires, backend } => {

                        // The workspace for child processes
                        let cfgdir = ".nixus/".to_owned() + &name;

                        // Removes config.tf.json if previously created
                        match std::fs::remove_file(cfgdir.to_owned() + "/config.tf.json") {
                            Ok(()) => (),
                            Err(e) if e.kind() == std::io::ErrorKind::NotFound => {
                                ()
                            }
                            Err(_) => todo!(),
                        };

                        // build terraform config and symlink to config.tf.json under workspace
                        let mut cmd = {
                            let mut cmd = Command::new("nix");
                            cmd.arg("build");
                            cmd.arg(format!(".#terranix.{}.config.{}", nixus::eval_flake_system(), name));
                            cmd.arg("-o");
                            cmd.arg("config.tf.json");

                            cmd
                        };

                        cmd.current_dir(std::path::Path::new(&cfgdir));

                        let mut child = cmd
                            .spawn()
                            .expect("Failed to spawn config builder");

                        child.wait().expect("Failed to wait config builder");


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
                            .expect("Failed to start terraform init command");

                        child.wait().expect("Failed to wait terraform init command");

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
                            .expect("Failed to start terraform plan command");

                        child.wait().expect("Failed to wait terraform plan command");
                    }
                    nixus::Node::NixOS   { .. } => (),
                    nixus::Node::Ansible { .. } => (),
                    nixus::Node::Service { .. } => (),
                };
            }
        }
        Commands::Apply {} => {
            let plan = nixus::plan();

            let mut nodes = HashMap::new();

            for (idx, node) in plan.nodes.iter().enumerate() {
                nodes.insert(node.id(), idx);
            }

            // traverse list
            for nodeId in plan.order.iter() {
                let nodeIdx = nodes.get(nodeId as &str).unwrap();

                match plan.nodes.get(*nodeIdx).unwrap() {
                    nixus::Node::Terraform { id, name, requires, backend } => {

                        // The workspace for child processes
                        let cfgdir = ".nixus/".to_owned() + &name;

                        // Removes config.tf.json if previously created
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
                            cmd.arg(format!(".#terranix.{}.config.{}", nixus::eval_flake_system(), name));
                            cmd.arg("-o");
                            cmd.arg("config.tf.json");

                            cmd
                        };

                        cmd.current_dir(std::path::Path::new(&cfgdir));

                        let mut child = cmd
                            .spawn()
                            .expect("Failed to spawn config builder");

                        child.wait().expect("Failed to wait config builder");



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
                            .expect(r#"
                                Failed to start terraform init command.
                                Try again after including terraform/tofu package in devShell.
                            "#);

                        child.wait().expect("Failed to wait terraform init command");

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
                            .expect("Failed to start terraform apply command");

                        child.wait().expect("Failed to wait terraform apply command");
                    }
                    nixus::Node::NixOS { id, name, .. } => {
                        let mut cmd = Command::new("colmena");
                        cmd.arg("apply");
                        cmd.arg("--on");
                        cmd.arg(format!("{}", name));

                        let mut child = cmd
                            .spawn()
                            .expect(r#"
                                Failed to start colmena apply command.
                                Try again after including config.colmena.package.colmena in devShell.
                            "#);

                        child.wait().expect("Failed to wait colmena apply command");
                    }
                    nixus::Node::Ansible { id, .. } => {
                        todo!()
                    },
                    nixus::Node::Service { .. } => (),
                };
            }

        }
        Commands::Destroy {} => {

        }
    }
}
