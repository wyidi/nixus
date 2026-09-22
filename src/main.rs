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
}

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Plan {} => {
            
        }
        Commands::Apply {} => {

        }
        Commands::Destroy {} => {

        }
    }
}
